# M4 — Single-target vertical slice

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Effort:** 150 h provisional · **Productive weeks:** 42–56 · **Gate:** [G4](GATES.md#g4)

## Objective and entry

Implement the selected single-target path with two distinct generator states. G3 supplies actual construction, Stage 1/Stage 2 entropy arguments, backend applicability and final block dimensions. G4 is an engineering prototype gate with a test-only health issuer; it is not production qualification.

## Work packages — 150 h provisional

| Package | Hours | Output |
|---|---:|---|
| Core/accounting/identity | 26 | Tagged amounts, epochs, errors and contracts |
| Sequential ring | 22 | FIFO/ownership model and proofs |
| Stage 1 | 26 | Map implementation, snapshot provenance and regression |
| Two generator instances | 40 | PTG.3 schedule; DRG.4 seeding/refresh/request state |
| API and local release model | 24 | Byte API, bounded request state and prototype eligibility |
| Statistical/rate baseline | 12 | Both T_irn boundaries, selected rate/latency/resource measurements |

## Core contracts

Use distinct types for raw/intermediate/state entropy amounts, input bits, generated bits and delivered bytes. Round credit down and debit requirements up. Prove no overflow, negative budget, double credit, overlapping sample-range reuse or refund of consumed material. Saturation is not permission to forget consumed identities.

Identity comprises source/configuration, boot session, epoch, sequence and authorization identifiers; wrap fails closed. Define ICA and ORA as separate record types with separate receiver state. Production constructors reside with their actual issuing authority; the model does not rely on nonexistent Rust friend visibility.

Error classes include source failure, health alarm, insufficient entropy, refresh required, invalid/expired authorization, wrong epoch, request too long and configuration fault. A failed call has a specified state/buffer effect, not just an enum.

## Sequential buffers and extraction

Prove ring length/capacity, push/pop count bounds, FIFO, initialized reads, no unread overwrite, empty/full distinction, peek lifetime, panic freedom and termination. This is a sequential cooperative model. Cross-PD ordering and hostile mutation are M6 obligations.

Implement only the selected Stage 1 route and configuration. Preserve input snapshot ID/range and mark its ICA consumed once. Qualify vectors/reference agreement, bit order, structural properties and edge dimensions. Full rank or plausible statistics never substitute for B-ARG-01.

## PTG.3 and DRG.4

Allocate two distinct states even if the code type is reused. PTG.3 output count follows B-ARG-06/09 per intermediate input; separate consumed seed from externally tapped test data and account for all generated bits. DRG.4 receives only qualified PTG.3 seed via a unique reservation.

Implement the exact nine-tuple and request-state schedule. Check seeding/reseeding with B-ENT-08 vectors/reference transitions, not statistical estimation of output. Include domain separation, prior state, additional input, length encodings, insufficient credit and failed-reservation behavior.

The byte API accepts zero as a no-op and 1–65,536 bytes only when eligible. Reject larger lengths before mutation. No new generating request is admitted at ≥2^17 generated bits since refresh. A previously admitted request may finish under ¶239, but never despite an alarm/expired release context. Generated/discarded bytes count; returning an error does not reset the counter. Total before refresh is <2^17+2^19 bits under this policy.

## Prototype issuance and production separation

A named test harness supplies explicit provisional authorizations. It is compiled separately from production and cannot be enabled through the production profile. Unit-test `cfg(test)` alone is not assumed to enable another dependency's issuer; implement a concrete harness interface without weakening production constructors.

G4's eligibility proofs cover local prototype state and epoch checks. Real health lease, authoritative snapshot issuance and client commit qualification arrive at G5/G6. Each result declares harness/profile scope and is rerun under real health before qualification.

## Measurement and proof acceptance

Measure raw/intermediate/PTG.3/DRG.4 boundaries separately. B-PERF-01c uses the G3-qualified schedule and target, reconciling finite buffered input. Buffered latency tests declare offered load and inventory. Cached refresh reports compute/transfer only; unbuffered acquisition is not covered by that result.

Implement and discharge the mandatory Creusot contracts on deterministic core, ring, accounting and generator/release state models. Mandatory properties must all discharge; report trusted assumptions separately. Annotation coverage is secondary. Resource accounting includes configured frames/rings/snapshots/reservoirs and ledgers in the system total. The static stack upper bound must cover watermark; equality within an arbitrary percentage is unnecessary.

## Exit

Selected-profile implementation and mandatory local proofs; both output boundaries pass specified statistical checks; seed/map regressions pass; rates/latencies and memory baseline recorded; byte API and <2^17+2^19 completion envelope tested. No production-ready claim until the real health and release gates pass.

## Acceptance and dependencies

Single-target implementation; all mandatory local proofs; independent primitive and seed regressions; named generated/delivered boundaries; byte-API and refresh tests. Stub-health results explicitly test-only.

Canonical acceptance criteria are in [BENCHMARKS.md](BENCHMARKS.md); gate aggregation is in [GATES.md](GATES.md). The paired [milestone benchmarks](M4-benchmarks.md) list newly active items and methods. Prior gate results remain required only when applicable and dependency-valid. See [architecture](ARCHITECTURE.md) for authority, units and trust definitions.
