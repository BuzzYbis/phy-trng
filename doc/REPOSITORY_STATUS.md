# Repository organisation — applied state

Status: migration record. Written 2026-09-17, when
[`REPOSITORY_AND_PROOF_SETUP.md`](REPOSITORY_AND_PROOF_SETUP.md) was applied to
the existing tree.

That document is the policy. This one records what of it is **in the tree**,
what is **deferred and why**, and how its vocabulary relates to
[`ARCHITECTURE.md`](ARCHITECTURE.md). Where the two disagree about the applied
state, this file is wrong and should be corrected.

## 0. Working rule: who writes what

**Rust implementation is written by the repository owner, by hand.**
Generation is limited to configuration, CI, and assurance documentation.

Adopted 2026-09-19, after a first pass had generated working implementations
of `driver-api`, `ptrng-core` and `ptrng-spsc` (about 1,900 lines, 103
discharged Creusot goals). Those were deliberately removed. The reason is not
that the code was wrong — it passed every gate — but that in a project whose
value is the *argument*, the author of a proof obligation has to be the person
who understands why it holds. Generated code that proves is still code nobody
has reasoned through.

What this means in practice:

| Area | Who |
| --- | --- |
| Rust implementation, contracts, tests | Owner, by hand |
| Design discussion, obligation lists, review of written code | Collaborative |
| Tool findings and feasibility probes | Either; probe code is discardable |
| `Cargo.toml`, lint configuration, workspace wiring | Generated |
| `ci/`, `makefile`, gate scripts | Generated |
| `proofs/`, `doc/`, assurance records | Generated, owner-reviewed |

The scaffolding crates keep their manifests, scope rules and obligation lists
precisely so the implementation can be written against a fixed specification
rather than invented alongside it.

## 1. Layout: applied state

| Path | Policy | State |
| --- | --- | --- |
| `Cargo.toml`, `Cargo.lock` | Root package and workspace membership | **Applied.** `[workspace]` added with `resolver = "3"` (the edition-2024 default, stated explicitly so adding a workspace changes nothing), members `.`, `crates/driver-api`, `crates/ptrng-core`, and `crates/ptrng-spsc`. `[package]`, dependencies, edition and profiles preserved. Lints moved to `[workspace.lints]` and inherited by every member, which preserves the previous effective lint set. |
| `src/`, `tests/` | Existing entropy library and tests, preserved | **Preserved in behaviour.** The `zero_slice` function body and discharged obligations are unchanged; `src/lib.rs` gained doc comments and its tests remain inline, so there is no root `tests/` directory for the library. |
| `why3find.json` | Creusot prover configuration | **Preserved unchanged.** |
| `verif/`, `.why3find/` | Creusot's own output and prover cache | **Preserved in obligations.** `verif/phy_trng_rlib/zero_slice.coma` updated span line numbers to match the doc-comment additions in `src/lib.rs`, without changing the proof obligations; not relocated into `proofs/`, per policy. |
| `crates/driver-api/` | Plain `no_std` transport types, numeric tags, protocol constants | **Scaffolding.** Manifest, scope rules, `#![no_std]`, `#![forbid(unsafe_code)]`, and crate doc comment; zero dependencies. The earlier generated implementation and 21 tests were removed under section 0; implementation will be written by hand against `proofs/contracts/frame-handoff.md`. |
| `crates/ptrng-core/` | Errors, amounts, epochs, identifiers, budget models (ARCHITECTURE §10) | **Scaffolding.** Manifest, scope rules and crate doc comment; no `creusot-std` dependency until the first contract. |
| `crates/ptrng-spsc/` | Sequential ring (ARCHITECTURE §10) | **Implemented and proved** (assistant-implemented on owner request for owner review). Standalone `SpscError` (`Display` + `Error`) and `RingBuffer<T: Copy, const N: usize>` (`new`, `new_with`, queries, `peek`, `try_push`, `pop`, `push_slice`, `pop_slice`, `clear`); 23 Creusot `.coma` goal files discharged, 10 host tests. |
| `crates/imx296-driver/` | IMX296 control, capture protocol, buffer lifecycle | **Deferred** — see section 2. |
| `crates/camera-mmio/` | Volatile primitives, platform memory operations | **Deferred.** |
| `crates/sel4-camera-pd/` | Camera PD entry points | **Deferred.** |
| `crates/sel4-entropy-pd/` | Frame acceptance, library invocation | **Deferred.** |
| `system/rpi4/` | Microkit system description, mappings, IRQs, image recipe | **Requirements written** (`README.md`). No system description: assigning real MMIO pages and IRQs from a guess is worse than assigning none. |
| `proofs/contracts/` | Normative contracts and requirement IDs | **Created.** `frame-handoff.md` defines the `FH-*` identifiers, mirrored in both coverage inventories and referenced from the source. |
| `proofs/creusot/` | Coverage inventory | **Created.** One proved function recorded. |
| `proofs/verus/` | Coverage inventory | **Created**, and records zero proved functions. |
| `proofs/tcb.md` | Trusted primitives, assumptions, justifications | **Created**, plus `tcb-inventory.tsv`, the machine-readable half checked by `ci/check-trust.sh`. |
| `proofs/smoke/` | Positive and expected-failure cases for both tools | **Created.** Creusot: both paths run and behave as specified. Verus: files in place, tool absent. |
| `tools/toolchains.toml` | Exact verifier, compiler, solver and SDK pins | **Created.** Creusot section populated from a working installation; Verus and runtime sections deliberately empty, with three recorded reproducibility defects. |
| `ci/` | Bootstrap, verification, build and test entry points | **Created**, all eight scripts. Three pass (`test-host`, `prove-core`, `check-trust`); five report an unconfigured gate (`bootstrap-proofs`, `smoke-proofs` due to missing Verus, `prove-driver`, `build-rpi4`, `test-hil`). |
| `tests/hil/` | Board tests and fault-injection procedures | **Requirements written** (`README.md`). No procedures. |
| `artifacts/` | Generated logs, proof summaries, provenance | **Created by the gates**, ignored by Git. |

Additions beyond the policy's table:

- `proofs/smoke/` gained `ci/smoke-proofs.sh` as an eighth CI entry point,
  because step 1 of the incremental proof plan needs both smoke tests as a
  distinct bootstrap step.
- `proofs/compatibility-experiment.md` records the section 6.3 experiment's
  actual outcome.
- `.clippy.toml` gained `allow-{panic,unwrap,expect}-in-tests`. The production
  bar is unchanged; the relaxation applies to test code, where a failed
  assertion is the intended outcome.

### 1.1 M0 artifacts named in the specification

`M0-architecture.md` ("Repository and artifact contracts") and G0 also name
artifacts that the setup policy does not. Their state:

| Artifact | State |
| --- | --- |
| Evidence mapping mechanism | **Applied** as tracked inventories: `proofs/creusot/coverage.md`, `proofs/creusot/goal-inventory.txt`, `proofs/tcb-inventory.tsv`. |
| Reproducible toy proof and harness | **Applied** for Creusot (`zero_slice`, `ci/prove-core.sh`). Cold/warm replay timings (M0 P4, B-VER-02) are not recorded yet. |
| Initial assumption register | `proofs/tcb.md` exists. No independent review (B-ARG-08) is recorded. |
| Probe verdicts P1–P5 | P4: Creusot expressiveness findings recorded in `proofs/creusot/coverage.md` (see section 2.1 below); the Verus half is blocked (`proofs/compatibility-experiment.md`). P1, P2, P3, P5: no verdict recorded. |
| `config/profiles.toml`, build matrix | **Created (provisional M0 baseline)** in `config/profiles.toml` (`rpi4-imx296-sel4`, `host-dev`, `portable-core-cortex-m`). Target triple and construction/backend selections remain open. |
| Benchmark JSON schema, `bench/` results, `bench/deps.toml` | Not created. |
| `evidence/arguments/` (B-ARG records) | Not created. |
| ADR directory | Not created. |
| `STATE.md` (ROADMAP session discipline) | **Created** at repository root (`STATE.md`). |

## 2. Deferred packages, and what creates them

The policy says to create a package when its responsibility is needed and to
avoid empty placeholder crates. None of the four packages below has a
responsibility yet: driver bring-up is step 2 of the incremental proof plan,
and step 1 is not finished — items 2, 4 and 5 of the compatibility experiment
are still blocked.

An empty crate would also be actively harmful here. It would appear in
`Cargo.lock` and both proof graphs, make `ci/build-rpi4.sh` report a missing
recipe instead of a missing package, and let `proofs/verus/coverage.md` list
files with no content as though coverage were merely low rather than absent.

| Package | Created when | First deliverable |
| --- | --- | --- |
| `crates/imx296-driver` | Verus is pinned and item 2 of the compatibility experiment passes | A small function verified against a `driver-api` type, before any bring-up code |
| `crates/camera-mmio` | The first real MMIO access is needed | The volatile primitive, its contract, and its entry in `proofs/tcb.md` |
| `crates/sel4-camera-pd` | The Microkit SDK is pinned and a trivial PD boots | The camera PD entry point |
| `crates/sel4-entropy-pd` | The camera PD publishes a frame | Frame acceptance, calling the existing library |

### 2.1 Entropy-pipeline crates: scaffolded early, implemented by hand

`ptrng-core` and `ptrng-spsc` were scaffolded on 2026-09-19, ahead of their
nominal M4 slot, because the reference hardware does not arrive until
mid-October and both are hardware-independent. Two things make that
legitimate rather than scope creep:

- **M0 package P4** asks for exactly this kind of work: "specify a bounded
  const-generic bulk operation and a consumer with arbitrary shared indices",
  "demonstrate checked local index snapshots and a sequential logical model",
  and produce "at least one discharged toy obligation".
- It front-loads the largest open risk: whether Creusot can express these
  models at all. `ARCHITECTURE.md` section 11 states that "M0 validates
  expressiveness before the implementation depends on a signature."

That P4 question has been **answered**, by a throwaway probe rather than by
shipped code. The findings are recorded in
[`proofs/creusot/coverage.md`](../proofs/creusot/coverage.md): const generics,
arrays, `Seq` models, `View` and `Invariant` all work; `#[logic(open)]` may not
reference private fields; a public associated constant may not expose a
private constructor; `core::fmt` is not provable; and bounded ring arithmetic
must wrap with a branch rather than `%`, or the central non-aliasing
obligation does not discharge. Those constraints are binding on the
implementation whoever writes it, which is why they are recorded outside the
code.

What was deliberately **not** scaffolded, because it would encode numbers
that do not exist yet:

| Deferred | Blocked on |
| --- | --- |
| ICA and ORA record types, receiver ledgers | G5; the health implementation defines their real content |
| Budget and credit policy | G2 derives `h_credit`; no default may stand in for it |
| Ring capacity and block dimensions | G2/G3 freeze `N_raw`, `n_int` and `w_eff`. The ring must stay generic over capacity so no dimension is baked in now |
| `ptrng-xfer`, `ptrng-sync` | Need explicit memory-ordering assumptions; M6 |

**Scope limit that must not be lost.** `ptrng-spsc` is named for its eventual
role but is specified only as a *sequential cooperative* model, which is how
`ARCHITECTURE.md` section 10 scopes it ("Sequential ring", "Sequential
FIFO/ownership proof") and what `M4-architecture.md` states ("Cross-PD
ordering and hostile mutation are M6 obligations"). A proof of the sequential
model says nothing about concurrent use, and nothing in the toolchain would
detect the difference. Concurrent transport is `ptrng-xfer`/`ptrng-sync`,
with their own assumptions.

### 2.2 Remaining deferred packages

Each is already named in the scripts that need it: `ci/build-rpi4.sh` and
`ci/prove-driver.sh` check for them and report exactly which are missing. They
are **not** listed in `Cargo.toml`'s `members`, because a member entry for a
non-existent path breaks every Cargo invocation.

## 3. Reconciling the two crate vocabularies

`ARCHITECTURE.md` section 10 and `REPOSITORY_AND_PROOF_SETUP.md` section 2
name different crate sets. They are not in conflict: they describe different
parts of the system at different milestones.

- `ARCHITECTURE.md` describes the **entropy pipeline** decomposition
  (`ptrng-core`, `ptrng-spsc`, `ptrng-health`, `ptrng-cond`, `ptrng-drbg`,
  `ptrng-release`, `ptrng-api`, ...), which is M3–M5 work, downstream of a
  frame arriving.
- `REPOSITORY_AND_PROOF_SETUP.md` describes the **acquisition** decomposition
  and the proof infrastructure, which is M0–M1 work, upstream of that.

The join is the frame handoff. Mapping:

| Setup-document name | Architecture counterpart |
| --- | --- |
| `crates/imx296-driver`, `crates/camera-mmio` | The implementation behind `ptrng-source` / `ptrng-hal-*` for this sensor |
| `crates/driver-api` | The transport vocabulary between `pd_sensor` and `pd_source` |
| `crates/sel4-camera-pd` | `pd_sensor` |
| `crates/sel4-entropy-pd` | `pd_source` through `pd_release`, before they are split into separate domains |
| `system/rpi4/` | The concrete profile for the seven application PDs and named platform services |
| `proofs/` | The evidence side of `ARCHITECTURE.md` section 11 |

`ptrng-core` and `ptrng-spsc` exist as scaffolded crates under `crates/`,
following the `ARCHITECTURE.md` section 10 naming. The root
`phy-trng` package keeps its original `zero_slice` baseline and its package
identity: the policy is explicit that relocating it must not be combined with
a verifier upgrade, so it stays at the root and becomes the facade over the
`ptrng-*` crates later. The remaining section 10 crates (`ptrng-health`,
`ptrng-cond`, `ptrng-crypto`, `ptrng-drbg`, `ptrng-release`, `ptrng-api`) are
M3-M5 work and depend on decisions frozen at G2 and G3.

Neither document is the plan of record for the other. When the entropy crates
are created, this table is updated rather than either source document being
quietly re-scoped.

### 3.1 Reconciling the v0.3 specification with the repository setup policy

1. **Dual verifier scope (Creusot + Verus).** `ARCHITECTURE.md` section 11 and
   `BENCHMARKS.md` scope Creusot for the entropy-processing library;
   `REPOSITORY_AND_PROOF_SETUP.md` adds Verus for `crates/imx296-driver` and
   manual contract bridging across `proofs/contracts/frame-handoff.md`. Verus
   bootstrap, driver proofs, and cross-tool review effort are not yet included
   in the 940 h baseline and must be folded into the G0 reforecast.
2. **Reference hardware profile.** `REPOSITORY_AND_PROOF_SETUP.md` targets
   Raspberry Pi 4 + colour Sony IMX296 (`1456×1088` native resolution, RAW10,
   targeting `60 fps` / `16.67 ms` cadence; `2.97 Mbit/s` at 1-in-32
   subsampling, 1 bit/pixel). Since v0.3.1, `ARCHITECTURE.md` section 4.2 and
   `M1-architecture.md` compute their illustrations from this profile; the
   earlier `1920×1080 @ 30 fps` example is retired. Colour Bayer CFA channel
   differences (R/G/B gain and illumination response) must be modeled
   explicitly in M2 (`B-ARG-05`) and reflected in the ROI subsampling rule.
3. **DMA confinement on Raspberry Pi 4 (BCM2711 → `A-DMA-1`).** BCM2711 lacks an
   ARM SMMU confining Unicam CSI-2 DMA. The RPi4 profile therefore cannot claim
   an independently enforced SMMU profile under `B-INT-10` and operates under
   explicit **`A-DMA-1`** (trusted DMA driver/device) unless a platform with
   protected IOMMU/SMMU is selected. `ARCHITECTURE.md` section 6.1 states which
   isolation claims remain under `A-DMA-1`, each conditional on correct camera
   DMA.
4. **Protection Domain staging (2 PDs → 7 PDs).** `sel4-camera-pd` and
   `sel4-entropy-pd` (`REPOSITORY_AND_PROOF_SETUP.md`) form the initial 2-PD
   Microkit bring-up stage; `sel4-entropy-pd` is subsequently decomposed into
   `pd_source`, `pd_health`, `pd_cond_drbg`, `pd_release`, `pd_api`, and
   `pd_fault` (plus timer/boot/scheduler services) to satisfy the 7-PD
   deployment architecture in `ARCHITECTURE.md` section 10 and M6/G6.

## 4. Open decisions

| Decision | Status |
| --- | --- |
| One Cargo workspace for core, driver and deployment | **Provisional.** Items 2, 4 and 6 of the compatibility experiment can still force the fallback: one repository, three explicitly excluded workspaces with separate lockfiles. |
| `resolver = "3"` | Applied, matching the root package's edition. Not a considered choice between resolver versions; it preserves current behaviour. |
| Whether `verif/` and `.why3find/` stay tracked | Open. They are preserved until a regeneration policy exists. `REPRO-1` in `tools/toolchains.toml` is partially mitigated (`--span-mode relative` removes developer-absolute `/Users/...` spans while preserving `proof.json` replay, though `creusot-std` spans still encode `../../creusot/creusot-std/...` via `REPRO-2`). |
| Which AArch64 target triple | Open. No bare-metal target is installed; `[runtime]` is unpopulated. |
| Whether the entropy library's dependency closure is `no_std`-clean for a PD | **Unvalidated.** Not to be claimed until item 4 passes. |
| Arithmetic and indexing lints (`arithmetic_side_effects`, `indexing_slicing`, `integer_division`) | **Disabled (decided).** Proofs cover overflow, bounds and division only in code under mandatory obligations; section 4.1 records what is left uncovered. |

### 4.1 Lint policy

The workspace lint table in `Cargo.toml` is the single place where the bar is
set, and every entry is at `warn`: the `-D warnings` in `makefile` and
`ci/test-host.sh` promotes them all to errors. Nothing has to be re-levelled
to tighten CI, and a developer can still iterate locally.

Beyond `clippy::all`, `pedantic` and `cargo`, the enabled lints mechanically
enforce constraints that `ARCHITECTURE.md` section 3 otherwise states only in
prose: `no_std` and allocation freedom (`std_instead_of_core` and siblings),
fail-closed behaviour (`todo`, `unimplemented`, `unreachable`, `exit`),
zeroization discipline (`mem_forget`), controlled unsafe (`unsafe_code`), and
documented public API (`missing_docs`).

Two lints carry the repository's justification discipline rather than
catching a bug class:

- `allow_attributes_without_reason` — every suppression states why.
  `#[expect]` is preferred over `#[allow]` because it fails once the
  suppression is no longer needed, so a stale one cannot outlive the problem
  it hid.
- `as_conversions` — `pedantic` already flags lossy casts, and lossless casts
  that have a `From` equivalent (`cast_lossless`). This lint catches every
  remaining `as`, such as enum-discriminant and pointer-to-integer casts. It
  exists to turn "this cast is fine" from
  a reader's assumption into a recorded justification. There are currently
  **zero sites** in the tree (the previous single site lived in the removed
  `driver-api` probe, where `const fn` cannot call `u16::from`).

**Intentionally disabled:**

`arithmetic_side_effects`, `indexing_slicing`, and `integer_division` are
disabled by decision. In code under mandatory Creusot or Verus obligations,
overflow, bounds and division safety are proved, so the lints would only add
noise there. The proofs do not reach everything the lints would: trusted code
(HAL/MMIO, FFI and seL4 glue, inventoried in `proofs/tcb.md`) and `std` host
tools are covered by neither, and Verus proves no function yet. That code
relies on review. Revisit the decision if a crate outside proof scope gains
non-trivial arithmetic or indexing.

`cognitive-complexity-threshold` is set to `14` in `.clippy.toml` (raised from
`10` to avoid false positives on flat, assertion-heavy test functions).

`clippy::restriction` and `clippy::nursery` are not enabled as groups: they
contain mutually contradictory and unstable lints and are not intended to be
turned on wholesale.

## 5. Completion checklist

Against section 10 of the policy document.

- [x] Existing package identity, API and proof baseline preserved.
- [x] Workspace membership and dependency directions enforced — `driver-api`
      has no dependencies, so it cannot depend on Creusot, Verus or hardware.
      Re-check once the crates carry code: the current result is trivially
      true over empty graphs.
- [ ] Every toolchain pin and artifact checksum populated — Creusot and host
      build are populated; Verus and runtime are not.
- [x] Creusot contract library and verifier revisions match — checked by
      `ci/bootstrap-proofs.sh`, including the out-of-repository patch.
- [ ] Verus, vstd and Z3 revisions match — no Verus installation.
- [ ] Positive and negative proof smoke tests pass — Creusot yes, Verus not
      run.
- [ ] Both target PD binaries build — no PD packages, no target.
- [x] Frame protocol specifies layout, ownership, visibility, restart and error
      handling — `proofs/contracts/frame-handoff.md` revision 2. **Specified
      only**: nothing is implemented, and the document says so at the top
      rather than implying otherwise.
- [x] Every trusted function and hardware assumption has an owner and a
      justification — `proofs/tcb.md`, with zero code-level trust markers
      today and an enforced inventory.
- [x] Formal source-code properties distinguished from hardware assumptions,
      entropy evidence and certification claims.

Acceptance language, unchanged: *"The listed components satisfy their specified
software contracts under the enumerated platform, hardware and toolchain
assumptions."*
