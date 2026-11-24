# `system/rpi4/`

Microkit system description, physical mappings, IRQ assignments and the image
recipe for the Raspberry Pi 4 reference target.

**Nothing here is built yet.** `ci/build-rpi4.sh` exits 78 (unconfigured)
until the pins in `tools/toolchains.toml` and the files below exist. A
plausible-looking system description is worse than none: it would assign real
hardware from a guess.

## What this directory must contain

| File | Contents |
| --- | --- |
| `ptrng.system` | The Microkit system description. |
| `Makefile` or a recipe invoked by `ci/build-rpi4.sh` | The image assembly, copied from the pinned Microkit example rather than a generic bare-metal Rust pattern. |
| `mappings.md` | The physical address, IRQ and DMA assignments, with the datasheet or device-tree source of each value. |

## Rules for the system description

A crate is a build unit; a protection domain is a runtime isolation boundary.
The mapping between them is defined here, not by the Cargo workspace.

- Assign MMIO pages, IRQs, DMA regions and shared buffers **explicitly**.
  Nothing is inherited by default.
- The shared frame region is the one the frame-handoff contract refers to. Its
  buffer count, buffer size and per-domain access rights are stated here, and
  the consumer's mapped size is what
  [`proofs/contracts/frame-handoff.md`](../../proofs/contracts/frame-handoff.md)
  calls the approved buffer size for `FH-BND-1`.
- The camera domain gets the device and a confined DMA region, and no
  authority to broaden a protected SMMU policy.
- Placing the driver in a protection domain does **not** confine DMA against
  faulty hardware or a compromised driver. That is `T-DMA-2` in
  [`proofs/tcb.md`](../../proofs/tcb.md) and needs a separate hardware
  isolation argument.
- Timer, fault and bootstrap support may be separate domains or trusted
  platform services. Whichever is chosen is listed in the profile, and counts
  toward the supporting TCB.

## Bring-up order

Each step is validated before the next, and each produces a recorded result:

1. Boot a trivial protection domain.
2. I2C access.
3. Sensor configuration and readback.
4. Receiver setup.
5. Capture.

Successful mode programming, actual frame cadence and host-memory packing are
three separate validation obligations, not one.

## Relationship to the architecture

`doc/ARCHITECTURE.md` section 10 names seven application protection domains
(`pd_sensor`, `pd_source`, `pd_health`, `pd_cond_drbg`, `pd_release`,
`pd_api`, `pd_fault`) with their data rights. The two domains in
`doc/REPOSITORY_AND_PROOF_SETUP.md` (`sel4-camera-pd`, `sel4-entropy-pd`) are
the bring-up subset: the camera domain corresponds to `pd_sensor`, and the
entropy domain stands in for the `pd_source` through `pd_release` chain until
those are split. The split is an M6 deliverable; see
[`doc/REPOSITORY_STATUS.md`](../../doc/REPOSITORY_STATUS.md).
