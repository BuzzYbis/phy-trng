#!/usr/bin/env bash
# Fresh Creusot translation, with every in-scope obligation discharged.
#
# Usage: ci/prove-core.sh [--no-cache] [--update-inventory]
#
#   --no-cache           Re-run the provers instead of replaying the tracked
#                        `.why3find/` cache. This rewrites the recorded
#                        timings in that cache, so the working tree comes back
#                        dirty. Use it to confirm the cache, not as the
#                        default gate.
#   --update-inventory   Rewrite the goal inventory from what was generated.
#                        A review action: an added goal needs a coverage entry
#                        in `proofs/creusot/coverage.md`, and a removed one
#                        needs its entry deleted.
#
# Never converts a verifier failure into success: each stage's exit status is
# propagated, and the proof log is additionally screened for unproved goals.
#
# Translation and proving are separate stages. `--only=coma` translates and
# `--only=prove` runs the provers; **translation-only success is never counted
# as proof completion**, which is why the coverage check sits between them and
# the screening happens only after the prove stage.

source "$(dirname "$0")/lib.sh"

NO_CACHE=0
UPDATE_INVENTORY=0
for arg in "$@"; do
    case "$arg" in
        --no-cache) NO_CACHE=1 ;;
        --update-inventory) UPDATE_INVENTORY=1 ;;
        *) die "unknown argument: $arg" ;;
    esac
done

need_cmd cargo
command -v cargo-creusot >/dev/null 2>&1 \
    || unconfigured "cargo-creusot is not on PATH"
cd "$REPO_ROOT"

# Every package Creusot owns *and that currently carries contracts*.
# Selection is explicit: `default-members` is a build-target convenience, not
# a verifier firewall.
#
# `ptrng-core` and `ptrng-spsc` are scaffolding with no contracts yet. Add
# each here when it gets its first contract, together with its `creusot-std`
# dependency, and re-run with --update-inventory.
readonly PACKAGES=(phy-trng)
readonly INVENTORY="$REPO_ROOT/proofs/creusot/goal-inventory.txt"

out="$(log_dir prove-core)"
log="$out/creusot.log"
: > "$log"

say "Recording tool identity"
cargo creusot version | tee "$out/tool-identity.txt" | sed 's/^/    | /'

say "Forcing a fresh translation"
# Removing Creusot's own build directory forces re-translation, so the proof
# run cannot silently reuse a stale Coma file. The replay files under `verif/`
# and the prover cache under `.why3find/` are preserved: they are tracked
# evidence and their regeneration policy is not settled yet.
rm -rf "$REPO_ROOT/target/creusot"
info "removed target/creusot"

baseline="$(find verif -name '*.coma' -exec shasum -a 256 {} + 2>/dev/null \
    | sort || true)"

say "Translating (stage 1 of 2 -- not a proof result)"
for package in "${PACKAGES[@]}"; do
    set +e
    cargo creusot --only=coma -- -p "$package" --lib 2>&1 | tee -a "$log"
    status=${PIPESTATUS[0]}
    set -e
    (( status == 0 )) || die "translation of $package exited $status; see $log"
    info "translated $package"
done

say "Checking goal coverage"
find verif -name '*.coma' | sort > "$out/goal-manifest.txt"
generated=$(wc -l < "$out/goal-manifest.txt" | tr -d ' ')
info "generated goals: $generated"

if (( UPDATE_INVENTORY )); then
    cp "$out/goal-manifest.txt" "$INVENTORY"
    say "inventory updated: $INVENTORY"
    warn "update proofs/creusot/coverage.md to match, in the same commit"
elif [[ ! -f "$INVENTORY" ]]; then
    die "missing $INVENTORY; create it with --update-inventory"
elif ! diff -u "$INVENTORY" "$out/goal-manifest.txt" \
        --label "inventory (proofs/creusot/goal-inventory.txt)" \
        --label "generated (verif/)"; then
    warn ""
    warn "Proof coverage does not match the reviewed inventory. A goal only"
    warn "in 'inventory' is a coverage decrease: a function lost its"
    warn "contracts, or was deleted. A goal only in 'generated' is new and"
    warn "needs a coverage entry. Re-run with --update-inventory once"
    warn "proofs/creusot/coverage.md has been updated to match."
    die "goal coverage changed"
fi

say "Proving (stage 2 of 2)"
set +e
if (( NO_CACHE )); then
    cargo creusot --only=prove --no-cache 2>&1 | tee -a "$log"
else
    cargo creusot --only=prove 2>&1 | tee -a "$log"
fi
verifier_status=${PIPESTATUS[0]}
set -e
(( verifier_status == 0 )) || die "the prove stage exited $verifier_status; see $log"

say "Screening the proof log"
# A zero exit status alone is not accepted as evidence.
if grep -Eq '✘|unproved|Timeout|Unknown|admitted|Failure' "$log"; then
    grep -En '✘|unproved|Timeout|Unknown|admitted|Failure' "$log" >&2
    die "the proof log reports an undischarged obligation"
fi
grep -Eq 'Proved \(' "$log" || die "the prove stage reported no proved goals"
info "$(grep -Eo 'Proved \([^)]*\)' "$log" | tail -1)"

current="$(find verif -name '*.coma' -exec shasum -a 256 {} + 2>/dev/null \
    | sort || true)"
if [[ -n "$baseline" && "$baseline" != "$current" ]]; then
    warn "the regenerated Coma differs from the tracked baseline."
    warn "See REPRO-1 in tools/toolchains.toml: the tracked Coma carries"
    warn "absolute spans, so it is not stable across checkout paths."
fi

write_provenance "$out/provenance.toml" prove-core
{
    printf 'packages = ['
    printf '"%s", ' "${PACKAGES[@]}"
    printf ']\n'
    echo "goals = $generated"
    echo "prover_cache_replayed = $(( 1 - NO_CACHE ))"
} >> "$out/provenance.toml"

say "prove-core: passed"
