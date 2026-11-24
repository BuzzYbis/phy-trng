#!/usr/bin/env bash
# Shared helpers for the CI entry points. Sourced, not executed.

set -euo pipefail

# Exit-code convention:
#   0  gate passed
#   1  gate failed (a real failure: unproved goal, test failure, mismatch)
#  78  gate is unconfigured (EX_CONFIG): a required pin, tool or SDK is not
#      recorded yet. This is never a pass. A release requires every applicable
#      gate to exit 0.
readonly EX_FAIL=1
readonly EX_CONFIG=78

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly PINS="$REPO_ROOT/tools/toolchains.toml"
readonly ARTIFACTS="$REPO_ROOT/artifacts"

say()  { printf '==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '!!  %s\n' "$*" >&2; }

die() {
    printf '!!  %s\n' "$*" >&2
    exit "$EX_FAIL"
}

unconfigured() {
    printf '??  unconfigured gate: %s\n' "$*" >&2
    printf '??  this is not a pass; exiting %s\n' "$EX_CONFIG" >&2
    exit "$EX_CONFIG"
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

# pin <section.key> — prints the value from tools/toolchains.toml, or nothing
# when the key is absent or its value is the empty string.
pin() {
    awk -v want="$1" '
        /^\[/ {
            section = $0
            sub(/^\[+/, "", section)
            sub(/\]+$/, "", section)
            next
        }
        /^[A-Za-z_][A-Za-z0-9_]*[ \t]*=/ {
            key = $0
            sub(/[ \t]*=.*$/, "", key)
            gsub(/[ \t]/, "", key)
            if (section "." key != want) next
            value = $0
            sub(/^[^=]*=[ \t]*/, "", value)
            sub(/[ \t]*$/, "", value)
            gsub(/^"|"$/, "", value)
            print value
            exit
        }
    ' "$PINS"
}

# require_pin <section.key> <what> — dies when a pin is unpopulated.
require_pin() {
    local value
    value="$(pin "$1")"
    [[ -n "$value" ]] || unconfigured "$2 (tools/toolchains.toml: $1 is empty)"
    printf '%s\n' "$value"
}

# expect_pin <section.key> <actual> <label> — compares an observed identity
# with its recorded pin.
expect_pin() {
    local key="$1" actual="$2" label="$3" expected
    expected="$(pin "$key")"
    if [[ -z "$expected" ]]; then
        warn "$label: no pin recorded ($key); observed '$actual'"
        return 0
    fi
    if [[ "$expected" != "$actual" ]]; then
        die "$label mismatch: pinned '$expected', observed '$actual' ($key)"
    fi
    info "$label: $actual"
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d' ' -f1
    else
        shasum -a 256 "$1" | cut -d' ' -f1
    fi
}

# Provenance every proof log must carry.
source_commit() { git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo unknown; }

dirty_state() {
    if [[ -n "$(git -C "$REPO_ROOT" status --porcelain 2>/dev/null)" ]]; then
        echo dirty
    else
        echo clean
    fi
}

log_dir() {
    local name="$1"
    mkdir -p "$ARTIFACTS/$name"
    printf '%s\n' "$ARTIFACTS/$name"
}

write_provenance() {
    local out="$1" gate="$2"
    {
        echo "gate = \"$gate\""
        echo "recorded = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
        echo "source_commit = \"$(source_commit)\""
        echo "working_tree = \"$(dirty_state)\""
        echo "host = \"$(uname -srm)\""
        echo "cargo_lock_sha256 = \"$(sha256_of "$REPO_ROOT/Cargo.lock")\""
    } > "$out"
    info "provenance: $out"
}
