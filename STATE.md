# Phy-TRNG — Session State (`STATE.md`)

**Milestone:** M0 — Feasibility and assurance profiles · **Next Gate:** [G0](doc/GATES.md#g0) · **Spec:** v0.3.1

## Working rule

Follow [`doc/REPOSITORY_STATUS.md`](doc/REPOSITORY_STATUS.md) §0:
- **Rust implementation, contracts, and tests:** written by the repository owner, by hand.
- **Design discussion, obligation lists, review, CI/config/assurance scaffolding:** collaborative / assistant-supported.

## Last verified state

- **Baseline commit:** `b3a99d6` (plus M0 baseline updates in progress)
- **Host / toolchain:** `Darwin 27.2.0 arm64`, `rustc 1.100.0`, `cargo-creusot 0.14.0-dev` (`nightly-2026-08-03`), `why3 1.8.2+git`, `why3find 1.3.0+dev`, solvers `alt-ergo 2.6.2`, `z3 4.15.3`, `cvc5 1.3.1` (pinned in [`tools/toolchains.toml`](tools/toolchains.toml))
- **Checks:**
  - `make all`: passing (`fmt-check`, `clippy -D warnings`, `test` + `miri` 11 passed: 1 in `phy-trng`, 10 in `ptrng-spsc`, `check-trust` 0 markers, `verify` 24 Creusot `.coma` goal files proved with `--span-mode relative`, `build --release`)
  - `ci/smoke-proofs.sh --creusot`: passing (positive case proves 1 goal; negative case fails on `vc_increment`)
  - `ci/bootstrap-proofs.sh`: cleanly exits `78` (`unconfigured` due to empty `[verus]` and `[runtime]` pins; zero mismatches)
  - `make gates`: zero `FAIL` lines (`test-host`, `prove-core`, `check-trust` pass; `bootstrap-proofs`, `smoke-proofs`, `prove-driver`, `build-rpi4` unconfigured; `test-hil` skipped without `BOARD`)
- **Code state:** `src/lib.rs` implements `zero_slice` (1 Creusot `.coma` goal); `crates/ptrng-spsc` implements `SpscError` + `RingBuffer<T: Copy, const N: usize>` (23 Creusot `.coma` goals, 10 host tests); `crates/driver-api` and `crates/ptrng-core` are `#![no_std]` / `#![forbid(unsafe_code)]` scaffolding stubs.

## Current active assumptions (M0)

| ID | Summary | Source |
| --- | --- | --- |
| `A-ACQ-1` | Sensor, physical interface, and acquisition software trusted for provenance | [`doc/ARCHITECTURE.md`](doc/ARCHITECTURE.md) §6, [`proofs/tcb.md`](proofs/tcb.md) |
| `A-DMA-1` | Camera device and driver trusted for DMA (default on RPi4 BCM2711, which lacks an ARM SMMU) | [`doc/ARCHITECTURE.md`](doc/ARCHITECTURE.md) §6, [`config/profiles.toml`](config/profiles.toml) |
| `T-TOOL-1..3` | Creusot translation, Why3/Why3find + 3 solvers (`alt-ergo`, `z3`, `cvc5`), and `creusot-std` specs | [`proofs/tcb.md`](proofs/tcb.md) §1 |
| `T-BUILD-1..3` | `rustc`/LLVM semantics, proof-material erasure (checked), release profile invariants | [`proofs/tcb.md`](proofs/tcb.md) §2 |
| `T-ENV-1` / `REPRO-2` | Out-of-repo `[patch.crates-io]` redirect for `creusot-std` in `~/.cargo/config.toml` | [`tools/toolchains.toml`](tools/toolchains.toml) |
| `REPRO-1` | Partially mitigated via `--span-mode relative`; `creusot-std` spans still reference `../../creusot/creusot-std/...` | [`tools/toolchains.toml`](tools/toolchains.toml) |
| `REPRO-3` | No Linux CI reference environment pinned yet | [`tools/toolchains.toml`](tools/toolchains.toml) |

## M0 progress tracker (80 h provisional budget)

| Package | Budget | Logged | Status | Notes |
| --- | ---: | ---: | --- | --- |
| P1 — Sensor configuration (IMX296) | 18 h | 0 h | Not started | Hardware probe on RPi4 + IMX296 RAW10 @ 60 fps |
| P2 — DMA and release platform | 14 h | 0 h | Not started | Confirm `A-DMA-1` on BCM2711; prototype timer/watchdog/fault routing |
| P3 — Primitive/backend/oracle scope | 18 h | 0 h | Not started | `no_std` link probe + independent oracle applicability matrix |
| P4 — Verification/transport signatures | 14 h | — | Partial | Creusot expressiveness answered ([`proofs/creusot/coverage.md`](proofs/creusot/coverage.md)); Verus + Microkit compatibility items 2, 4, 5 blocked |
| P5 — Physical acquisition freshness | 8 h | 0 h | Not started | Assess Option B feasibility vs. `A-ACQ-1` default |
| Scaffolding & review setup | 8 h | — | In progress | Workspace, CI gates, TCB, `config/profiles.toml`, `STATE.md` in place; `bench/` schema, ADR dir, and `B-ARG-08` review open |
| `B-ARG-08` independent reviewer | — | — | Open | Reserve non-author reviewer for G0 assumption register |

## Next small tasks (<= 4 h sessions)

1. Implement `crates/driver-api` by hand against [`proofs/contracts/frame-handoff.md`](proofs/contracts/frame-handoff.md) (validated tags + 48-byte wire codec, then lifecycle, consumer validation, and unit tests).
2. Implement `crates/ptrng-core` by hand with Creusot contracts (`crates/ptrng-spsc` element-type decision resolved as generic `T: Copy` / `Default` and implemented + proved).
3. Install/pin Verus in [`tools/toolchains.toml`](tools/toolchains.toml) and run compatibility experiment item 2 (`imx296-driver` skeleton using a `driver-api` type).
4. Execute M0 P3 (crypto backend `no_std` link + oracle matrix) and hardware probes P1/P2/P5 on RPi4 + IMX296.
5. Reserve independent non-author reviewers (`B-EVD-04`, `B-ARG-08`).

## Open issues / blockers

- `[verus]` and `[runtime]` sections in [`tools/toolchains.toml`](tools/toolchains.toml) are unpopulated, blocking compatibility experiment items 2, 4, and 5 and keeping the single-workspace layout provisional.
- `REPRO-1` (`creusot-std` sibling relative span), `REPRO-2` (external `creusot-std` Cargo patch), and `REPRO-3` (missing Linux CI reference container) remain open for `B-EVD-03`.
- Independent non-author reviewer availability (`B-EVD-04`) is not yet secured.
