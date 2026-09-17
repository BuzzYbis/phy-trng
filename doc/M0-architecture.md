# M0 — Feasibility and assurance profiles

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Effort:** 80 h provisional · **Productive weeks:** 1–8 · **Gate:** [G0](GATES.md#g0)

## Objective and entry

Reduce hardware, proof-tool and assurance-profile uncertainty before durable runtime work. Use the supplied standards and the v0.3 claim boundaries. Probe code may be discarded. No entropy estimate or source certification is asserted at this gate.

## Work packages — 80 h provisional

| Package | Hours | Concrete output |
|---|---:|---|
| P1 sensor configuration | 18 | Raw/fixed pipeline report and capture/readback evidence |
| P2 DMA and release platform | 14 | Enforced/trusted DMA verdict and timing-service feasibility |
| P3 primitive/backend scope | 18 | Selected-target artifact and independent-oracle applicability matrix |
| P4 verification/transport signatures | 14 | Hardest signature prototype and replayable obligations |
| P5 acquisition freshness | 8 | Authenticated-freshness feasibility, A-ACQ-1 scope |
| Scaffolding and review setup | 8 | Profiles, registry/schema, evidence spine, CI and initial review |

### P1 — actual acquisition configuration

Configure and read back exposure, gain, white balance, gamma/ISP/denoise/lens correction, frame rate and integration time as supported by the device. Capture at least ten minutes while varying scene illumination. Record undocumented processing and firmware behavior. Raw unprocessed access is the preferred project constraint; a deterministic modeled transformation is not universally forbidden by physics, but requires a specific revised model and explicit acceptance.

Verdicts: confirmed; unacceptable and an alternative chosen; or unresolved. Ordering a replacement is a recorded procurement result, not confirmation that it works. G1 cannot begin qualification on an untested replacement.

### P2 — DMA and temporal enforcement

Identify every camera DMA path and stream ID, memory aperture, SMMU ownership and configuration authority. Attempt a valid and deliberately forbidden DMA transaction. A driver that can broaden its own mappings is not confined against compromise. If enforcement is unavailable, record A-DMA-1 and its effect on the claim.

Prototype reliable monotone time, timer interrupts, watchdog/fault routing and scheduler isolation. The release protocol will rely on these; no promise of instantaneous revocation follows from seL4. Record whether bounded commit and timely revocation are implementable on the chosen target.

### P3 — conditional crypto scope

For each candidate primitive/target, record implementation, upstream commit, compiler, available functional/leakage proofs, KAT source and independent reference. Link at least one usable backend into a no_std target binary. A soft-primary verdict is a valid profile choice; G3 then uses the independent-oracle gate, not an impossible Formosa requirement. Carry SHA-256 availability alongside Keccak because the construction choice is still open.

### P4 — Creusot expressiveness and unsafe boundary

Using the pinned Rust/Creusot toolchain and its Why3/solver pipeline, specify a bounded const-generic bulk operation and a consumer with arbitrary shared indices. Archive tool versions, specification dependencies and a reproducible invocation. Demonstrate checked local index snapshots and a sequential logical model. State which memory-ordering/FFI primitives remain assumptions. Produce at least one discharged toy obligation with cold/warm replay timings. A fallback API must have a working prototype; a handwritten signature alone is insufficient proof of feasibility.

### P5 — physical acquisition trust

Assess whether a protected sensor-side freshness mechanism exists. Record the part, challenge acquisition binding and what attacker control it survives. v1 default is A-ACQ-1 plus narrow failure monitors; a generic counter, nonce or video comparison is not proof of fresh physical noise.

## Repository and artifact contracts

Create only the scaffolding needed for probes: workspace profiles, build matrix, an evidence attribute retaining the annotated item, matrix extractor, benchmark JSON schema, dependency manifest, ADR directory and STATE.md. The evidence macro is semantically transparent; it must not delete the annotated Rust item.

Profile fields: target/board, supported scope (compile-only or qualified), construction candidate, primitive/backend applicability, oracle, DMA mode, clock/fault mechanism, active evidence and assumptions. Keep scripts/tools separate from no_std runtime.

## Freeze / defer

Freeze document/benchmark identifiers and the first reference profile. Defer numeric entropy, final extraction map, generator choice and advertised performance. Obtain independent reviewer availability now for B-ARG-08 and subsequent model/construction reviews; availability is a schedule dependency.

## Risks and exit

Probe timeboxes produce explicit confirmed/unresolved verdicts. An unresolved essential capability blocks its qualification; do not convert uncertainty into a pass. If camera feasibility fails, assess the separately budgeted RO source. G0 requires current assumptions reviewed, selected backend viable, one replayable proof and a working evidence/result mechanism. No durable cryptographic code is required beyond the linking probe.

## Acceptance and dependencies

Five probe verdicts; `config/profiles.toml`; target/backend/oracle applicability; initial reviewed assumption register; reproducible toy proof and harness.

Canonical acceptance criteria are in [BENCHMARKS.md](BENCHMARKS.md); gate aggregation is in [GATES.md](GATES.md). The paired [milestone benchmarks](M0-benchmarks.md) list newly active items and methods. Prior gate results remain required only when applicable and dependency-valid. See [architecture](ARCHITECTURE.md) for authority, units and trust definitions.
