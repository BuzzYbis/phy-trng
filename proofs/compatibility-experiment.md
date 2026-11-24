# Mandatory compatibility experiment

Status: **partially satisfied.** Last re-run 2026-09-19 on
`Darwin 25.6.0 arm64`.

Since the first run, the Rust implementations were removed: the pipeline
crates are now scaffolding, to be written by hand. Items 1, 3 and 6 were
re-checked against that tree and still hold, but item 6 now holds over a
smaller graph and must be re-run as each crate gains code.

Section 6.3 of `doc/REPOSITORY_AND_PROOF_SETUP.md` requires all six items
below before substantial driver code is written. Items 1, 3 and 6 pass. Items
2, 4 and 5 are blocked on tool and hardware installations, not on a design
problem found in the experiment.

**No driver implementation may begin until items 2, 4 and 5 pass**, because
each of them can still invalidate the single-workspace decision.

## Results

| # | Item | Result |
| ---: | --- | --- |
| 1 | The existing library still passes its tests and Creusot proofs | **PASS** |
| 2 | Verus verifies a small driver function using a type from `driver-api` | **BLOCKED** — no Verus installation |
| 3 | Ordinary executable builds erase proof-only material correctly | **PASS** |
| 4 | Both protection-domain dependency graphs cross-compile to the selected AArch64 seL4 target with `no_std` satisfied | **BLOCKED** — no bare-metal target, no PD packages |
| 5 | The Microkit recipe assembles those binaries into a bootable image | **BLOCKED** — no Microkit SDK |
| 6 | Neither proof job loads the other tool's annotation crates as part of its verified implementation graph | **PASS** for the current graph |

### 1 — existing library, tests and proofs: PASS

`ci/test-host.sh` passes: format check, clippy with `-D warnings`, the root
package's test, and a release build of every workspace member.

`ci/prove-core.sh` passes: after removing `target/creusot` to force a fresh
translation, the gate reports
`Proved (verif/phy_trng_rlib/zero_slice.coma) ✔`, one proved goal, matching
the recorded goal inventory exactly. The regenerated Coma is byte-identical to the
tracked baseline on this host, and `verif/` gained no output belonging to any
other package.

Adding `[workspace]` to the root manifest and adding three member crates did
not change the proof result. The package name, public API, inline
tests, `why3find.json`, `verif/` and the `.why3find/` prover cache are
unchanged.

### 2 — Verus with a `driver-api` type: BLOCKED

`verus` is not on `PATH` and `[verus]` in `tools/toolchains.toml` is
unpopulated. `ci/prove-driver.sh` exits 78 and `ci/smoke-proofs.sh` skips the
Verus cases, both reporting an unconfigured gate rather than a pass.

What is prepared: `proofs/smoke/verus_smoke.rs` and its expected-failure
companion are in place, and the harness in `ci/smoke-proofs.sh` already
requires a non-zero verified count for the positive case and a
*postcondition* failure for the negative one, so a parse error cannot be
mistaken for either outcome.

What is unresolved and cannot be assumed: whether the pinned release provides
`cargo verus verify`, and how a crate opts in through its manifest. Verus
documents only partial multi-crate support, so a mixed-verifier workspace is
not prevalidated. Ordinary `--extern` metadata imports do not carry proof
contracts, so the dependency-free `verus --crate-type=lib` form stops being
sufficient as soon as the driver depends on `driver-api` — which is exactly
what this item tests.

### 3 — proof-material erasure: PASS

Checked, not assumed, by a step in `ci/test-host.sh`. Expanding the library
with the Creusot toolchain but **without** `--cfg creusot` yields:

```rust
pub fn zero_slice(v: &mut [u8]) {
    let len = v.len();
    let mut i = 0;

    while i < len { v[i] = 0; i += 1; }
}
```

Every `#[requires]`, `#[ensures]` and `#[invariant]` expands to nothing, so
the compiled program is the program that was checked. The check fails the gate
if a contract attribute or any `pearlite`/`creusot::` material survives
expansion.

The remaining `creusot_std` and `pearlite` strings in `target/release/libphy_trng.rlib`
are rlib *metadata* — dependency names and proc-macro attribute names — not
emitted code. This is an rlib property, and a final-binary check on the target
remains part of item 4.

### 4 — AArch64 `no_std` cross-compilation: BLOCKED

No bare-metal target is installed: `rustup target list --installed` shows only
`aarch64-apple-darwin` and `wasm32-unknown-unknown`. The seL4 protection-domain
packages do not exist, and `[runtime]` in `tools/toolchains.toml` is
unpopulated, so no target triple has been selected.

Partial evidence that is available:

- All three member crates currently have empty dependency graphs and are
  `no_std` with `#![forbid(unsafe_code)]`, so their closures are trivially
  satisfied — and trivially uninformative until they carry code.
- `phy-trng` is `#![no_std]` and depends only on `creusot-std` with
  `default-features = false`. Its dependency closure has **not** been
  validated for a bare-metal target, and the architecture's no-allocation and
  no-reachable-panic constraints have not been checked on a final binary.

The first concrete step, once a target is selected:

```sh
rustup target add <runtime.target_triple>
cargo build -p driver-api -p phy-trng --target <runtime.target_triple>
```

A portable core build on a bare-metal triple would still not be a claim that
the full camera and seL4 system runs there.

### 5 — Microkit image assembly: BLOCKED

No Microkit SDK, no seL4 Rust bindings revision, no board configuration.
`system/rpi4/` contains only the requirements for the system description.
`ci/build-rpi4.sh` exits 78 and lists precisely what is missing.

### 6 — proof-graph separation: PASS for the current graph

| Package | Dependency graph | Annotation crates |
| --- | --- | --- |
| `phy-trng` | `creusot-std` only, plus its proc-macro build dependencies | Creusot only |
| `driver-api` | empty | none |
| `ptrng-core` | empty (scaffolding) | none yet; Creusot when implemented |
| `ptrng-spsc` | empty (scaffolding) | none yet; Creusot when implemented |

`driver-api` has no dependencies at all, so it cannot pull `creusot-std` into
the Verus graph or `vstd` into the Creusot graph. `ci/prove-core.sh` confirms
`verif/` contains output for `phy_trng_rlib` only, so the Creusot run did not
translate the other members into its verified implementation graph even
though Cargo type-checks them.

**This result is weak right now** and must not be over-read: the other crates
are empty, so separation is trivially true. The informative version of item 6
is a re-run once `ptrng-core` carries Creusot contracts and the driver
carries Verus ones, with `driver-api` depended on by both. That is the
configuration that could force the fallback.

This result is only as strong as the current graph. It must be re-run when the
driver packages are added, and it is the property most likely to break: it is
what would force the fallback in section 6.3.

## Fallback if items 2, 4 or 5 fail

Keep one repository, and split it into explicitly excluded Cargo workspaces —
core, driver and deployment — each with its own lockfile and its own run
scripts, executed in its own directory. Share only the plain protocol package
source as an ordinary dependency with explicit workspace ownership. Separate
protection-domain executables avoid linking Rust rlibs built by incompatible
compiler versions.

The current single-workspace layout is therefore **provisional** until items
2, 4 and 5 pass, and until item 6 is re-run over a non-empty graph. `doc/REPOSITORY_STATUS.md` records that this decision is open.

## Re-running

```sh
ci/bootstrap-proofs.sh    # tool identities and pins
ci/test-host.sh           # items 1 and 3
ci/smoke-proofs.sh        # both tools' positive and negative cases
ci/prove-core.sh          # item 1, proof half
ci/prove-driver.sh        # item 2
ci/build-rpi4.sh          # items 4 and 5
```

Update this file with the observed outcome, not with the intended one.
