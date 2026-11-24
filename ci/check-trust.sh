#!/usr/bin/env bash
# Compare the trust markers in the repository's Rust sources with the reviewed
# inventory in proofs/tcb-inventory.tsv.
#
# Usage: ci/check-trust.sh [--print | --update]
#
#   --print    Write the observed inventory to stdout and exit.
#   --update   Overwrite the declared inventory with what is observed. This is
#              a review action: every added line needs a justification in
#              proofs/tcb.md, and the check does not verify that it has one.
#
# What this catches: an `unsafe` block, a `#[trusted]` or `external_body`
# function, an `assume!`/`admit!`, or a verifier escape hatch appearing without
# being declared. What it cannot catch: an assumption that exists only in
# prose. Those are maintained by review in proofs/tcb.md.

source "$(dirname "$0")/lib.sh"

readonly INVENTORY="$REPO_ROOT/proofs/tcb-inventory.tsv"

# marker label -> extended regular expression
readonly -a MARKERS=(
    "unsafe:(^|[^[:alnum:]_])unsafe([^[:alnum:]_]|$)"
    "trusted:#\[(creusot::)?trusted\]"
    "external_body:external_body"
    "verifier_external:#\[verifier::external"
    "assume:(^|[^[:alnum:]_])assume!"
    "admit:(^|[^[:alnum:]_])admit!"
    "sorry:(^|[^[:alnum:]_])sorry([^[:alnum:]_]|$)"
    "creusot_attr:#\[creusot::"
)

observe() {
    cd "$REPO_ROOT"
    local file entry label pattern count
    # Tracked sources plus new, not-ignored ones, so a file added in the
    # same change cannot escape the scan. Generated Coma under verif/ is
    # verifier output, not source, and is covered by the proof gate instead.
    while IFS= read -r file; do
        for entry in "${MARKERS[@]}"; do
            label="${entry%%:*}"
            pattern="${entry#*:}"
            count=$(grep -Ec "$pattern" "$file" 2>/dev/null || true)
            [[ -n "$count" && "$count" != "0" ]] || continue
            printf '%s\t%s\t%s\n' "$count" "$label" "$file"
        done
    done < <(git ls-files --cached --others --exclude-standard '*.rs' | sort -u)
}

declared() {
    grep -Ev '^[[:space:]]*(#|$)' "$INVENTORY" || true
}

case "${1-}" in
    --print)
        observe | sort -k3,3 -k2,2
        exit 0
        ;;
    --update)
        tmp="$(mktemp)"
        {
            grep -E '^[[:space:]]*#' "$INVENTORY" || true
            observe | sort -k3,3 -k2,2
        } > "$tmp"
        mv "$tmp" "$INVENTORY"
        say "inventory updated: $INVENTORY"
        warn "every added line needs a justification in proofs/tcb.md"
        exit 0
        ;;
    "") ;;
    *) die "unknown argument: $1" ;;
esac

say "Scanning Rust sources for trust markers"
observed_file="$(mktemp)"
declared_file="$(mktemp)"
trap 'rm -f "$observed_file" "$declared_file"' EXIT
observe | sort -k3,3 -k2,2 > "$observed_file"
declared | sort -k3,3 -k2,2 > "$declared_file"

observed_count=$(wc -l < "$observed_file" | tr -d ' ')
declared_count=$(wc -l < "$declared_file" | tr -d ' ')
info "observed: $observed_count marker site(s)"
info "declared: $declared_count marker site(s)"

if ! diff -u "$declared_file" "$observed_file" \
        --label "declared (proofs/tcb-inventory.tsv)" \
        --label "observed (repository sources)"; then
    warn ""
    warn "The trusted boundary does not match the reviewed inventory."
    warn "A line only present in 'observed' is an undeclared trusted"
    warn "construct: declare it in proofs/tcb-inventory.tsv and justify it in"
    warn "proofs/tcb.md, in the same commit. A line only present in"
    warn "'declared' means trusted code was removed; drop the entry and the"
    warn "justification with it."
    warn ""
    warn "An annotation never becomes a discharged proof by being declared."
    die "trusted-boundary check failed"
fi

if (( observed_count == 0 )); then
    info "no trust marker in any Rust source"
fi

say "check-trust: passed"
