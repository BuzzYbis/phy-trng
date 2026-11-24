#!/usr/bin/env bash
# Build the protection-domain binaries and the bootable image with locked
# deployment dependencies.
#
# Usage: ci/build-rpi4.sh
#
# This script must hold the concrete, successfully tested recipe. It is not
# written from a guess: bring-up order is a trivial protection domain first,
# then I2C, then sensor configuration, then receiver setup, then capture, each
# validated separately. Until that has happened on hardware, this exits 78.

source "$(dirname "$0")/lib.sh"

say "Checking preconditions"

if [[ "$(pin meta.runtime_status)" != "observed" ]]; then
    unconfigured "runtime pins are unpopulated.
    Populate the [runtime] section of tools/toolchains.toml from a working
    build: Rust toolchain and AArch64 target triple, seL4 Rust bindings
    revision, Microkit SDK version and checksum, the Pi 4 board configuration
    matching the installed RAM, the kernel configuration and the linker.
    Copy the build pattern from the pinned Microkit example rather than
    guessing a generic bare-metal target."
fi

missing=()
for path in \
    crates/imx296-driver \
    crates/camera-mmio \
    crates/sel4-camera-pd \
    crates/sel4-entropy-pd
do
    [[ -d "$REPO_ROOT/$path" ]] || missing+=("$path")
done
if (( ${#missing[@]} > 0 )); then
    unconfigured "these packages do not exist yet: ${missing[*]}
    They are created when their responsibility is needed; see
    doc/REPOSITORY_STATUS.md. Empty placeholder crates are not created."
fi

if [[ ! -f "$REPO_ROOT/system/rpi4/ptrng.system" ]]; then
    unconfigured "system/rpi4/ptrng.system does not exist.
    The Microkit system description must assign MMIO pages, IRQs, DMA regions
    and shared buffers explicitly; see system/rpi4/README.md."
fi

die "reached the build step with every precondition satisfied, but the recipe
    has not been written. Put the concrete, tested recipe here rather than a
    plausible one: separate build output locations for normal, Creusot and
    Verus builds, explicit target selection in CI rather than a member-level
    rust-toolchain.toml, and no globally set RUSTC_WRAPPER."
