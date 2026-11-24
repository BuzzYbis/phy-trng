#!/usr/bin/env bash
# Test core and mockable driver behaviour with appropriate compilers.
#
# Usage: ci/test-host.sh [--no-fmt]
#
# Packages are selected explicitly. `default-members` is a build-target
# convenience, not a dependency-resolution firewall, so CI never relies on it.

source "$(dirname "$0")/lib.sh"

RUN_FMT=1
for arg in "$@"; do
    case "$arg" in
        --no-fmt) RUN_FMT=0 ;;
        *) die "unknown argument: $arg" ;;
    esac
done

need_cmd cargo
cd "$REPO_ROOT"

if (( RUN_FMT )); then
    say "Formatting"
    # The rustfmt configuration uses unstable options, so formatting is
    # checked with the nightly toolchain regardless of the build toolchain.
    cargo +nightly fmt --all -- --check
    info "formatting clean"
fi

say "Lints"
cargo clippy --workspace --all-targets --all-features -- -D warnings
info "clippy clean with warnings denied"

say "Host tests"
cargo test --workspace --all-features

say "Release build"
cargo build --workspace --release --all-features
info "release build succeeded"

say "Proof-material erasure (T-BUILD-2)"
# An ordinary build is not compiled with --cfg creusot, so every contract
# attribute must expand to nothing: what runs is what was checked. This is
# asserted rather than assumed, because a contract that survived into the
# executable would mean the proof and the program had diverged.
toolchain="$(pin creusot.rust_toolchain)"
if [[ -z "$toolchain" ]]; then
    warn "creusot.rust_toolchain is unpinned; skipping the erasure check"
elif ! rustup toolchain list 2>/dev/null | grep -q "^${toolchain}-"; then
    warn "$toolchain is not installed; skipping the erasure check"
else
    expanded="$(mktemp)"
    trap 'rm -f "$expanded"' EXIT
    cargo "+$toolchain" rustc -p phy-trng --lib --profile release -- \
        -Zunpretty=expanded > "$expanded" 2>/dev/null
    if grep -Eq '#\[(requires|ensures|invariant|variant|ghost|logic|predicate)' \
            "$expanded"; then
        grep -En '#\[(requires|ensures|invariant|variant|ghost|logic|predicate)' \
            "$expanded" >&2
        die "a contract attribute survived macro expansion in an ordinary build"
    fi
    if grep -Eqi 'pearlite|creusot::' "$expanded"; then
        grep -Eni 'pearlite|creusot::' "$expanded" >&2
        die "proof-only material survived macro expansion in an ordinary build"
    fi
    info "contract attributes expand to nothing outside cfg(creusot)"
fi

say "test-host: passed"
