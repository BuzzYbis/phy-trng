#!/usr/bin/env bash
# Resolve recorded pins, validate checksums and report exact tool identities.
#
# Usage: ci/bootstrap-proofs.sh [--require-all]
#
#   --require-all   Also fail when a pin section is unpopulated. Release CI
#                   uses this; bootstrap development does not.
#
# This script reports identities and fails on a mismatch. It never installs
# anything, and it never treats an unpopulated pin as a pass.

source "$(dirname "$0")/lib.sh"

REQUIRE_ALL=0
for arg in "$@"; do
    case "$arg" in
        --require-all) REQUIRE_ALL=1 ;;
        *) die "unknown argument: $arg" ;;
    esac
done

status=0
note_gap() {
    if (( REQUIRE_ALL )); then
        die "$1"
    fi
    warn "$1"
    status=$EX_CONFIG
}

say "Host and repository"
info "host: $(uname -srm)"
info "source commit: $(source_commit) ($(dirty_state))"
info "pins: $PINS"
[[ -f "$PINS" ]] || die "missing $PINS"
info "pins revision: $(pin meta.revision), recorded $(pin meta.recorded)"

say "Host build toolchain"
need_cmd cargo
need_cmd rustc
expect_pin host_build.rustc "$(rustc --version | sed 's/^rustc //')" "rustc"
expect_pin host_build.cargo "$(cargo --version | sed 's/^cargo //')" "cargo"

say "Creusot"
if ! command -v cargo-creusot >/dev/null 2>&1; then
    note_gap "cargo-creusot not found on PATH"
else
    # `cargo creusot version` reports the verifier, its Rust toolchain, Why3
    # and every solver it will invoke. That is the authoritative identity:
    # a different solver build earlier on PATH is not the one Why3 uses.
    versions="$(cargo creusot version)"
    printf '%s\n' "$versions" | sed 's/^/    | /'

    expect_pin creusot.cargo_creusot_version \
        "$(printf '%s\n' "$versions" | awk '/^cargo-creusot /{print $2}')" \
        "cargo-creusot"
    expect_pin creusot.rust_toolchain \
        "$(printf '%s\n' "$versions" | awk '/^Rust toolchain /{print $3}')" \
        "Creusot Rust toolchain"
    expect_pin creusot.why3.why3 \
        "$(printf '%s\n' "$versions" | awk '/^Why3 platform/{print $NF}')" \
        "Why3"
    expect_pin creusot.why3.why3find \
        "$(printf '%s\n' "$versions" | awk '/^why3find /{sub(/^v/,"",$2); print $2}')" \
        "why3find"
    for prover in alt-ergo z3 cvc4 cvc5; do
        key="creusot.provers.${prover//-/_}"
        expect_pin "$key" \
            "$(printf '%s\n' "$versions" | awk -v p="$prover" '$1==p{print $2}')" \
            "$prover"
    done
fi

say "Creusot replay and cache format"
cache_pin="$(pin creusot.why3.cache_format)"
if [[ -f "$REPO_ROOT/.why3find/version" ]]; then
    observed="$(cat "$REPO_ROOT/.why3find/version")"
    if [[ -n "$cache_pin" && "$cache_pin" != "$observed" ]]; then
        die "why3find cache format mismatch: pinned '$cache_pin', found '$observed'"
    fi
    info "cache format: $observed"
else
    note_gap "no .why3find/version; the tracked prover cache is missing"
fi

say "Creusot contract library (T-ENV-1)"
# `creusot-std` is declared as a crates.io dependency but must resolve to the
# pinned Creusot checkout through a `[patch.crates-io]` entry. A clean
# checkout on another machine does not inherit that patch, so its absence is
# reported rather than assumed.
if [[ "$(pin creusot.contract_library.patch_required)" == "true" ]]; then
    resolved="$(cargo metadata --format-version 1 --quiet 2>/dev/null | python3 -c '
import json, sys
meta = json.load(sys.stdin)
for package in meta["packages"]:
    if package["name"] == "creusot-std":
        print(package["manifest_path"] if package.get("source") is None else "registry")
        break
else:
    print("absent")
')"
    case "$resolved" in
        absent)   note_gap "creusot-std is not in the dependency graph" ;;
        registry) die "creusot-std resolves to the registry; the [patch.crates-io] redirect to the pinned checkout is missing" ;;
        *)        info "creusot-std resolves to: $resolved" ;;
    esac
fi

say "Creusot checkout commit"
checkout="$(pin creusot.checkout_path)"
commit_pin="$(pin creusot.commit)"
if [[ -n "$checkout" && -d "$checkout/.git" ]]; then
    observed="$(git -C "$checkout" rev-parse HEAD)"
    [[ "$observed" == "$commit_pin" ]] \
        || die "Creusot checkout is $observed, pinned $commit_pin"
    info "Creusot commit: $observed"
    if [[ -n "$(git -C "$checkout" status --porcelain)" ]]; then
        warn "the Creusot checkout has local modifications; the pinned commit does not describe it"
    fi
else
    note_gap "Creusot checkout not found at '${checkout:-<unset>}'; cannot confirm commit $commit_pin"
fi

say "Reproducibility checksums"
for entry in \
    "Cargo.lock:reproducibility.cargo_lock_sha256" \
    "why3find.json:reproducibility.why3find_json_sha256"
do
    file="${entry%%:*}"
    key="${entry#*:}"
    expected="$(pin "$key")"
    observed="$(sha256_of "$REPO_ROOT/$file")"
    if [[ -z "$expected" ]]; then
        note_gap "no checksum pinned for $file (observed $observed)"
    elif [[ "$expected" != "$observed" ]]; then
        die "$file checksum mismatch:
      pinned   $expected
      observed $observed
    If the change is intended, update $key in tools/toolchains.toml in the
    same commit as the change, and say why in the commit message."
    else
        info "$file: $observed"
    fi
done

say "Verus"
if [[ "$(pin meta.verus_status)" != "observed" ]]; then
    note_gap "Verus pins are unpopulated; ci/prove-driver.sh will refuse to run"
else
    need_cmd verus
    expect_pin verus.release "$(verus --version | head -1)" "verus"
fi

say "Runtime and deployment"
if [[ "$(pin meta.runtime_status)" != "observed" ]]; then
    note_gap "runtime pins are unpopulated; ci/build-rpi4.sh and ci/test-hil.sh will refuse to run"
fi

say "Open reproducibility items"
grep -E '^id = "REPRO-' "$PINS" | sed 's/^id = /    /' || true

if (( status == 0 )); then
    say "bootstrap: all applicable pins resolved and matched"
else
    warn "bootstrap: pins resolved for the sections that are populated"
    warn "unpopulated sections remain; a release requires --require-all to pass"
fi
exit "$status"
