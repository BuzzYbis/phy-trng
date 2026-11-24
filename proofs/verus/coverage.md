# Verus proof coverage

Status: **not yet established.** Recorded 2026-09-17.

Verus owns the camera-driver protocol and buffer logic. No Verus installation
is pinned: `[verus]` in [`tools/toolchains.toml`](../../tools/toolchains.toml)
is unpopulated, `verus` is not on the development host's `PATH`, and the
`crates/imx296-driver` and `crates/camera-mmio` packages do not exist yet.

`ci/prove-driver.sh` therefore reports an **unconfigured gate** and exits
non-zero. It does not report a pass, and no shell error suppression converts a
missing verifier into success.

## Proved functions

None.

## Planned command

To be qualified against the pinned release before it is committed as the gate
command. For a dependency-free skeleton using the bundled `vstd`:

```sh
verus --crate-type=lib crates/imx296-driver/src/lib.rs
```

That form stops being sufficient once the driver depends on
`driver-api`, because ordinary `--extern` metadata imports do not carry proof
contracts. The dependent form is the pinned release's Cargo integration, if it
provides one:

```sh
cargo verus verify -p imx296-driver
```

Whether `cargo verus` and its `verify` subcommand exist, and how the manifest
opts a crate in, is a bootstrap deliverable of the release actually selected,
not an assumed property of any Rust package. Verus documents only partial
multi-crate support, so a mixed-verifier workspace is not prevalidated.

## Planned obligations

The `FH-*` identifiers Verus is expected to discharge, from
[`../contracts/frame-handoff.md`](../contracts/frame-handoff.md):

| Identifier | Obligation | Status |
| --- | --- | --- |
| FH-OWN-1 | The device is no longer writing a published buffer | Not started |
| FH-OWN-2 | A published buffer is not requeued before release | Not started |
| FH-OWN-3 | A release matches the buffer's current occupant | Not started |
| FH-CMP-2 | `Complete` follows a valid completion event with no relevant capture error | Not started |
| FH-LAY-4 | The programmed mode produces the declared packing, stride and geometry | Not started |
| FH-ID-4 | Producer-side counter exhaustion fails closed | Not started |
| FH-FAIL-2 | Restart does not race outstanding DMA writes | Not started |
| FH-FAIL-3 | A quarantined buffer is reusable only after established quiescence | Not started |
| FH-FAIL-4 | Frames already published at fault detection have an explicit disposition | Not started |

FH-VIS-1 and FH-VIS-2 are **not** Verus obligations. They rest on the audited
primitives in `camera-mmio`; see `T-MMIO-1` and `T-MMIO-2` in
[`../tcb.md`](../tcb.md).

## Gate rules

- Every `external_body` function trusts its specification rather than proving
  its implementation. Each one is small, named in `tcb.md`, and never hides a
  complete driver routine.
- A failed Cargo integration is not worked around by marking the whole driver
  external.
- A host-only proof is insufficient for a target-specific branch unless that
  branch is separately covered or explicitly trusted.
