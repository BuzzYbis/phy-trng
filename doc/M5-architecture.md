# M5 — Health, authorization and release

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Effort:** 140 h provisional · **Productive weeks:** 57–70 · **Gate:** [G5](GATES.md#g5)

## Objective and entry

Replace the test issuer with real health decisions, immutable accepted data, two authorization protocols and a timed release commit model. Use G2 physical assumptions and G3 complete entropy-transfer arguments. Freeze statistical and timing contracts before claiming detection or release bounds.

## Work packages — 140 h provisional

| Package | Hours | Output |
|---|---:|---|
| Model-derived online tests | 28 | Statistics, cutoffs and uncertainty rationale |
| Output-referred degradation mapping | 14 | Bound-aware injection scenarios |
| Startup/total-failure/RCT/APT | 24 | Implementations and vectors |
| Snapshot/ICA/ORA/receiver ledgers | 24 | Separate credit and release authorization paths |
| Local release/temporal protocol | 24 | Commit model, horizons, leases and exposure budget |
| Rig/campaign execution analysis | 26 | Accepted counts/bounds and evidence |

## Health design

Derive tests from read-noise, illumination/clipping, dependence and other modeled degradation signatures. State null distribution, parameter uncertainty, temporal dependence, window/stride and detector look-ahead. Every code constant is checked against the rationale table. RCT/APT use exact 90B conventions and complement, rather than replace, model-specific tests.

Choose the min-entropy claim only. Map source changes through B-ARG-05/01/**09** to output-entropy intervals. A lower bound crossing 0.98 means loss of assurance; it does not demonstrate the actual entropy is below 0.98. The experiment labels which interpretation it supports. Do not convert a lower-bound deficit into a fictitious exact injected entropy loss.

Startup inhibition includes qualified transient handling, and no ICA/ORA may be issued before success. Distinguish sensor startup/warm-up from the target ≤500 ms test phase and overall first output. Revisit M2 restart data if the deployed inhibition changes.

## Snapshot and ICA

1. Copy completed raw data into health-owned storage.
2. End the copy and establish immutable ownership of the snapshot.
3. Run required tests and subsequent observation horizon on the actual snapshot/context.
4. On success, issue a single ICA for source/configuration, boot session, epoch, snapshot generation, exact sample range, length, credit and expiry.
5. The conditioner checks trusted channel provenance and a consumed-ID/range ledger, then credits/consumes those same bytes exactly once.

Copying after testing a mutable producer buffer is forbidden. Slot reuse requires checked acknowledgements. Alternative integrity tags are verified against a private snapshot subsequently used, not against a buffer the producer can mutate again.

## ORA and local release model

ORA is independently issued through the authentic health-to-release path for a specific boundary, request/generation/reseed context, epoch, output interval, deadline and maximum bytes. It is not a reused ICA and adds no entropy credit. DRG.4 expansion is explicitly bounded in output units. Keep a trusted ORA consumption ledger even though local types are non-Copy.

Release snapshots staging into its own bounded writable commit buffer. Consume/reserve the permit conservatively; verify authoritative current epoch/lease/range immediately at the specified commit section; publish a bounded chunk and commit descriptor. Cancellation/error burns used ranges. A stale held Ready value is checked dynamically. Successful confinement does not prove malicious staged data are random.

## Three instants and the release rule

Define t_fault, t_alarm and t_close. No commit after release-local closure. Before closure, bound pending ORA bytes, chunk size, scheduling/clock/check tolerance and permitted exposure. Lease expiry is an eventual bounded closure mechanism, not instantaneous remote revocation. A reliable timer and bounded scheduling are explicit dependencies.

Quarantine holdback follows detector observation horizon and fault onset phase. A test window pass alone cannot imply certain absence of a fault. Deterministic zero-post-fault-dependence guarantees apply only to named faults with a proven adequate holdback/detection model. Statistical misses carry probabilities and an exposure argument. If bounded cryptographic bridging is selected, separately justify its state/security assumptions, output boundary, bit count and stop condition before accepting it.

Alarm handling invalidates outstanding context, stops new permits and schedules release closure. In-flight callers receive an error and diagnostic written count and discard the whole request buffer; prior committed bytes are not retrospectively revoked. Release erases its own commit buffer; generator staging cleanup is not trusted under hostile-generator tests.

## Statistical campaign plan

Defaults: 299 zero-miss independent trials for ≥0.99 per-class detection; 2,995 for ≥0.999 startup; three million zero-alarm independent opportunities for ≤10^-6. Use exact one-sided bounds, predeclared counts/stopping rules and explicit confidence scope. B-HLT-06 requires the upper bound ≤alpha, not merely k/n≤alpha.

Choose separate worst entropy, false-alarm and detection-delay scenarios. Treat overlapping windows/continuous state carefully; resetting the rig does not automatically preserve the deployed null distribution. Retain failures and all trials. No weaker achieved bound silently passes G5.

Compute wall clock from actual opportunity cadence and rig throughput before starting. At one second/window, three million windows take 34.72 days; at ten seconds, 347.22 days. Replace the old fixed week-60 start assumption with a measured campaign schedule. Independent review/rig availability are explicit critical-path dependencies.

## Exit

Real tests and snapshot issuance; accepted ICA/ORA ledger model; local timed release protocol; detector/lease/commit parameters frozen; uncertainty-aware mapping; completed statistical bounds; restart/latency evidence requalified. G6 must reproduce these properties across PDs and the actual platform scheduler/clock.

## Acceptance and dependencies

Reviewed detector rationale, uncertainty-aware defect mapping, campaign plan/results, snapshot/ICA/ORA protocol and local commit-state model; real startup invalidates earlier provisional restart assumptions where changed.

Canonical acceptance criteria are in [BENCHMARKS.md](BENCHMARKS.md); gate aggregation is in [GATES.md](GATES.md). The paired [milestone benchmarks](M5-benchmarks.md) list newly active items and methods. Prior gate results remain required only when applicable and dependency-valid. See [architecture](ARCHITECTURE.md) for authority, units and trust definitions.
