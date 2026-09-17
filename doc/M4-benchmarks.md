# M4 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G4 · **Paired design:** [M4-architecture.md](M4-architecture.md)

## Gate scope

All outputs using the test-only issuer are marked prototype. No G4 result claims production health/release qualification. G5/G6 rerun affected results with the real issuer. The byte boundary is 65,536 bytes; zero is a no-op; alarms override in-flight completion.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
|---|---|---|
| B-STAT-01 | BLOCKING | All four T_irn tests pass under the declared repetition rule; reference condition at G4, qualified supported envelope at G7. |
| B-STAT-02 | ADVISORY | Report all applicable test outcomes; investigate anomalies. Advisory; no entropy claim. |
| B-STAT-04 | BLOCKING | Same specified T_irn suite passes at the separate DRG.4 boundary; reference at G4, final profile at G7. |
| B-ENT-06 | BLOCKING | Exact vectors and structural tests pass; selected configuration matches B-ARG-01. No empirical extraction theorem claimed. |
| B-ENT-08 | BLOCKING | Seeding/reseeding matches the selected reference and vectors; entropy-insufficient paths reject; no output statistic is used to infer state entropy. |
| B-PERF-01b | BLOCKING | Within 5% of the accepted-input rate and actual Stage 1 map schedule, after accounting for rejects and seed overhead. |
| B-PERF-01c | BLOCKING | Meets the positive target frozen by G3 and never exceeds the justified output schedule. 16 kbit/s remains an aspiration until B-ARG-09 closes. |
| B-PERF-01d | BLOCKING | Measured at its own boundary with correct request/refresh enforcement; no physical entropy-rate claim. |
| B-PERF-02 | BLOCKING | For the declared available-buffer workload, target p50≤1 ms, p99.9≤5 ms; observed max≤20 ms. Freeze applicability at G3/G4. |
| B-PERF-03 | ADVISORY | Report p99.9/p50; target ≤5 under B-PERF-02 conditions. |
| B-PERF-07 | ADVISORY | Target ≤10 ms when qualifying reserved seed is already available; prove reservoir freshness/non-reuse policy separately. |
| B-FOOT-01 | ADVISORY | Reference portable-core aspiration ≤24 KiB; G3 freezes the actually selected profile budget. |
| B-FOOT-02 | BLOCKING | All static allocations and configured buffers fit the frozen per-profile memory budget. |
| B-FOOT-03 | BLOCKING | Peak stack ≤ selected profile bound (2 KiB core target); static safe upper bound covers measured watermark. |
| B-FOOT-05 | BLOCKING | Zero reachable panic paths for production runtime entry points. |
| B-VER-01 | BLOCKING | Every mandatory property discharged; zero admitted/skipped/unresolved/timed-out obligations. Report annotation coverage ≥95%, 100% for core/ring/release/state machines. |
| B-VER-03 | BLOCKING | Mandatory obligations for all production deterministic components discharge; linked checks agree. |
| B-VER-05 | BLOCKING | No output path from uninitialized/failed/expired context; dynamic epoch and lease checks are proved at runtime, not claimed as compile-time revocation. |
| B-VER-06 | BLOCKING | Tagged accounts cannot overcredit, wrap, double-consume or refund used entropy; transfers match B-ARG-01/03/09. |
| B-VER-07 | BLOCKING | FIFO, capacity, returned-count bounds, initialization, no unread overwrite, empty/full distinction, peek lifetime, panic freedom and termination proved. |
| B-INT-03 | BLOCKING | 0 bytes is a no-op; 1–65,536 bytes admitted only when otherwise eligible; >65,536 rejected before mutation. |
| B-INT-04 | BLOCKING | No new generating request admitted at ≥2^17 generated bits since qualifying refresh; an already admitted ≤2^19-bit request may complete; next generating request blocks. |
| B-INT-05 | BLOCKING | ≥246 effective bits supported by the construction analysis; state capacity not confused with entropy. |
| B-INT-06 | BLOCKING | B-ARG-03 accepted; implementation consumes sufficient unique qualified seed and rejects insufficient/invalid input. |

## Methods and required artifacts

### B-STAT-01 — PTG.3 T_irn

**Method:** Collect 2,040,000 consecutive PTG.3 output bits. Monobit: 20,000 bits, accept 9655–10345 inclusive. Poker: 20,000 bits/5,000 4-bit words, accept 1.03–57.4 inclusive. MultiMMC: 1,000,000 bits, k=2/D=16, min-entropy statistic ≥0.95. LZ78Y: 1,000,000 bits, k=2/B=16, statistic ≥0.95. Apply KS24 ¶904–914 and at most one permitted whole-suite repetition per assessment/condition; preserve every result. A logged debug run never becomes a qualifying extra retry. Record tool versions, parameter matching, min/max values and boundary. This is statistical inconspicuousness, not B-ARG-09.

**Artifact:** `bench/b-stat-01.json` · **Tier:** Campaign.

**Acceptance:** All four T_irn tests pass under the declared repetition rule; reference condition at G4, qualified supported envelope at G7.

### B-STAT-02 — SP 800-22 diagnostic sweep

**Method:** Use 1,000 sequences of 10^6 bits at a named boundary. Predeclare significance, proportion intervals, uniformity criteria and treatment of tests with insufficient eligible sequences. No rerun-until-pass and no use as seeding/extraction evidence.

**Artifact:** `bench/b-stat-02.json` · **Tier:** Campaign.

**Acceptance:** Report all applicable test outcomes; investigate anomalies. Advisory; no entropy claim.

### B-STAT-04 — DRG.4 T_irn

**Method:** Use B-STAT-01 parameters and repeat policy on DRG.4 output. Label as computational output, never a physical entropy assessment.

**Artifact:** `bench/b-stat-04.json` · **Tier:** Campaign.

**Acceptance:** Same specified T_irn suite passes at the separate DRG.4 boundary; reference at G4, final profile at G7.

### B-ENT-06 — Stage 1 implementation regression

**Method:** Test map/reference agreement, dimensions, bit ordering, full-rank/degeneracy checks where relevant, and model-predicted behavior for biased Bernoulli, Markov, periodic-noisy, sparse and adversarial fixtures plus real captures. Fixed-map full rank does not establish entropy transfer. Synthetic fixtures generated by a PRNG simulate distributions. Intermediate v_m is a lower-bound claim: output is neither required nor expected to fail T_irn.

**Artifact:** `bench/b-ent-06.json` · **Tier:** Commit.

**Acceptance:** Exact vectors and structural tests pass; selected configuration matches B-ARG-01. No empirical extraction theorem claimed.

### B-ENT-08 — Seeding implementation regression

**Method:** Check seed-input provenance, state-transition vectors, counters, domain separation, effective-state encoding, previous-state/additional-input cases and insufficient-credit behavior. Compare an independent implementation. Controlled low-entropy fixtures test plumbing only. B-ARG-03 alone supplies the state entropy-transfer argument.

**Artifact:** `bench/b-ent-08.json` · **Tier:** Commit.

**Acceptance:** Seeding/reseeding matches the selected reference and vectors; entropy-insufficient paths reject; no output statistic is used to infer state entropy.

### B-PERF-01b — Intermediate rate

**Method:** Report raw accepted/rejected rates, r_ext, variable-output/seed costs where applicable and measurement duration.

**Artifact:** `bench/b-perf-01b.json` · **Tier:** Campaign.

**Acceptance:** Within 5% of the accepted-input rate and actual Stage 1 map schedule, after accounting for rejects and seed overhead.

### B-PERF-01c — Qualified PTG.3 rate

**Method:** Count all generated PTG.3 bits, including seed material and discarded output. Reconcile credited input, theorem losses, buffering inventory and final output lengths; use a steady-state interval. Exceeding a lower-credit budget is a justification failure, not proof of excess physical entropy.

**Artifact:** `bench/b-perf-01c.json` · **Tier:** Campaign.

**Acceptance:** Meets the positive target frozen by G3 and never exceeds the justified output schedule. 16 kbit/s remains an aspiration until B-ARG-09 closes.

### B-PERF-01d — DRG.4 computational rate

**Method:** Report generated and delivered rates, request size/load, refresh/reservoir behavior, blocking and dropped/failed requests.

**Artifact:** `bench/b-perf-01d.json` · **Tier:** Campaign.

**Acceptance:** Measured at its own boundary with correct request/refresh enforcement; no physical entropy-rate claim.

### B-PERF-02 — Buffered warm request latency

**Method:** Measure 10^6 32-byte requests with stated offered load, queue depth, source readiness and target frequency. Report full distribution, failures and attribution; do not exclude refresh events silently. This is not a cold or source-starved bound.

**Artifact:** `bench/b-perf-02.json` · **Tier:** Campaign.

**Acceptance:** For the declared available-buffer workload, target p50≤1 ms, p99.9≤5 ms; observed max≤20 ms. Freeze applicability at G3/G4.

### B-PERF-03 — Buffered latency ratio

**Method:** Report absolute latency alongside ratio; measurement resolution must support p50.

**Artifact:** `bench/b-perf-03.json` · **Tier:** Campaign.

**Acceptance:** Report p99.9/p50; target ≤5 under B-PERF-02 conditions.

### B-PERF-07 — Cached refresh latency

**Method:** Measure transfer, state update and accounting. Reservoir age, authorization lifetime and compromise scope recorded. Never include unexplained wait time in a claim labelled cached.

**Artifact:** `bench/b-perf-07.json` · **Tier:** Campaign.

**Acceptance:** Target ≤10 ms when qualifying reserved seed is already available; prove reservoir freshness/non-reuse policy separately.

### B-FOOT-01 — Application text size

**Method:** Final linked .text/.rodata breakdown per profile/backend; do not apply a Cortex-M core budget to the full seL4 camera image.

**Artifact:** `bench/b-foot-01.json` · **Tier:** Commit.

**Acceptance:** Reference portable-core aspiration ≤24 KiB; G3 freezes the actually selected profile budget.

### B-FOOT-02 — RAM and buffers

**Method:** Report state, stack, frame/DMA, snapshots, raw/intermediate rings, seed reservoir, staging, commit buffers and replay ledgers separately. The legacy ≤8 KiB non-buffer target is advisory; excluded buffers remain in the system total.

**Artifact:** `bench/b-foot-02.json` · **Tier:** Commit.

**Acceptance:** All static allocations and configured buffers fit the frozen per-profile memory budget.

### B-FOOT-03 — Stack bound

**Method:** Use static call/interrupt analysis and high-water testing; a conservative static bound need not agree within 10%. Record differences and interrupt/FFI assumptions.

**Artifact:** `bench/b-foot-03.json` · **Tier:** Commit.

**Acceptance:** Peak stack ≤ selected profile bound (2 KiB core target); static safe upper bound covers measured watermark.

### B-FOOT-05 — No reachable panic

**Method:** Combine proof obligations with linked analysis; missing panic_fmt alone is not sufficient if another panic/abort path exists. Fault handling remains a specified system action.

**Artifact:** `bench/b-foot-05.json` · **Tier:** Commit.

**Acceptance:** Zero reachable panic paths for production runtime entry points.

### B-VER-01 — Mandatory obligations and annotation coverage

**Method:** Maintain property inventory and assumption map. Trusted contracts are separate assumptions with approvals, never reported as proofs. Test-harness-only obligations at G4 cannot qualify production release.

**Artifact:** `bench/b-ver-01.json` · **Tier:** Commit.

**Acceptance:** Every mandatory property discharged; zero admitted/skipped/unresolved/timed-out obligations. Report annotation coverage ≥95%, 100% for core/ring/release/state machines.

### B-VER-03 — Panic freedom and termination

**Method:** Include error paths, length conversions, fixed-point rounding, counter saturation and loop variants. State trusted HAL/FFI assumptions explicitly.

**Artifact:** `bench/b-ver-03.json` · **Tier:** Commit.

**Acceptance:** Mandatory obligations for all production deterministic components discharge; linked checks agree.

### B-VER-05 — Output eligibility

**Method:** Compile-fail tests for non-Ready types; runtime/model proofs for remote epoch changes, lease expiry and commit eligibility. G4 covers local prototype only; G5/G6 add real health/release.

**Artifact:** `bench/b-ver-05.json` · **Tier:** Commit.

**Acceptance:** No output path from uninitialized/failed/expired context; dynamic epoch and lease checks are proved at runtime, not claimed as compile-time revocation.

### B-VER-06 — Entropy accounting

**Method:** Prove credited/debited balance, disjoint sample ranges, downward credit/upward debit rounding, failed-call behavior, state cap and finite inventory accounting. Claim parameter validation is part of input preconditions.

**Artifact:** `bench/b-ver-06.json` · **Tier:** Commit.

**Acceptance:** Tagged accounts cannot overcredit, wrap, double-consume or refund used entropy; transfers match B-ARG-01/03/09.

### B-VER-07 — Sequential ring

**Method:** Reference queue property tests plus obligations. Explicitly sequential/cooperative semantics; no claim of ISR/cross-domain ordering proof.

**Artifact:** `bench/b-ver-07.json` · **Tier:** Commit.

**Acceptance:** FIFO, capacity, returned-count bounds, initialization, no unread overwrite, empty/full distinction, peek lifetime, panic freedom and termination proved.

### B-INT-03 — Byte request limit

**Method:** Test 0,1,4096,65,535,65,536,65,537,usize::MAX without allocating an impossible buffer; test checked length-validation helper and real feasible buffers. Internal conversion enforces 2^19 bits.

**Artifact:** `bench/b-int-03.json` · **Tier:** Campaign.

**Acceptance:** 0 bytes is a no-op; 1–65,536 bytes admitted only when otherwise eligible; >65,536 rejected before mutation.

### B-INT-04 — Refresh bound and completion

**Method:** Test exactly-before/at/after threshold, large requests, zero-length calls, partial errors and discarded output. Only qualifying refresh changes reseed generation. Alarm/lease expiry overrides completion. Show total generated bits before next refresh <2^17+2^19; report tighter block-aligned bound if applicable.

**Artifact:** `bench/b-int-04.json` · **Tier:** Campaign.

**Acceptance:** No new generating request admitted at ≥2^17 generated bits since qualifying refresh; an already admitted ≤2^19-bit request may complete; next generating request blocks.

### B-INT-05 — Effective state classification

**Method:** Inventory secret-dependent computational state, public counters and derived components. Justify classification using selected construction, not just storage size.

**Artifact:** `bench/b-int-05.json` · **Tier:** Campaign.

**Acceptance:** ≥246 effective bits supported by the construction analysis; state capacity not confused with entropy.

### B-INT-06 — Seeding admission and provenance

**Method:** Use source ICA and PTG.3 generation accounting plus seed reservations. Verify actual state transitions via B-ENT-08. A count of 240,000 input millibits alone is not the transfer argument.

**Artifact:** `bench/b-int-06.json` · **Tier:** Campaign.

**Acceptance:** B-ARG-03 accepted; implementation consumes sufficient unique qualified seed and rejects insufficient/invalid input.

## Evidence completeness at G4

Single-target implementation; all mandatory local proofs; independent primitive and seed regressions; named generated/delivered boundaries; byte-API and refresh tests. Stub-health results explicitly test-only.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M4
make verify PROFILE=reference
make gate G4 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
