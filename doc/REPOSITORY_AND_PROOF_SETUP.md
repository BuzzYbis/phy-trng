# Repository organisation and proof-system setup

Status: proposed implementation policy. Documentation checked on 2026-09-17.

> *Live-state pointer:* See [`REPOSITORY_STATUS.md`](REPOSITORY_STATUS.md) for
> the live applied state, current workspace members, and reconciliation with
> [`ARCHITECTURE.md`](ARCHITECTURE.md) (including Verus scope,
> RPi4/IMX296/`A-DMA-1`, and the 2-PD → 7-PD staging path).

This document describes the intended repository, not an already completed migration. The existing source tree and its installed Creusot version have not been inspected. Preserve the current package name, public API, tests and proof baseline when applying it. Commands containing uppercase placeholders require values selected during bootstrap; they are not a tested version matrix.

## 1. Decisions

- Keep one repository. Start with one Cargo workspace containing the existing library and separate driver/runtime packages.
- Keep the existing library at the root initially; do not combine relocation with a verifier upgrade.
- Use Creusot for the entropy-processing library and Verus for the camera-driver protocol and buffer logic.
- Keep volatile accesses, architecture-specific barriers/cache operations and seL4 bindings behind small, documented trust boundaries.
- Compile the same executable implementations that are checked by the verifiers. Proof-only lemmas may live in separate modules; duplicate production algorithms may not.
- Bring up the Rust driver before completing its proofs, but establish interfaces, invariants and a small proof smoke test immediately.
- A crate is a build unit, not a seL4 protection domain. Runtime isolation is defined by the Microkit system description.
- No camera-frame disk-storage subsystem is required initially. Boot media is separate from experiment storage.

The hardware target is Raspberry Pi 4 with a colour IMX296 and a fixed RAW10 capture profile, targeting 60 fps. Treat successful mode programming, actual frame cadence and host-memory packing as separate validation obligations.

## 2. Repository layout

Paths below are relative to the repository root. Create new packages only when their responsibility is needed; avoid empty placeholder crates.

| Path | Responsibility | Proof/build owner |
| --- | --- | --- |
| `Cargo.toml`, `Cargo.lock` | Root package and workspace membership; resolved dependencies | Repository |
| `src/`, `tests/` | Existing entropy library and tests, preserved initially | Creusot |
| `why3find.json` | Existing/generated Creusot prover configuration | Creusot |
| `crates/driver-api/` | Plain `no_std` transport types, numeric tags and protocol constants | Shared interface review |
| `crates/imx296-driver/` | IMX296 control, Unicam capture protocol, buffer lifecycle | Verus |
| `crates/camera-mmio/` | Minimal volatile primitives and platform memory operations | Audited trusted code |
| `crates/sel4-camera-pd/` | Camera PD entry points and driver integration | seL4 build + integration |
| `crates/sel4-entropy-pd/` | Frame acceptance and invocation of the existing library | seL4 build + integration |
| `system/rpi4/` | Microkit system description, physical mappings, IRQ assignments and image recipe | System configuration |
| `proofs/contracts/` | Normative cross-component contracts and requirement IDs | Both proof domains |
| `proofs/creusot/` | Proof coverage inventory and reviewed auxiliary material | Creusot |
| `proofs/verus/` | Proof coverage inventory and reviewed auxiliary material | Verus |
| `proofs/tcb.md` | Every trusted primitive, assumption and justification | Assurance review |
| `proofs/smoke/` | Small positive and expected-failure verification cases | Both tools |
| `tools/toolchains.toml` | Exact verifier/compiler/solver/SDK pins | Build owner |
| `ci/` | Explicit bootstrap, verification, build and test entry points | CI |
| `tests/hil/` | Board tests and fault-injection procedures | Hardware validation |
| `artifacts/` | Generated logs, proof summaries, images and provenance; ignored by Git | CI outputs |

Do not force generated Creusot files into `proofs/creusot/`: allow the pinned tool's normal output paths, such as `verif/`. Preserve any existing replay/session files until their regeneration policy is established.

### Workspace manifest

Append this to the existing root manifest once the listed packages exist. Preserve the existing `[package]`, dependencies and edition. Retain an existing resolver choice; `2` below is a conservative example, not a mandated downgrade.

```toml
[workspace]
resolver = "2"
members = [
    ".",
    "crates/driver-api",
    "crates/imx296-driver",
    "crates/camera-mmio",
    "crates/sel4-camera-pd",
    "crates/sel4-entropy-pd",
]
default-members = [".", "crates/driver-api"]
```

`default-members` selects default build targets; it is not a verifier or dependency-resolution firewall. A workspace shares its lockfile and normally its output directory. Dependencies of selected packages still participate. Root-only settings include Cargo profiles and patches. [Cargo workspace reference](https://doc.rust-lang.org/cargo/reference/workspaces.html)

Keep the entropy library independent of Verus and hardware packages. The camera driver must not depend on the Creusot library. Each PD executable depends on its own implementation and `driver-api`. The system image recipe assembles the PD binaries; no additional monolithic `ptrng-system` crate is required merely to link them together.

## 3. Driver internals

Initially use modules inside `imx296-driver`, rather than a crate per module:

| Module | Scope |
| --- | --- |
| `registers` | Register offsets, bit masks, permitted operations and field encoding |
| `sensor` | IMX296 I2C transactions, configuration and sensor state |
| `unicam` | Receiver configuration and interrupt-event interpretation |
| `buffers` | Buffer identities, address translation, sizes and ownership |
| `capture` | Capture state machine, publication and restart epochs |
| `faults` | Error classification, timeout policy and quarantine |
| `spec` | Device model, invariants and proof lemmas |

Use fixed-capacity data structures, bounded retries and explicit state transitions. Keep hardware-facing addresses distinct from CPU virtual addresses. Use `no_std` for deployable libraries; host mocks and tests may use `std`. Validate the existing library's dependency closure for `no_std` before claiming it can run in a PD.

Keep all direct MMIO and architecture assembly in the audited layer. Generic register read-modify-write is not valid for every register: model write-one-to-clear, read-side effects, reserved bits and autonomous hardware changes explicitly.

## 4. Frame handoff contract

`driver-api` is shared executable vocabulary, not a shared theorem prover. Put the normative protocol in `proofs/contracts/frame-handoff.md`, with stable requirement IDs mirrored in both proof domains.

Do not exchange a producer virtual pointer as the frame address. Use a buffer ID plus an offset into a predefined shared region. Each PD resolves that description through its own mapping.

Use fixed-width fields for protocol version, buffer ID, generation, capture epoch, sequence, payload length, stride, dimensions, packing, Bayer order and status. Specify byte order and offsets for serialized descriptors. `repr(C)` alone does not define a portable wire format; raw integer tags must be validated before conversion into Rust enums. Do not publish padding bytes or uninitialised data.

Required obligations:

1. Bounds: the identified range fits the approved buffer, with checked arithmetic.
2. Layout: payload length and stride agree with the configured in-memory format. CSI-2 RAW10 on the wire does not imply tightly packed RAW10 in RAM.
3. Ownership: the device is no longer writing the published buffer; the producer cannot requeue it until the consumer releases it.
4. Visibility: required cache maintenance and ordering precede publication and consumption.
5. Identity: generation and epoch reject stale descriptors and releases. Define restart and integer-exhaustion behaviour; sequence numbers alone do not prove physical freshness.
6. Completion: publication follows a valid completion event in the hardware model, with no relevant capture error.
7. Failure: errors prevent affected frames entering the entropy pipeline. Frames already published, reset races and outstanding DMA writes have explicit policies.

Suggested lifecycle: `Free → DeviceOwned → Ready → ConsumerOwned → Free`. Faulted buffers enter `Quarantined`; reset does not make them reusable until DMA quiescence is established.

A `FrameLease`-style API should bound the consumer's access lifetime. Do not create ordinary Rust references into a region while hardware may mutate it in a way incompatible with their guarantees.

The consumer validates descriptors before establishing its processing preconditions. Validation cannot independently establish that DMA really stopped; that depends on the producer protocol, mappings and hardware assumptions. Reviews must show that Verus guarantees imply Creusot preconditions. There is no automatic proof transfer between the tools.

## 5. What is proved and what is trusted

| Claim | Evidence required |
| --- | --- |
| Library obeys arithmetic and algorithm contracts | Creusot proof results for identified functions |
| Driver obeys its device/ownership model | Verus proof results for identified functions |
| MMIO primitives satisfy their contracts | Manual audit, target semantics and hardware tests |
| DMA is confined during correct operation | Address/bounds proofs plus explicit hardware assumptions |
| DMA remains confined despite faulty hardware/compromised driver | Separate hardware isolation argument; not implied by a PD |
| Integration preserves the handoff contract | Mapping review, protocol reasoning and integration tests |
| Samples have a justified entropy bound | Separate physical/statistical evidence; not a driver proof |

Volatile accesses are not atomic synchronization and do not replace DMA cache maintenance or device ordering. [Rust volatile semantics](https://doc.rust-lang.org/std/ptr/fn.read_volatile.html)

Verus external bodies trust their specifications rather than prove the implementations. Keep these small and list every occurrence in `proofs/tcb.md`; do not hide complete driver routines behind them. [Verus external-body semantics](https://verus-lang.github.io/verus/guide/reference-attributes.html)

Do not claim binary-level verification or unconditional seL4 isolation. Record compiler/linker assumptions, actual kernel configuration and boot/firmware dependencies. Kernel proof coverage and board support are different questions. [seL4 verification scope](https://sel4.systems/Verification/)

## 6. Toolchain bootstrap and pinning

Use a clean development environment with Git, Rustup/Cargo, a native C/C++ build environment, curl and Opam. A Linux CI environment is the reference; developer machines may differ. Installation below executes upstream build/install scripts: review them and use project-specific environments.

First record the existing successful library build and proof commands. Do not upgrade Creusot merely to add the driver. Capture these pins in `tools/toolchains.toml`:

| Pin | Record |
| --- | --- |
| Creusot | Release/full commit, required Rust, contract-library revision, Why3/Why3find and solver versions |
| Verus | Release/full commit, Rust, matching vstd and Z3 |
| Runtime | Rust target/toolchain, seL4 Rust bindings revision, Microkit SDK, kernel/configuration and linker |
| Reproducibility | Archive checksums, host/container identity and Cargo lockfile hash |

No floating `latest`, branch-only or wildcard versions in release CI. Version numbers must be populated by a successful compatibility check, not guessed from these examples.

Use separate build output locations for normal builds, Creusot and Verus. Do not globally set `RUSTC_WRAPPER` or force a seL4 build target in the root Cargo configuration. Member-level `rust-toolchain.toml` files do not switch compilers automatically when building a member from the workspace root: CI must select its tools explicitly.

### 6.1 Creusot and Why3

For a new environment, obtain the revision matching the existing library. Run in a tools checkout outside the project:

```sh
git clone https://github.com/creusot-rs/creusot creusot-tool
cd creusot-tool
git checkout --detach CREUSOT_COMMIT
./INSTALL
cargo creusot --help
```

Replace `CREUSOT_COMMIT` before running. The upstream installer configures Why3/Why3find and provers; keep the associated contract-library version aligned. Development revisions can require local Cargo patches, which must be recorded rather than silently inherited from a developer's home configuration. [Creusot installation](https://guide.creusot.rs/installation.html)

Since the library already uses Creusot, do not run `init` over it without reviewing the changes. For a clean scratch smoke project, outside the workspace:

```sh
cargo creusot new creusot-smoke
cd creusot-smoke
cargo creusot
```

Preserve the generated example and config. Change its postcondition to an incorrect one and confirm proof failure, then restore it. This verifies both the success and failure paths.

For the existing root package, run the established command first. With the current documented CLI, `cargo creusot` compiles and proves, whereas `--only=coma` only translates and `--only=prove` only runs proofs. Never count translation-only success as proof completion. [Creusot quick start](https://guide.creusot.rs/print.html)

Use explicit package selection in mixed-workspace CI. Check the pinned `cargo creusot --help` for Cargo-argument forwarding; releases differ. Where trailing Cargo arguments are supported, the intended invocation is:

```sh
cargo creusot -- -p ACTUAL_ROOT_PACKAGE --lib
```

Validate this against the pinned release before committing `ci/prove-core.sh`. Also verify proof search covers only freshly generated outputs for the selected package; package selection alone does not justify reusing stale proof directories.

### 6.2 Verus and Z3

Choose a pinned weekly release and the archive for the developer/CI host. Download it from the official release page, record its checksum, verify the archive and extract it into an isolated tools directory. Run its `verus` executable and install the Rust toolchain it requests. Keep the distribution's matching vstd and solver configuration. [Verus installation](https://github.com/verus-lang/verus/blob/main/INSTALL.md)

Create `proofs/smoke/verus_smoke.rs` with this small standalone example:

```rust
use vstd::prelude::*;

verus! {
    pub fn increment(x: u32) -> (result: u32)
        requires x < u32::MAX,
        ensures result == x + 1,
    {
        x + 1
    }
}

fn main() {}
```

With the pinned executable on PATH:

```sh
verus --version
verus proofs/smoke/verus_smoke.rs
```

Check that the function is actually verified, not merely parsed. An expected-failure companion changes the postcondition to `result == x`; the CI harness must require rejection specifically for that obligation, not accept an unrelated compiler error as success.

For a dependency-free driver skeleton using bundled vstd, the direct library entry point is:

```sh
verus --crate-type=lib crates/imx296-driver/src/lib.rs
```

This is not sufficient once external package dependencies are added. Use the pinned release's Cargo integration or explicit dependency/proof-metadata imports. Do not assume ordinary `--extern` metadata imports proof contracts. [Verus build instructions](https://github.com/verus-lang/verus/blob/main/BUILD.md)

If the selected distribution provides `cargo-verus`, inspect:

```sh
cargo verus --help
cargo verus verify --help
```

If that release supports the `verify` subcommand and package selection, qualify and record:

```sh
cargo verus verify -p imx296-driver
```

Pin the release's matching vstd dependency and crate opt-in metadata according to its documentation. The exact manifest integration is a bootstrap deliverable, not an assumed property of any Rust package. Do not replace a failed integration by marking the whole driver external.

### 6.3 Mandatory compatibility experiment

Before writing substantial driver code, demonstrate all of the following:

1. The existing library still passes its tests and Creusot proofs.
2. Verus verifies a small driver function using a type from `driver-api` with an explicit model where needed.
3. Ordinary executable builds erase proof-only material correctly.
4. Both PD dependency graphs cross-compile to the selected AArch64 seL4 target with `no_std` requirements satisfied.
5. The Microkit recipe assembles those independently built binaries into a bootable image.
6. Neither proof job loads the other tool's annotation crates as part of its verified implementation graph.

Verus documents partial multi-crate support; do not treat a mixed-verifier workspace as prevalidated. [Verus supported features](https://verus-lang.github.io/verus/guide/features.html)

If toolchain or lockfile incompatibilities prevent this, keep one repository but split into explicitly excluded Cargo workspaces: core, driver and deployment. Give each its own lockfile and run scripts in its own directory. Share only the plain protocol package/source as an ordinary dependency, with explicit workspace ownership. Separate PD executables avoid linking Rust rlibs built by incompatible compiler versions.

## 7. seL4 deployment setup

Install a pinned Microkit SDK and matching Rust seL4 bindings/examples. Select the Pi 4 board configuration matching installed RAM; copy the build pattern from that pinned example rather than guessing a generic bare-metal Rust target. The system description must assign MMIO pages, IRQs, DMA regions and shared buffers explicitly. [Microkit manual](https://docs.sel4.systems/projects/microkit/manual/latest/)

Put the concrete, successfully tested recipe in `ci/build-rpi4.sh`. Initially boot a trivial PD before adding camera hardware access. Then validate I2C, sensor configuration, receiver setup and capture in separate steps. Camera and entropy PDs exchange messages and buffer IDs, not direct Rust calls across address spaces.

No Isabelle, Rocq or Pancake installation is required for the selected application proof approach. Reproducing kernel proofs would be a separate task with its own supported configuration and pinned proof repository.

## 8. CI contracts

The following script names are proposed repository interfaces; this Markdown file does not create or test them.

| Entry point | Required behaviour |
| --- | --- |
| `ci/bootstrap-proofs.sh` | Resolve recorded pins, validate checksums and report exact tool identities |
| `ci/test-host.sh` | Test core and mockable driver behaviour with appropriate compilers |
| `ci/prove-core.sh` | Fresh Creusot translation and all in-scope obligations discharged |
| `ci/prove-driver.sh` | Verus proof run with expected function/obligation coverage |
| `ci/check-trust.sh` | Compare external bodies, assumed specs and unsafe boundaries with reviewed inventory |
| `ci/build-rpi4.sh` | Build PDs and image with locked deployment dependencies |
| `ci/test-hil.sh` | Explicit board selection, capture and fault-injection checks |

Independent proof jobs may run in parallel. A release requires all applicable gates, including integration and hardware results. Proof logs must record source commit, dirty-state status, tool/solver identities, target assumptions, enabled features and trusted exceptions. Unexpected coverage decreases, skipped goals, timeouts and unproved goals fail the proof gate. Never convert verifier failure into success with shell error suppression.

Keep proof jobs and production builds aligned on executable features. A host proof is insufficient for target-specific branches unless those branches are separately covered or explicitly trusted. Record integer-width, layout and memory-ordering assumptions.

## 9. Incremental proof plan

1. Bootstrap: preserve current proofs; pass both smoke tests and the compatibility experiment.
2. Bring-up: implement fixed-mode capture in Rust with mocks and an explicit unverified-function inventory.
3. Arithmetic: prove address ranges, stride/length calculations and register field encoding.
4. Protocol: prove legal sensor/receiver transitions and handling of modelled hardware events.
5. Ownership: prove buffer handoff, generation/epoch handling and safe reset/quarantine behaviour.
6. Composition review: reconcile the producer contract, consumer validation and trusted memory-access adapters.
7. Release evidence: reproduce proofs, target build and hardware tests from pinned inputs.

Do not postpone the first representative proof until the driver is complete. Discovering unsupported language features or an unsuitable ownership model early is substantially cheaper than rewriting the full driver.

## 10. Completion checklist

- [ ] Existing package identity/API and proof baseline preserved.
- [ ] Workspace membership and dependency directions enforced.
- [ ] Every toolchain pin and artifact checksum populated.
- [ ] Creusot contract library and verifier revisions match.
- [ ] Verus/vstd/Z3 revisions match.
- [ ] Positive and negative proof smoke tests pass their expected outcomes.
- [ ] Both target PD binaries build using the intended executable implementations.
- [ ] Frame protocol specifies layout, ownership, visibility, restart and error handling.
- [ ] Every trusted function and hardware assumption has an owner and justification.
- [ ] Formal source-code properties are distinguished from hardware assumptions, entropy evidence and certification claims.

Acceptance language: “The listed components satisfy their specified software contracts under the enumerated platform, hardware and toolchain assumptions.” Do not shorten this to “the entire TRNG is formally verified.”
