# M5 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G5 · **Paired design:** [M5-architecture.md](M5-architecture.md)

## Gate scope

Predeclare statistical counts/stopping rules and separate worst entropy, false-alarm and detection scenarios. The lower success formula is 0.05^(1/n), not its complement. Observation horizon and t_fault/t_alarm/t_close scope must be visible in every release report.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
|---|---|---|
| B-HLT-01 | BLOCKING | Per in-scope class, a one-sided 95% detection lower bound ≥0.99; default 299 independent trials with zero misses. Release behavior meets its declared deterministic/probabilistic scope. |
| B-HLT-02 | BLOCKING | Observed maximum ≤2 frames for specified hard failures; separate justified bounds for other classes. Required worst-case claims also have an analytic scheduling/detector argument. |
| B-HLT-03 | BLOCKING | At the predeclared source-degradation cases corresponding to an assured-output defect boundary of 0.02 min-entropy/bit, detection lower bound ≥0.99 within its window. |
| B-HLT-04 | BLOCKING | One-sided 95% upper bound ≤10^-6 per declared independent test opportunity at each required false-alarm worst case. Default 3,000,000 opportunities with zero alarms. |
| B-HLT-05 | BLOCKING | Per fault class, one-sided 95% lower bound ≥0.999; default 2,995 independent zero-miss trials; qualified startup-test phase ≤500 ms including declared exclusions. |
| B-HLT-06 | BLOCKING | Independent cutoff calculation matches the selected 90B method; target failures detected; false-alarm **upper confidence bound**, not observed proportion, ≤ configured alpha=2^-20. |
| B-PERF-05 | ADVISORY | Target ≤25% of one reference core at selected raw rate; report worst supported load. |
| B-PERF-06 | ADVISORY | Report p50/p99/observed max and phase breakdown; aspiration ≤2 s subject to the physical warm-up envelope. |
| B-PERF-09 | BLOCKING | Within the detector-specific observation-horizon and release timing contract frozen at G5. |
| B-PERF-10 | BLOCKING | Meets the bounded-wait or nonblocking-error API policy frozen at G5; no cached-latency promise applied. |
| B-VER-10 | BLOCKING | All state transitions satisfy the release contract; old sessions/epochs and expired leases are rejected. |
| B-VER-11 | BLOCKING | No ID/range can be consumed twice at its trusted receiver; replayed serialized bytes are rejected. |
| B-ROB-07 | BLOCKING | Every in-scope scenario has its specified result; out-of-scope cases are labelled, never counted as passes. |
| B-INT-09 | BLOCKING | Snapshot/permit/epoch/lease validation and bounded commit obey the frozen contract under every enumerated interleaving. |
| B-INT-11 | BLOCKING | Consumed bytes are the tested immutable snapshot; altered identity/range/configuration/provenance is rejected. |

## Methods and required artifacts

### B-HLT-01 — Total failure coverage

**Method:** Inject occlusion, flood, power removal, data interruption, clock stop, frozen frames and specifically named replay patterns. General varied-video replay is outside A-ACQ-1. Vary onset across frame/window/commit phases. Record fault, detection, close and commit timestamps plus contributing sequence ranges. No claim of structural detection from a statistical pass.

**Artifact:** `bench/b-hlt-01.json` · **Tier:** Campaign.

**Acceptance:** Per in-scope class, a one-sided 95% detection lower bound ≥0.99; default 299 independent trials with zero misses. Release behavior meets its declared deterministic/probabilistic scope.

### B-HLT-02 — Detection timing

**Method:** Use B-HLT-01 trials with clock uncertainty and onset phase. Report full distribution and observed maximum, not a claimed universal p100. Distinguish physical fault detection from propagation to release and final commit closure. The clock/lease assumptions are explicit.

**Artifact:** `bench/b-hlt-02.json` · **Tier:** Campaign.

**Acceptance:** Observed maximum ≤2 frames for specified hard failures; separate justified bounds for other classes. Required worst-case claims also have an analytic scheduling/detector argument.

### B-HLT-03 — Output-referred online sensitivity

**Method:** Map controlled sigma/illumination/clipping/dependence changes through B-ARG-05/01/09, including parameter uncertainty. Distinguish a proved upper/lower interval for actual output entropy from a conservative lower bound that merely falls below the claim. Label the latter loss of assurance, not measured actual defect. Choose physical/synthetic injections accordingly. Default 299 zero-miss trials per scenario with individually stated confidence. No Shannon variant required in v1. Report detection-versus-degradation curves, not an incorrectly labelled ROC unless false-positive rate is also varied.

**Artifact:** `bench/b-hlt-03.json` · **Tier:** Campaign.

**Acceptance:** At the predeclared source-degradation cases corresponding to an assured-output defect boundary of 0.02 min-entropy/bit, detection lower bound ≥0.99 within its window.

### B-HLT-04 — Online false-alarm probability

**Method:** Predeclare window/stride and independence or a justified dependent-event model; nominal operation must preserve the deployed history rather than resetting it away. Worst false-alarm cells are selected independently of minimum-entropy and slowest-detection cells. Use exact binomial bounds if assumptions apply. A predeclared larger-n acceptance plan may permit alarms. A weaker achieved bound is a failed gate unless the specification is explicitly revised. Derive wall clock from opportunity cadence.

**Artifact:** `bench/b-hlt-04.json` · **Tier:** Campaign.

**Acceptance:** One-sided 95% upper bound ≤10^-6 per declared independent test opportunity at each required false-alarm worst case. Default 3,000,000 opportunities with zero alarms.

### B-HLT-05 — Startup efficacy

**Method:** Test stuck-at, model-incompatible short periods and selected severe biases plus applicable total failures. Justify severity relative to the model, rather than generic bias alone. Distinguish test execution, sensor power-up/warm-up and total first-output latency. No startup authorization before success. Document a wider required platform budget if measurements demand it before qualification.

**Artifact:** `bench/b-hlt-05.json` · **Tier:** Campaign.

**Acceptance:** Per fault class, one-sided 95% lower bound ≥0.999; default 2,995 independent zero-miss trials; qualified startup-test phase ≤500 ms including declared exclusions.

### B-HLT-06 — 90B RCT/APT

**Method:** Define sample alphabet, entropy estimate, cutoff convention, window and per-opportunity event unit for each test. Use the exact standard algorithms including startup/continuous behavior. Publish counts, bounds and dependence assumptions. Very low false-alarm rates are allowed. RCT/APT complement the source-model online tests; they do not replace them.

**Artifact:** `bench/b-hlt-06.json` · **Tier:** Campaign.

**Acceptance:** Independent cutoff calculation matches the selected 90B method; target failures detected; false-alarm **upper confidence bound**, not observed proportion, ≤ configured alpha=2^-20.

### B-PERF-05 — Health CPU share

**Method:** Include snapshot copy, all tests, metadata and authorization issuance, with warm/cold caches and rate variation.

**Artifact:** `bench/b-perf-05.json` · **Tier:** Campaign.

**Acceptance:** Target ≤25% of one reference core at selected raw rate; report worst supported load.

### B-PERF-06 — Cold boot to first output

**Method:** 100 independent cold boots including configuration, KAT, warm-up, startup tests, fresh entropy acquisition and seeding. Qualify any advertised bound on the selected envelope.

**Artifact:** `bench/b-perf-06.json` · **Tier:** Campaign.

**Acceptance:** Report p50/p99/observed max and phase breakdown; aspiration ≤2 s subject to the physical warm-up envelope.

### B-PERF-09 — Quarantine and commit delay

**Method:** Report raw-block last-sample to eligibility, eligibility to commit, alarm-to-close and outstanding authorized bytes. Include worst onset phase and scheduling uncertainty. A covering-window completion alone is insufficient.

**Artifact:** `bench/b-perf-09.json` · **Tier:** Campaign.

**Acceptance:** Within the detector-specific observation-horizon and release timing contract frozen at G5.

### B-PERF-10 — Uncached refresh/source-starved request

**Method:** Measure with empty reservoir, absent input and delayed health coverage. Include acquisition/holdback time. At 16 kbit/s, 240 ideal entropy bits alone take 15 ms; actual required seed and loss may increase this.

**Artifact:** `bench/b-perf-10.json` · **Tier:** Campaign.

**Acceptance:** Meets the bounded-wait or nonblocking-error API policy frozen at G5; no cached-latency promise applied.

### B-VER-10 — Epoch/revocation protocol

**Method:** Model/test alarm during copy/commit, health silence, timer fault, source failure, generator/API crash, reinitialization and counter exhaustion. Requalify across PDs at G6.

**Artifact:** `bench/b-ver-10.json` · **Tier:** Commit.

**Acceptance:** All state transitions satisfy the release contract; old sessions/epochs and expired leases are rejected.

### B-VER-11 — ICA/ORA anti-replay

**Method:** Local non-Copy compile-fail tests plus receiver-ledger/model tests: duplicates, overlaps, reorder, wrong issuer/channel/configuration, old boot session/epoch, expiry, partial consumption and restart. ICA and ORA are distinct types and ledgers.

**Artifact:** `bench/b-ver-11.json` · **Tier:** Commit.

**Acceptance:** No ID/range can be consumed twice at its trusted receiver; replayed serialized bytes are rejected.

### B-ROB-07 — Tamper/fault scope battery

**Method:** 20 trials per exploratory attack with count/bound reported; formal ≥0.99 detector claims use B-HLT-01 counts. Cover observation, illumination, cold/heat, faulted acquisition, explicit replay patterns and driver faults within declared trust scope.

**Artifact:** `bench/b-rob-07.json` · **Tier:** Campaign.

**Acceptance:** Every in-scope scenario has its specified result; out-of-scope cases are labelled, never counted as passes.

### B-INT-09 — Release commit protocol

**Method:** Test physical fault at window end, absent covering verdict, health alarm during snapshot and commit, permit exhaustion, request cancellation, queued work, reinitialization and partial-fill errors. Reject after closure; account for pre-close committed chunks and inaccessible/uncommitted bytes.

**Artifact:** `bench/b-int-09.json` · **Tier:** Campaign.

**Acceptance:** Snapshot/permit/epoch/lease validation and bounded commit obey the frozen contract under every enumerated interleaving.

### B-INT-11 — Snapshot and authorization binding

**Method:** Mutate producer memory before/during/after snapshot and after test. Private snapshot changes are prevented by permissions. Verify tags on the consumed snapshot if used. Test ICA credit and ORA release separately; no single record authorizes both unbounded operations.

**Artifact:** `bench/b-int-11.json` · **Tier:** Campaign.

**Acceptance:** Consumed bytes are the tested immutable snapshot; altered identity/range/configuration/provenance is rejected.

## Evidence completeness at G5

Reviewed detector rationale, uncertainty-aware defect mapping, campaign plan/results, snapshot/ICA/ORA protocol and local commit-state model; real startup invalidates earlier provisional restart assumptions where changed.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M5
make verify PROFILE=reference
make gate G5 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
