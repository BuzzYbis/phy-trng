# Trusted computing base

Status: live inventory. Revision 1, 2026-09-17.

Every trusted primitive, assumed specification and hardware assumption that a
claim in this repository rests on. An entry here is **not** a discharged
proof; it is something a reviewer must accept on other grounds.

`ci/check-trust.sh` compares the trust markers actually present in the tracked
Rust sources against [`tcb-inventory.tsv`](tcb-inventory.tsv) and fails on any
undeclared occurrence. That check covers markers in code. It does not and
cannot detect an assumption that exists only in prose, so the narrative
entries below are maintained by review.

## 1. Verification-tool trust

| ID | Assumption | Justification | Owner |
| --- | --- | --- | --- |
| T-TOOL-1 | Creusot's translation from Rust to Coma preserves the semantics of the compiled program. | Upstream tool trust. Mitigated by pinning the exact commit (`tools/toolchains.toml`) and by replaying proofs from a clean checkout. | Build owner |
| T-TOOL-2 | Why3, Why3find and the four selected solvers are sound. | Upstream tool trust. Four independent solvers are configured, which reduces but does not remove the exposure. | Build owner |
| T-TOOL-3 | The `creusot-std` contracts for `core` and `std` items are correct. They are *specifications of* the standard library, not proofs about it. | Upstream contract-library trust, pinned to the same Creusot commit. Each newly relied-upon contract should be read, not assumed. | Creusot owner |
| T-TOOL-4 | Verus, its `vstd` and its bundled solver are sound. | Not yet applicable: no Verus installation is pinned. Becomes active when `[verus]` in `tools/toolchains.toml` is populated. | Build owner |

## 2. Build and language trust

| ID | Assumption | Justification | Owner |
| --- | --- | --- | --- |
| T-BUILD-1 | `rustc` and LLVM compile the verified source into a program with the semantics the proof assumed. | Compiler trust. No binary-level verification is claimed. The exact compiler identities are recorded in `tools/toolchains.toml`. | Build owner |
| T-BUILD-2 | Proof-only material is erased from ordinary executable builds, so what runs is what was checked. | Checked by item 3 of the compatibility experiment. | Build owner |
| T-BUILD-3 | `overflow-checks = true` in the release profile, `panic = "abort"`, and the absence of an allocator are preserved by the final link. | Root profile settings apply to every workspace member. Final-binary allocator and panic-path checks are not yet implemented. | Build owner |
| T-ENV-1 | The `[patch.crates-io]` redirect that resolves `creusot-std` to the pinned Creusot checkout is present and points at that commit. | Recorded as `REPRO-2` in `tools/toolchains.toml`; checked by `ci/bootstrap-proofs.sh`. A clean checkout on another machine does not inherit it. | Build owner |

## 3. Code-level trust markers

Scanned markers: `unsafe`, `#[trusted]`, `external_body`,
`#[verifier::external*]`, `assume!`, `admit!`, `sorry`, `#[creusot::*]`.

**Current count: zero.** `crates/driver-api` sets `#![forbid(unsafe_code)]`,
and `src/lib.rs` contains no trust marker. The declared inventory in
`tcb-inventory.tsv` is therefore empty, and any new occurrence fails
`ci/check-trust.sh` until it is declared here with a justification.

Rules for adding an entry:

- Keep each trusted body small. A complete driver routine behind
  `external_body` trusts its specification instead of proving the
  implementation, and is not acceptable.
- A Verus `external_body` function must name the specification being trusted
  and the reason the implementation cannot be verified.
- Every `unsafe` block states the invariant that makes it sound and who
  established that invariant.

## 4. Not-yet-existing trusted layers

These layers are named by `doc/REPOSITORY_AND_PROOF_SETUP.md` and will be
trusted when they exist. They are listed so that their absence is not mistaken
for their being proved.

| ID | Future assumption | Gate |
| --- | --- | --- |
| T-MMIO-1 | `camera-mmio` volatile primitives satisfy their contracts under the target's memory model. Volatile access is not atomic synchronization and does not replace DMA cache maintenance or device ordering. | Manual audit plus hardware tests |
| T-MMIO-2 | Architecture-specific barriers and cache-maintenance operations have the effect their wrappers claim on the selected Pi 4 configuration. | Manual audit plus hardware tests |
| T-DMA-1 | DMA is confined to the assigned region during correct operation. | Address and bounds proofs plus explicit hardware assumptions |
| T-DMA-2 | DMA remains confined despite faulty hardware or a compromised driver. **This does not follow from placing the driver in a protection domain.** It requires a separate hardware isolation argument. | Separate argument; M6 |
| T-SEL4-1 | The kernel configuration actually built provides the isolation the composition argument uses. Kernel proof coverage and board support are different questions, and no unconditional seL4 isolation is claimed. | M6 qualification |
| T-BOOT-1 | Boot media, firmware and bootloader do not invalidate the configuration the system description assigns. | M6 |

## 5. Physical and acquisition assumptions

These are not software properties and cannot be discharged by any verifier in
this repository. They are owned by `doc/ARCHITECTURE.md` and its argument
items, and are repeated here only so the TCB is complete.

| ID | Assumption | Where it is argued |
| --- | --- | --- |
| T-ACQ-1 | Acquisition is trusted: general stream substitution is outside the default threat model, and frame monitors are failure detectors rather than authenticity mechanisms. | `A-ACQ-1`, `B-ARG-07` |
| T-PHYS-1 | Samples have a justified entropy bound from the physical source model. This is physical and statistical evidence, never a driver or library proof. | `B-ARG-05`, `B-ARG-09` |
| T-FRESH-1 | Sequence and epoch counters order frames; physical freshness rests on the acquisition argument. | `FH-ID-3` in [`contracts/frame-handoff.md`](contracts/frame-handoff.md) |
