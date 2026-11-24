#!/usr/bin/env bash
# Positive and expected-failure verification cases for both tools.
#
# Usage: ci/smoke-proofs.sh [--creusot] [--verus]   (default: both)
#
# The point of the negative cases is that the harness must require rejection
# of the *specific* obligation. A parse error, a missing contract library or
# an unresolved prover is a broken setup, not a passing negative test.
#
# The Creusot cases run in a scratch package created outside the workspace
# with `cargo creusot new`, so `cargo creusot init` is never run over the
# existing library.

source "$(dirname "$0")/lib.sh"

RUN_CREUSOT=0
RUN_VERUS=0
if (( $# == 0 )); then
    RUN_CREUSOT=1
    RUN_VERUS=1
fi
for arg in "$@"; do
    case "$arg" in
        --creusot) RUN_CREUSOT=1 ;;
        --verus)   RUN_VERUS=1 ;;
        *) die "unknown argument: $arg" ;;
    esac
done

readonly SMOKE="$REPO_ROOT/proofs/smoke"
out="$(log_dir smoke)"
overall=0

# --- Creusot ---------------------------------------------------------------

creusot_smoke() {
    command -v cargo-creusot >/dev/null 2>&1 || {
        warn "cargo-creusot is not on PATH; skipping the Creusot smoke cases"
        return "$EX_CONFIG"
    }

    local scratch
    scratch="$(mktemp -d "${TMPDIR:-/tmp}/creusot-smoke.XXXXXX")"
    trap 'rm -rf "$scratch"' RETURN

    say "Creusot smoke: creating a scratch package outside the workspace"
    ( cd "$scratch" && cargo creusot new creusot-smoke >/dev/null )
    local project="$scratch/creusot-smoke"
    [[ -f "$project/src/lib.rs" ]] || die "cargo creusot new produced no library"
    info "scratch package: $project"

    say "Creusot smoke: positive case"
    cp "$SMOKE/creusot_smoke.rs" "$project/src/lib.rs"
    set +e
    ( cd "$project" && cargo creusot ) > "$out/creusot-positive.log" 2>&1
    local positive=$?
    set -e
    if (( positive != 0 )) || ! grep -q 'Proved (' "$out/creusot-positive.log"; then
        sed 's/^/    | /' "$out/creusot-positive.log" >&2
        die "the positive Creusot case did not prove"
    fi
    info "proved: $(grep -c 'Proved (' "$out/creusot-positive.log") goal(s)"

    say "Creusot smoke: expected-failure case"
    cp "$SMOKE/creusot_smoke_fail.rs" "$project/src/lib.rs"
    set +e
    ( cd "$project" && cargo creusot ) > "$out/creusot-negative.log" 2>&1
    local negative=$?
    set -e
    if (( negative == 0 )); then
        sed 's/^/    | /' "$out/creusot-negative.log" >&2
        die "the expected-failure Creusot case was accepted"
    fi
    # Require the failure to be the postcondition of `increment`, not an
    # unrelated setup error.
    grep -q 'vc_increment' "$out/creusot-negative.log" \
        || { sed 's/^/    | /' "$out/creusot-negative.log" >&2
             die "the Creusot case failed, but not on increment's obligation"; }
    grep -q 'proof failed' "$out/creusot-negative.log" \
        || { sed 's/^/    | /' "$out/creusot-negative.log" >&2
             die "the Creusot case failed without a proof failure; the setup is broken"; }
    info "rejected on vc_increment, as expected (exit $negative)"

    say "Creusot smoke: both paths behaved as specified"
}

# --- Verus -----------------------------------------------------------------

verus_smoke() {
    if [[ "$(pin meta.verus_status)" != "observed" ]]; then
        warn "Verus pins are unpopulated; skipping the Verus smoke cases"
        return "$EX_CONFIG"
    fi
    command -v verus >/dev/null 2>&1 || {
        warn "verus is not on PATH; skipping the Verus smoke cases"
        return "$EX_CONFIG"
    }

    say "Verus smoke: tool identity"
    verus --version | tee "$out/verus-version.txt" | sed 's/^/    | /'

    say "Verus smoke: positive case"
    set +e
    verus "$SMOKE/verus_smoke.rs" > "$out/verus-positive.log" 2>&1
    local positive=$?
    set -e
    if (( positive != 0 )); then
        sed 's/^/    | /' "$out/verus-positive.log" >&2
        die "the positive Verus case did not verify"
    fi
    # Parsing is not verifying: require a non-zero verified count.
    grep -Eq 'verification results:: *[1-9][0-9]* verified' \
        "$out/verus-positive.log" \
        || { sed 's/^/    | /' "$out/verus-positive.log" >&2
             die "the positive Verus case reported no verified function"; }
    info "verified, with a non-zero verified count"

    say "Verus smoke: expected-failure case"
    set +e
    verus "$SMOKE/verus_smoke_fail.rs" > "$out/verus-negative.log" 2>&1
    local negative=$?
    set -e
    if (( negative == 0 )); then
        sed 's/^/    | /' "$out/verus-negative.log" >&2
        die "the expected-failure Verus case was accepted"
    fi
    grep -q 'postcondition' "$out/verus-negative.log" \
        || { sed 's/^/    | /' "$out/verus-negative.log" >&2
             die "the Verus case failed, but not on the postcondition"; }
    info "rejected on the postcondition, as expected (exit $negative)"

    say "Verus smoke: both paths behaved as specified"
}

if (( RUN_CREUSOT )); then
    set +e; creusot_smoke; rc=$?; set -e
    (( rc == 0 )) || overall=$rc
fi
if (( RUN_VERUS )); then
    set +e; verus_smoke; rc=$?; set -e
    (( rc == 0 )) || overall=$rc
fi

write_provenance "$out/provenance.toml" smoke
if (( overall == 0 )); then
    say "smoke: passed"
else
    warn "smoke: one or both tools were unavailable; exiting $overall"
fi
exit "$overall"
