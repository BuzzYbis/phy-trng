#!/usr/bin/env bash
# Verus proof run with the expected function and obligation coverage.
#
# Usage: ci/prove-driver.sh
#
# Until the Verus pins are populated and the driver packages exist, this exits
# 78 (unconfigured). That is not a pass, and nothing here suppresses a
# verifier error to make it look like one.

source "$(dirname "$0")/lib.sh"

readonly DRIVER="$REPO_ROOT/crates/imx296-driver"

say "Checking preconditions"

if [[ "$(pin meta.verus_status)" != "observed" ]]; then
    unconfigured "Verus pins are unpopulated.
    Populate the [verus] section of tools/toolchains.toml from a successful
    compatibility check: release, archive checksum, Rust toolchain, matching
    vstd and Z3, and whether the distribution provides cargo-verus.
    See proofs/verus/coverage.md and section 6.2 of
    doc/REPOSITORY_AND_PROOF_SETUP.md."
fi

command -v verus >/dev/null 2>&1 || unconfigured "verus is not on PATH"

if [[ ! -d "$DRIVER" ]]; then
    unconfigured "crates/imx296-driver does not exist yet.
    The package is created at bring-up, together with its first proof; see
    doc/REPOSITORY_STATUS.md. An empty placeholder crate is not created."
fi

out="$(log_dir prove-driver)"

say "Recording tool identity"
verus --version | tee "$out/tool-identity.txt" | sed 's/^/    | /'
expect_pin verus.release "$(verus --version | head -1)" "verus"

say "Smoke cases"
"$REPO_ROOT/ci/smoke-proofs.sh" --verus

say "Verifying the driver"
# The invocation depends on what the pinned release supports. A dependency-free
# skeleton can use the direct library entry point; once the driver depends on
# driver-api it cannot, because ordinary `--extern` metadata imports do not
# carry proof contracts. Whichever form is used must be qualified against the
# pinned release before it is committed here.
if [[ "$(pin verus.cargo_verus_available)" == "true" ]]; then
    cargo verus verify -p imx296-driver 2>&1 | tee "$out/verus.log"
    verifier_status=${PIPESTATUS[0]}
else
    verus --crate-type=lib "$DRIVER/src/lib.rs" 2>&1 | tee "$out/verus.log"
    verifier_status=${PIPESTATUS[0]}
    warn "using the dependency-free entry point; this stops being sufficient"
    warn "as soon as the driver depends on driver-api"
fi

(( verifier_status == 0 )) || die "verus exited $verifier_status; see $out/verus.log"

say "Screening the proof log"
grep -Eq 'verification results:: *[1-9][0-9]* verified' "$out/verus.log" \
    || die "no function was reported verified; parsing is not verifying"
if grep -Eq '[1-9][0-9]* (errors|error)' "$out/verus.log"; then
    die "the proof log reports verification errors"
fi

say "Trusted-boundary check"
# An external body trusts its specification instead of proving the
# implementation, so a change in their number is a TCB change.
"$REPO_ROOT/ci/check-trust.sh"

write_provenance "$out/provenance.toml" prove-driver
say "prove-driver: passed"
