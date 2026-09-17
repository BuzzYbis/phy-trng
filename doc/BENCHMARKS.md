# Phy-TRNG — Benchmark Specification

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

This is the canonical benchmark registry. Gate and milestone tables reference these IDs. Numeric engineering targets are distinguished from normative claims, provisional aspirations and configuration-specific bounds. All reported results name a boundary and qualified build profile.

## 1. Statistical acceptance rules

Default detection/false-alarm intervals are **one-sided 95%**, per declared scenario. With n independent successes and zero failures:

- Success lower bound: `p_L = 0.05^(1/n)`.
- Failure upper bound: `q_U = 1 - 0.05^(1/n)` (approximately `3/n`).
- 299 zero-miss trials support `p_L ≈0.99003085`.
- 2,995 zero-miss trials support `p_L ≥0.999`.
- 3,000,000 zero-alarm opportunities support `q_U <10^-6`.

For k>0 failures, use the exact one-sided Clopper–Pearson bound with the predeclared n and acceptance rule. A point estimate k/n is not a confidence bound. Specify trials, independence, event unit, stopping rule and aggregation before acquisition. Avoid optional stopping unless a valid sequential method is selected in advance. Reinitializing every trial does not represent a deployed continuous-history detector unless justified.

Per-scenario intervals do not imply simultaneous campaign confidence. State the family and apply a predeclared correction when claiming a simultaneous guarantee. Predictor falsification uses a separate 1% family-wise threshold with held-out data. Do not pool distinct fault classes or conditions to improve a weak class's interval.

At true false-alarm probability 10^-6, observing zero in 3,000,000 trials occurs with probability about 0.0498. Thus design the nominal rate below the acceptance ceiling, or predeclare more trials and acceptance of some events. Report all alarms, not just the successful segment of a campaign.

## 2. Environmental matrix and campaign manifest

Supported candidate envelope: temperature T1=5°C, T2=25°C, T3=45°C; voltage V1=nominal−5%, V2=nominal, V3=nominal+5%; lamp L1=warming, L2=steady; ambient A1=dark room, A2=office, A3=direct sunlight on enclosure. This is **54 cells**. Sensor temperature and mean/clipping/read-noise parameters are logged separately from ambient labels. Warming has an explicitly defined time trajectory, not an assumed stationary equilibrium.

Reference cell: T2-V2-L2-A2. Every cell is supported by default for planning, pending M0/G2 qualification. If a physical combination cannot exist or cannot support the model, record a justified exclusion and narrow the advertised envelope before accepting the campaign. No silent reduction to 'about 25 points'.

| Cell IDs (all three ambient conditions per row) | Temperature | Voltage | Lamp |
|---|---|---|---|
| T1-V1-L1-A1, T1-V1-L1-A2, T1-V1-L1-A3 | 5°C | −5% | warming |
| T1-V1-L2-A1, T1-V1-L2-A2, T1-V1-L2-A3 | 5°C | −5% | steady |
| T1-V2-L1-A1, T1-V2-L1-A2, T1-V2-L1-A3 | 5°C | nominal | warming |
| T1-V2-L2-A1, T1-V2-L2-A2, T1-V2-L2-A3 | 5°C | nominal | steady |
| T1-V3-L1-A1, T1-V3-L1-A2, T1-V3-L1-A3 | 5°C | +5% | warming |
| T1-V3-L2-A1, T1-V3-L2-A2, T1-V3-L2-A3 | 5°C | +5% | steady |
| T2-V1-L1-A1, T2-V1-L1-A2, T2-V1-L1-A3 | 25°C | −5% | warming |
| T2-V1-L2-A1, T2-V1-L2-A2, T2-V1-L2-A3 | 25°C | −5% | steady |
| T2-V2-L1-A1, T2-V2-L1-A2, T2-V2-L1-A3 | 25°C | nominal | warming |
| T2-V2-L2-A1, T2-V2-L2-A2, T2-V2-L2-A3 | 25°C | nominal | steady |
| T2-V3-L1-A1, T2-V3-L1-A2, T2-V3-L1-A3 | 25°C | +5% | warming |
| T2-V3-L2-A1, T2-V3-L2-A2, T2-V3-L2-A3 | 25°C | +5% | steady |
| T3-V1-L1-A1, T3-V1-L1-A2, T3-V1-L1-A3 | 45°C | −5% | warming |
| T3-V1-L2-A1, T3-V1-L2-A2, T3-V1-L2-A3 | 45°C | −5% | steady |
| T3-V2-L1-A1, T3-V2-L1-A2, T3-V2-L1-A3 | 45°C | nominal | warming |
| T3-V2-L2-A1, T3-V2-L2-A2, T3-V2-L2-A3 | 45°C | nominal | steady |
| T3-V3-L1-A1, T3-V3-L1-A2, T3-V3-L1-A3 | 45°C | +5% | warming |
| T3-V3-L2-A1, T3-V3-L2-A2, T3-V3-L2-A3 | 45°C | +5% | steady |

Out-of-range tests are separate: unlit/solid lamp with a dark sensor, overheated/saturated sensor, temperatures beyond the qualified range, disconnected/frozen/clock-faulted source and out-of-scope replay demonstrations. Correct refusal can pass these tests; do not require T_irn data from a condition required to refuse output.

The campaign manifest records cell ID, supported/excluded status, exclusion rationale, equilibration/trajectory protocol, unit serial number, firmware/configuration, acquisition IDs and separate extrema for minimum entropy, maximum false-alarm risk, maximum detection delay and performance. Environmental transitions and post-burn-in measurements are additional conditions, not invented extra axes in a nominal product table.

## 3. Entropy notation and unit discipline

`H_model`, `H_submitter`, `H_original`, `H_I`, `H_r`, `H_c`, `H_90B` and `h_credit` follow ARCHITECTURE §5. In particular H_I includes H_submitter as prescribed by 90B, and runtime h_credit is derived afterward. Normalize bits/sample to bits/bit explicitly before applying the project's 50% margin. A rejected 90B assessment cannot be salvaged merely by selecting a smaller credit.

Stage 1 and Stage 2 each have an independent analytic transfer argument. B-ENT-06/08 are implementation regressions. Testing generated output never measures seed-state entropy. Performance limits derived from credited lower bounds are policy constraints, not physical upper bounds.

## 4. Canonical registry

All items require their stated artifacts and machine-readable result. Review items hold signed/identified review records and accepted dispositions; no document implies an achieved result.

### B-STAT-01 — PTG.3 T_irn

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** All four T_irn tests pass under the declared repetition rule; reference condition at G4, qualified supported envelope at G7.

**Method:** Collect 2,040,000 consecutive PTG.3 output bits. Monobit: 20,000 bits, accept 9655–10345 inclusive. Poker: 20,000 bits/5,000 4-bit words, accept 1.03–57.4 inclusive. MultiMMC: 1,000,000 bits, k=2/D=16, min-entropy statistic ≥0.95. LZ78Y: 1,000,000 bits, k=2/B=16, statistic ≥0.95. Apply KS24 ¶904–914 and at most one permitted whole-suite repetition per assessment/condition; preserve every result. A logged debug run never becomes a qualifying extra retry. Record tool versions, parameter matching, min/max values and boundary. This is statistical inconspicuousness, not B-ARG-09.

**Artifact:** `bench/b-stat-01.json`.

### B-STAT-02 — SP 800-22 diagnostic sweep

**First gate:** G4 · **Level:** ADVISORY · **Tier:** Campaign

**Acceptance:** Report all applicable test outcomes; investigate anomalies. Advisory; no entropy claim.

**Method:** Use 1,000 sequences of 10^6 bits at a named boundary. Predeclare significance, proportion intervals, uniformity criteria and treatment of tests with insufficient eligible sequences. No rerun-until-pass and no use as seeding/extraction evidence.

**Artifact:** `bench/b-stat-02.json`.

### B-STAT-03 — Raw characterization

**First gate:** G1 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Complete labelled characterization at ≥4 supported cells by G1; full selected campaign set by G2. No arbitrary raw-randomness pass threshold.

**Method:** Report pixel bias; spatial correlation with uncertainty; temporal lags 1–64; full-value mean/variance; shared row/column noise; read-noise estimation method; frame/sample sequence gaps. Distinguish selected ROI cadence from accidental missing samples. Record actual dropped frames separately from silent drops.

**Artifact:** `bench/b-stat-03.json`.

### B-STAT-04 — DRG.4 T_irn

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Same specified T_irn suite passes at the separate DRG.4 boundary; reference at G4, final profile at G7.

**Method:** Use B-STAT-01 parameters and repeat policy on DRG.4 output. Label as computational output, never a physical entropy assessment.

**Artifact:** `bench/b-stat-04.json`.

### B-ENT-01 — 90B sequential assessment

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** 90B assessment succeeds, and final h_credit is ≤0.5×min(H_model,H_90B) after restart assessment.

**Method:** Use ≥1,000,000 contiguous raw samples per supported cell, full applicable non-IID track, all estimator outputs and versions. Define H_submitter separately from runtime h_credit. Binary H_I=min(H_original,H_submitter); non-binary assessment follows §3.1.3 including bitstring track and unit conversion. An estimator disagreement triggers model/data investigation. Do not test conditioned/DRBG output to infer source entropy.

**Artifact:** `bench/b-ent-01.json`.

### B-ENT-02 — 90B restart assessment

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Prescribed sanity check passes; min(H_r,H_c)≥H_I/2; derive H_90B=min(H_r,H_c,H_I), then apply the runtime margin.

**Method:** Define a restart representative of deployment, including startup inhibition and warm-up, then collect 1,000 restarts ×1,000 samples as specified in 90B §3.1.4. Record all row/column/sanity results; no invented exemption from validation. Requalify after M5 changes startup behavior. H_submitter is not silently set to h_credit: doing so while demanding H_90B≥2h_credit would be contradictory.

**Artifact:** `bench/b-ent-02.json`.

### B-ENT-03 — Model-tailored predictors

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** No held-out predictor result rejects the declared model under the predeclared multiplicity-adjusted decision rule.

**Method:** At least spatial, temporal, illumination-conditioned and shared-readout predictors on ≥10^7 raw bits each where applicable. Separate fitting/tuning and validation captures. Declare each null bound and dependence assumptions; control the campaign family-wise false-rejection probability at 1% using a specified method such as Holm adjustment. Report adjusted and unadjusted results and the assumption attacked.

**Artifact:** `bench/b-ent-03.json`.

### B-ENT-04 — Runtime claim margin

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** h_credit≤0.5×min(H_model,H_90B) across the supported envelope; credits rounded down.

**Method:** Check units and the model-derived bound for the actual accepted-block regime. Apply the margin after successful 90B assessment. Record model/estimator uncertainty and configuration. This project margin is not a NIST requirement or a repair for a false physical model.

**Artifact:** `bench/b-ent-04.json`.

### B-ENT-06 — Stage 1 implementation regression

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Exact vectors and structural tests pass; selected configuration matches B-ARG-01. No empirical extraction theorem claimed.

**Method:** Test map/reference agreement, dimensions, bit ordering, full-rank/degeneracy checks where relevant, and model-predicted behavior for biased Bernoulli, Markov, periodic-noisy, sparse and adversarial fixtures plus real captures. Fixed-map full rank does not establish entropy transfer. Synthetic fixtures generated by a PRNG simulate distributions. Intermediate v_m is a lower-bound claim: output is neither required nor expected to fail T_irn.

**Artifact:** `bench/b-ent-06.json`.

### B-ENT-07 — Dependence and model-parameter support

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Measurements do not contradict the model assumptions after uncertainty/dependence treatment; B-ARG-01/05 independently justify the actual extraction block.

**Method:** Measure small joint blocks (2/4/8/16 selected bits), conditional distributions, illumination strata and shared readout structure on held-out data. Direct small-alphabet estimates require finite-sample bounds. A 16-bit alphabet has up to 65,536 symbols; for 90B use its prescribed ≤256-symbol reduction and bitstring procedure, documenting losses and units. Do not equate a reduced-alphabet estimate with full-block entropy or extrapolate 16-bit measurements to N_raw without the physical dependence argument.

**Artifact:** `bench/b-ent-07.json`.

### B-ENT-08 — Seeding implementation regression

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Seeding/reseeding matches the selected reference and vectors; entropy-insufficient paths reject; no output statistic is used to infer state entropy.

**Method:** Check seed-input provenance, state-transition vectors, counters, domain separation, effective-state encoding, previous-state/additional-input cases and insufficient-credit behavior. Compare an independent implementation. Controlled low-entropy fixtures test plumbing only. B-ARG-03 alone supplies the state entropy-transfer argument.

**Artifact:** `bench/b-ent-08.json`.

### B-ARG-01 — Stage 1 extraction

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** A source-specific conditional block bound is transferred through the selected map. Independent review accepted; no unresolved substantive objection.

**Method:** State route applicability, actual map, input dependencies, conditioning variables, accepted-data selection effects, seed/index distribution, secrecy, reuse policy and cost. Distinguish fixed-map analysis from a randomized-family theorem. Prove the claimed v_m; ratios and matrix rank alone are insufficient. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-01.md`.

### B-ARG-02 — Generator construction security

**First gate:** G3 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** Chosen construction supports the selected DRG.3/DRG.4 properties. Independent review accepted; no unresolved substantive objection.

**Method:** Specify the nine-tuple, request/persistent state evolution, irreversible update assumptions, additional input, domain separation, arbitrary-time state exposure, enhanced-backward-secrecy granularity, conceptual atomicity if selected, erasure scope and known security limits. Cover each applicable DRG.3.3 and .5–.9 and DRG.4 security obligation. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-02.md`.

### B-ARG-03 — DRG.4 seeding/refresh transfer

**First gate:** G3 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** Each qualifying DRG.4 seeding or refresh establishes ≥240 bits min-entropy in the effective state. Independent review accepted; no unresolved substantive objection.

**Method:** Analyze the complete transfer from qualified PTG.3 seed to effective state, with personalization, previous state and adversary knowledge. State effective state size separately from entropy. Explain reservoir freshness, compromise scope, non-reuse and entropy losses. No test of generated output can discharge this item. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-03.md`.

### B-ARG-04 — Two-instance composition

**First gate:** G3 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** PTG.3 and DRG.4 have separate state, acyclic seeding and explicit boundary/range accounting. Independent review accepted; no unresolved substantive objection.

**Method:** Show PTG.3 output consumption, seed reservations, bounded computational expansion, output provenance and release authority. Give the boundary for every benchmark and counter. Specify trust in generator correctness separately from hostile-generator release confinement. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-04.md`.

### B-ARG-05 — Stochastic source model

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** Physical model and conditional block assumptions are substantiated and independently reviewed. Independent review accepted; no unresolved substantive objection.

**Method:** P~Poisson(lambda), deterministic Q(gP+R+b), calibrated parameters/uncertainty, dark current and shared readout treatment, time-local stationarity, environmental support, conditional dependence, model predictions and limits. Wax receives zero credit; environment still changes the parameters. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-05.md`.

### B-ARG-06 — Effective compression

**First gate:** G3 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** PTG.3.4 c_rate≥1 per intermediate input, with all internal bottlenecks and output counts accounted for. Independent review accepted; no unresolved substantive objection.

**Method:** Use minimum guaranteed n_int for variable inputs, no sliding averages, actual intermediate mapping widths and generated (not merely delivered) output. Demonstrate why KS24 ¶388 pathology cannot occur. Width/compression compliance does not discharge PTG.3.5. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-06.md`.

### B-ARG-07 — Acquisition integrity

**First gate:** G1 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** A-ACQ-1 and monitor limitations are explicit and consistent with the chosen hardware boundary. Independent review accepted; no unresolved substantive objection.

**Method:** Review physical/interface/software trust, access protection, sensor configuration and firmware controls, out-of-scope replay, failure-detector scope and user guidance. Update after target integration; authenticated freshness is not claimed unless implemented and qualified. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-07.md`.

### B-ARG-08 — Assumptions and complete TCB

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** Every gate-active assumption has scope, consequence, owner and acceptance status; final register includes all supporting dependencies. Independent review accepted; no unresolved substantive objection.

**Method:** Independent review starts with M0-active assumptions and expands at each gate. Include acquisition, DMA, primitive proof scope, concurrent memory model, zeroization, clock, fault service, boot/scheduling configuration, compiler/library/kernel/platform dependencies. A document entry does not itself prove an assumption. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-08.md`.

### B-ARG-09 — PTG.3 Stage 2 output entropy

**First gate:** G3 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** The selected explicit PTG.3.5 min-entropy bound holds for the complete Stage 2 mapping under its declared assumptions. Independent review accepted; no unresolved substantive objection.

**Method:** Follow KS24 ¶391–413 for the chosen construction. Specify n_int, intermediate block entropy, old-state conditioning, reseed/absorb mappings, bottlenecks, final output map, truncation, m_ptg and the applicable undercut probability (including the 2^-16 criterion where applicable). Account for latest-input credit per ¶402. Derive v_out≥0.98 for the selected claim; 240 seeded-state bits, c_rate≥1, width and T_irn do not substitute. Freeze the attainable throughput only after this argument closes. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-09.md`.

### B-HLT-01 — Total failure coverage

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Per in-scope class, a one-sided 95% detection lower bound ≥0.99; default 299 independent trials with zero misses. Release behavior meets its declared deterministic/probabilistic scope.

**Method:** Inject occlusion, flood, power removal, data interruption, clock stop, frozen frames and specifically named replay patterns. General varied-video replay is outside A-ACQ-1. Vary onset across frame/window/commit phases. Record fault, detection, close and commit timestamps plus contributing sequence ranges. No claim of structural detection from a statistical pass.

**Artifact:** `bench/b-hlt-01.json`.

### B-HLT-02 — Detection timing

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Observed maximum ≤2 frames for specified hard failures; separate justified bounds for other classes. Required worst-case claims also have an analytic scheduling/detector argument.

**Method:** Use B-HLT-01 trials with clock uncertainty and onset phase. Report full distribution and observed maximum, not a claimed universal p100. Distinguish physical fault detection from propagation to release and final commit closure. The clock/lease assumptions are explicit.

**Artifact:** `bench/b-hlt-02.json`.

### B-HLT-03 — Output-referred online sensitivity

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** At the predeclared source-degradation cases corresponding to an assured-output defect boundary of 0.02 min-entropy/bit, detection lower bound ≥0.99 within its window.

**Method:** Map controlled sigma/illumination/clipping/dependence changes through B-ARG-05/01/09, including parameter uncertainty. Distinguish a proved upper/lower interval for actual output entropy from a conservative lower bound that merely falls below the claim. Label the latter loss of assurance, not measured actual defect. Choose physical/synthetic injections accordingly. Default 299 zero-miss trials per scenario with individually stated confidence. No Shannon variant required in v1. Report detection-versus-degradation curves, not an incorrectly labelled ROC unless false-positive rate is also varied.

**Artifact:** `bench/b-hlt-03.json`.

### B-HLT-04 — Online false-alarm probability

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** One-sided 95% upper bound ≤10^-6 per declared independent test opportunity at each required false-alarm worst case. Default 3,000,000 opportunities with zero alarms.

**Method:** Predeclare window/stride and independence or a justified dependent-event model; nominal operation must preserve the deployed history rather than resetting it away. Worst false-alarm cells are selected independently of minimum-entropy and slowest-detection cells. Use exact binomial bounds if assumptions apply. A predeclared larger-n acceptance plan may permit alarms. A weaker achieved bound is a failed gate unless the specification is explicitly revised. Derive wall clock from opportunity cadence.

**Artifact:** `bench/b-hlt-04.json`.

### B-HLT-05 — Startup efficacy

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Per fault class, one-sided 95% lower bound ≥0.999; default 2,995 independent zero-miss trials; qualified startup-test phase ≤500 ms including declared exclusions.

**Method:** Test stuck-at, model-incompatible short periods and selected severe biases plus applicable total failures. Justify severity relative to the model, rather than generic bias alone. Distinguish test execution, sensor power-up/warm-up and total first-output latency. No startup authorization before success. Document a wider required platform budget if measurements demand it before qualification.

**Artifact:** `bench/b-hlt-05.json`.

### B-HLT-06 — 90B RCT/APT

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Independent cutoff calculation matches the selected 90B method; target failures detected; false-alarm **upper confidence bound**, not observed proportion, ≤ configured alpha=2^-20.

**Method:** Define sample alphabet, entropy estimate, cutoff convention, window and per-opportunity event unit for each test. Use the exact standard algorithms including startup/continuous behavior. Publish counts, bounds and dependence assumptions. Very low false-alarm rates are allowed. RCT/APT complement the source-model online tests; they do not replace them.

**Artifact:** `bench/b-hlt-06.json`.

### B-PERF-01a — Raw acquisition rate

**First gate:** G1 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** ≥1 Mbit/s sustained for 1 h; zero silent gaps; report all observed drops.

**Method:** Reference profile capture with frame/sample IDs and timing. A qualification capture used as contiguous data has zero unexplained gaps. A deliberate sampling cadence is part of the model.

**Artifact:** `bench/b-perf-01a.json`.

### B-PERF-01b — Intermediate rate

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Within 5% of the accepted-input rate and actual Stage 1 map schedule, after accounting for rejects and seed overhead.

**Method:** Report raw accepted/rejected rates, r_ext, variable-output/seed costs where applicable and measurement duration.

**Artifact:** `bench/b-perf-01b.json`.

### B-PERF-01c — Qualified PTG.3 rate

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Meets the positive target frozen by G3 and never exceeds the justified output schedule. 16 kbit/s remains an aspiration until B-ARG-09 closes.

**Method:** Count all generated PTG.3 bits, including seed material and discarded output. Reconcile credited input, theorem losses, buffering inventory and final output lengths; use a steady-state interval. Exceeding a lower-credit budget is a justification failure, not proof of excess physical entropy.

**Artifact:** `bench/b-perf-01c.json`.

### B-PERF-01d — DRG.4 computational rate

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Measured at its own boundary with correct request/refresh enforcement; no physical entropy-rate claim.

**Method:** Report generated and delivered rates, request size/load, refresh/reservoir behavior, blocking and dropped/failed requests.

**Artifact:** `bench/b-perf-01d.json`.

### B-PERF-02 — Buffered warm request latency

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** For the declared available-buffer workload, target p50≤1 ms, p99.9≤5 ms; observed max≤20 ms. Freeze applicability at G3/G4.

**Method:** Measure 10^6 32-byte requests with stated offered load, queue depth, source readiness and target frequency. Report full distribution, failures and attribution; do not exclude refresh events silently. This is not a cold or source-starved bound.

**Artifact:** `bench/b-perf-02.json`.

### B-PERF-03 — Buffered latency ratio

**First gate:** G4 · **Level:** ADVISORY · **Tier:** Campaign

**Acceptance:** Report p99.9/p50; target ≤5 under B-PERF-02 conditions.

**Method:** Report absolute latency alongside ratio; measurement resolution must support p50.

**Artifact:** `bench/b-perf-03.json`.

### B-PERF-04 — Selected primitive performance

**First gate:** G3 · **Level:** ADVISORY · **Tier:** Campaign

**Acceptance:** Report cycles/operation and cycles/byte against a matched ISA/configuration baseline.

**Method:** Keccak only if selected; SHA-256 if selected. Compare the exact qualified implementations at matched sizes/compiler/clock. A ≤1.2× assembly or ≤3× soft ratio is advisory where a comparable baseline exists; a slow soft ratio alone does not prove source throughput failure.

**Artifact:** `bench/b-perf-04.json`.

### B-PERF-05 — Health CPU share

**First gate:** G5 · **Level:** ADVISORY · **Tier:** Campaign

**Acceptance:** Target ≤25% of one reference core at selected raw rate; report worst supported load.

**Method:** Include snapshot copy, all tests, metadata and authorization issuance, with warm/cold caches and rate variation.

**Artifact:** `bench/b-perf-05.json`.

### B-PERF-06 — Cold boot to first output

**First gate:** G5 · **Level:** ADVISORY · **Tier:** Campaign

**Acceptance:** Report p50/p99/observed max and phase breakdown; aspiration ≤2 s subject to the physical warm-up envelope.

**Method:** 100 independent cold boots including configuration, KAT, warm-up, startup tests, fresh entropy acquisition and seeding. Qualify any advertised bound on the selected envelope.

**Artifact:** `bench/b-perf-06.json`.

### B-PERF-07 — Cached refresh latency

**First gate:** G4 · **Level:** ADVISORY · **Tier:** Campaign

**Acceptance:** Target ≤10 ms when qualifying reserved seed is already available; prove reservoir freshness/non-reuse policy separately.

**Method:** Measure transfer, state update and accounting. Reservoir age, authorization lifetime and compromise scope recorded. Never include unexplained wait time in a claim labelled cached.

**Artifact:** `bench/b-perf-07.json`.

### B-PERF-08 — Cross-PD overhead

**First gate:** G6 · **Level:** ADVISORY · **Tier:** Campaign

**Acceptance:** Report throughput and latency at all boundaries; target ≤15% throughput loss against the same functional/release configuration.

**Method:** Match block sizes, source rate, backend, clock and health/release policy to the single-address-space comparison. Do not compare a stub-health baseline with the full deployment.

**Artifact:** `bench/b-perf-08.json`.

### B-PERF-09 — Quarantine and commit delay

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Within the detector-specific observation-horizon and release timing contract frozen at G5.

**Method:** Report raw-block last-sample to eligibility, eligibility to commit, alarm-to-close and outstanding authorized bytes. Include worst onset phase and scheduling uncertainty. A covering-window completion alone is insufficient.

**Artifact:** `bench/b-perf-09.json`.

### B-PERF-10 — Uncached refresh/source-starved request

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Meets the bounded-wait or nonblocking-error API policy frozen at G5; no cached-latency promise applied.

**Method:** Measure with empty reservoir, absent input and delayed health coverage. Include acquisition/holdback time. At 16 kbit/s, 240 ideal entropy bits alone take 15 ms; actual required seed and loss may increase this.

**Artifact:** `bench/b-perf-10.json`.

### B-PERF-11 — Release revocation timing

**First gate:** G6 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** No commit after the specified release-local closure point; alarm/expiry-to-close and pre-close exposure stay inside the frozen bounds.

**Method:** Record t_fault/t_alarm/t_close/commit, independent clock tolerance, pending ORAs, maximum chunk and non-preemptible section. Test scheduler contention, timer failure and hostile generation. Use finite permit budgets rather than average throughput to bound exposure.

**Artifact:** `bench/b-perf-11.json`.

### B-FOOT-01 — Application text size

**First gate:** G4 · **Level:** ADVISORY · **Tier:** Commit

**Acceptance:** Reference portable-core aspiration ≤24 KiB; G3 freezes the actually selected profile budget.

**Method:** Final linked .text/.rodata breakdown per profile/backend; do not apply a Cortex-M core budget to the full seL4 camera image.

**Artifact:** `bench/b-foot-01.json`.

### B-FOOT-02 — RAM and buffers

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** All static allocations and configured buffers fit the frozen per-profile memory budget.

**Method:** Report state, stack, frame/DMA, snapshots, raw/intermediate rings, seed reservoir, staging, commit buffers and replay ledgers separately. The legacy ≤8 KiB non-buffer target is advisory; excluded buffers remain in the system total.

**Artifact:** `bench/b-foot-02.json`.

### B-FOOT-03 — Stack bound

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Peak stack ≤ selected profile bound (2 KiB core target); static safe upper bound covers measured watermark.

**Method:** Use static call/interrupt analysis and high-water testing; a conservative static bound need not agree within 10%. Record differences and interrupt/FFI assumptions.

**Artifact:** `bench/b-foot-03.json`.

### B-FOOT-04 — No runtime heap

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Zero reachable allocation operations in runtime entry points of qualified profiles.

**Method:** Analyze final linked images, imports and transitive allocation paths; scan allocator symbols as a complementary check. Tool/host allocations are outside runtime.

**Artifact:** `bench/b-foot-04.json`.

### B-FOOT-05 — No reachable panic

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Zero reachable panic paths for production runtime entry points.

**Method:** Combine proof obligations with linked analysis; missing panic_fmt alone is not sufficient if another panic/abort path exists. Fault handling remains a specified system action.

**Artifact:** `bench/b-foot-05.json`.

### B-FOOT-06 — Unsafe scope

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Zero project unsafe outside the permitted module/crate list; all unsafe/trusted dependencies enumerated.

**Method:** Allow HAL, selected FFI/hardware backends, low-level synchronization/zeroization and seL4 glue. Report transitive dependency scope separately from first-party token counts.

**Artifact:** `bench/b-foot-06.json`.

### B-FOOT-07 — TCB inventory and review size

**First gate:** G6 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Complete application/support/dependency TCB inventory; unexplained omissions fail.

**Method:** Report release application logic separately (≤300 SLOC review target) and first-party entropy-boundary logic (≤3,000 SLOC target). Include timer/fault/boot/scheduling/SMMU configuration, libs, compiler/kernel/platform assumptions. Targets do not exclude dependencies or substitute for security review.

**Artifact:** `bench/b-foot-07.json`.

### B-VER-01 — Mandatory obligations and annotation coverage

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Every mandatory property discharged; zero admitted/skipped/unresolved/timed-out obligations. Report annotation coverage ≥95%, 100% for core/ring/release/state machines.

**Method:** Maintain property inventory and assumption map. Trusted contracts are separate assumptions with approvals, never reported as proofs. Test-harness-only obligations at G4 cannot qualify production release.

**Artifact:** `bench/b-ver-01.json`.

### B-VER-02 — Proof replay

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Scheduled

**Acceptance:** All gate-active mandatory proofs replay; toy pipeline at G0, full reference target ≤20 min local/≤45 min scheduled target by G4.

**Method:** Replay the pinned Rust/Creusot, Why3 and solver pipeline, with library specifications and proof-session hashes. Cold/warm timings and per-obligation results. A time target cannot excuse an unresolved proof; gate distinguishes performance target from proof success.

**Artifact:** `bench/b-ver-02.json`.

### B-VER-03 — Panic freedom and termination

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Mandatory obligations for all production deterministic components discharge; linked checks agree.

**Method:** Include error paths, length conversions, fixed-point rounding, counter saturation and loop variants. State trusted HAL/FFI assumptions explicitly.

**Artifact:** `bench/b-ver-03.json`.

### B-VER-04 — Trusted-boundary inventory

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** Every trust item has spec, scope, owner, rationale and control; baseline ≤12 review entries or explicitly revised design inventory.

**Method:** Review semantic breadth, not just annotation count. One giant trusted function is not a small trust boundary. Record crypto and compiler artifact scope.

**Artifact:** `bench/b-ver-04.json`.

### B-VER-05 — Output eligibility

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** No output path from uninitialized/failed/expired context; dynamic epoch and lease checks are proved at runtime, not claimed as compile-time revocation.

**Method:** Compile-fail tests for non-Ready types; runtime/model proofs for remote epoch changes, lease expiry and commit eligibility. G4 covers local prototype only; G5/G6 add real health/release.

**Artifact:** `bench/b-ver-05.json`.

### B-VER-06 — Entropy accounting

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Tagged accounts cannot overcredit, wrap, double-consume or refund used entropy; transfers match B-ARG-01/03/09.

**Method:** Prove credited/debited balance, disjoint sample ranges, downward credit/upward debit rounding, failed-call behavior, state cap and finite inventory accounting. Claim parameter validation is part of input preconditions.

**Artifact:** `bench/b-ver-06.json`.

### B-VER-07 — Sequential ring

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** FIFO, capacity, returned-count bounds, initialization, no unread overwrite, empty/full distinction, peek lifetime, panic freedom and termination proved.

**Method:** Reference queue property tests plus obligations. Explicitly sequential/cooperative semantics; no claim of ISR/cross-domain ordering proof.

**Artifact:** `bench/b-ver-07.json`.

### B-VER-08 — Selected backend differential agreement

**First gate:** G3 · **Level:** BLOCKING · **Tier:** Scheduled

**Acceptance:** Selected backend matches an independent oracle and applicable KATs on 10^6 host cases and 10^4 target cases.

**Method:** A selected Formosa artifact is compared where supported; soft-only and SHA-256 profiles use an appropriate independent reference. Message/state boundary cases include all-zero, all-one, single bits and rate/block limits ±1. Applicability is decided by the build matrix; no empty/oracle-identical comparison counts.

**Artifact:** `bench/b-ver-08.json`.

### B-VER-09 — Hostile transport safety

**First gate:** G6 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Arbitrary partner-controlled indices cannot cause out-of-bounds access/overflow; proof discharges and 24 h adversarial fuzz campaign is clean.

**Method:** Read shared values into checked local snapshots before use, with specified memory semantics. Fuzz mutation between loads, wrap values, inconsistent lengths and slot reuse. This does not prove physical provenance or sample integrity.

**Artifact:** `bench/b-ver-09.json`.

### B-VER-10 — Epoch/revocation protocol

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** All state transitions satisfy the release contract; old sessions/epochs and expired leases are rejected.

**Method:** Model/test alarm during copy/commit, health silence, timer fault, source failure, generator/API crash, reinitialization and counter exhaustion. Requalify across PDs at G6.

**Artifact:** `bench/b-ver-10.json`.

### B-VER-11 — ICA/ORA anti-replay

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** No ID/range can be consumed twice at its trusted receiver; replayed serialized bytes are rejected.

**Method:** Local non-Copy compile-fail tests plus receiver-ledger/model tests: duplicates, overlaps, reorder, wrong issuer/channel/configuration, old boot session/epoch, expiry, partial consumption and restart. ICA and ORA are distinct types and ledgers.

**Artifact:** `bench/b-ver-11.json`.

### B-ROB-01 — Supported-envelope qualification

**First gate:** G7 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** PTG.3 T_irn and relevant entropy/model checks pass for all 54 supported cells, unless an exclusion was explicitly approved before campaign.

**Method:** Cells defined in BENCHMARKS §2. Pruning requires a named configuration constraint and updated advertised envelope; no informal approximation to 25 cells. Include transitions/aging checks separately.

**Artifact:** `bench/b-rob-01.json`.

### B-ROB-02 — Entropy envelope sweep

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Model/assessment support h_credit in every supported cell; report distinct extrema for entropy and later detector metrics.

**Method:** Run sequential assessment and model checks with equilibration protocol; preserve failed runs and physically unavailable cells as unresolved rather than silently omitting.

**Artifact:** `bench/b-rob-02.json`.

### B-ROB-03 — Cold/out-of-range behavior

**First gate:** G2 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Each trial yields justified operation or a clean refusal; no unjustified output.

**Method:** At least 50 cold starts with conditions/observed outcomes reported (no unsupported 99.9% claim). Before real health at M5, acquisition/model verdicts are provisional. Out-of-range conditions are not required to emit T_irn data.

**Artifact:** `bench/b-rob-03.json`.

### B-ROB-04 — Thermal transitions

**First gate:** G7 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** No unexplained operation outside qualified bounds; detector/refusal behavior matches policy; model remains adequate.

**Method:** 50 cycles between supported extremes, 20 min dwell plus measured settling requirement; inspect cycles 1/25/50 and transition behavior. A fixed runtime credit should remain justified; report measured parameter/entropy drift. 10% drift is an investigation trigger, not a theorem or evidence that wax temperature is irrelevant.

**Artifact:** `bench/b-rob-04.json`.

### B-ROB-05 — Burn-in

**First gate:** G7 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** 500 h completes without unexplained claim violations; each alarm and trend adjudicated under predefined rules.

**Method:** Hourly diagnostics, health statistics, configuration readback and daily T_irn at the named boundary. Archive data/versions; preserve restart gaps and replaced hardware identity.

**Artifact:** `bench/b-rob-05.json`.

### B-ROB-06 — Restart storm

**First gate:** G7 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** 1,000/1,000 specified restart behaviors correct; report one-sided 95% lower success bound (~0.9970).

**Method:** Use the G2/M5-defined real restart process. Verify startup, fresh seed, no reuse of state/permits, new session/epoch initialization and no pre-startup output. Runtime restart and whole power loss may need separate cases.

**Artifact:** `bench/b-rob-06.json`.

### B-ROB-07 — Tamper/fault scope battery

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Every in-scope scenario has its specified result; out-of-scope cases are labelled, never counted as passes.

**Method:** 20 trials per exploratory attack with count/bound reported; formal ≥0.99 detector claims use B-HLT-01 counts. Cover observation, illumination, cold/heat, faulted acquisition, explicit replay patterns and driver faults within declared trust scope.

**Artifact:** `bench/b-rob-07.json`.

### B-INT-01 — Hostile-generator release confinement

**First gate:** G6 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** No direct client writes; no commit without valid current ORA, trusted issuer provenance and unused range; scope excludes randomness correctness of malicious staged data.

**Method:** Give attacker exactly generator capabilities. Confirm staging writes succeed, direct client writes fail, forged/wrong-channel authorization fails, replay/expired/old-epoch/overlap fails. Test a valid authorization separately: accepted bytes may be arbitrary, which is an explicit limit of confinement.

**Artifact:** `bench/b-int-01.json`.

### B-INT-02 — Raw containment

**First gate:** G1 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** No production external raw/evidence output; internal capabilities follow the entropy boundary.

**Method:** API/feature checks plus linked/configuration audit; at G6 add probe PD and all diagnostic/crash-report paths. Internal NoiseSource APIs legitimately carry raw types; do not require their disappearance from the whole workspace.

**Artifact:** `bench/b-int-02.json`.

### B-INT-03 — Byte request limit

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** 0 bytes is a no-op; 1–65,536 bytes admitted only when otherwise eligible; >65,536 rejected before mutation.

**Method:** Test 0,1,4096,65,535,65,536,65,537,usize::MAX without allocating an impossible buffer; test checked length-validation helper and real feasible buffers. Internal conversion enforces 2^19 bits.

**Artifact:** `bench/b-int-03.json`.

### B-INT-04 — Refresh bound and completion

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** No new generating request admitted at ≥2^17 generated bits since qualifying refresh; an already admitted ≤2^19-bit request may complete; next generating request blocks.

**Method:** Test exactly-before/at/after threshold, large requests, zero-length calls, partial errors and discarded output. Only qualifying refresh changes reseed generation. Alarm/lease expiry overrides completion. Show total generated bits before next refresh <2^17+2^19; report tighter block-aligned bound if applicable.

**Artifact:** `bench/b-int-04.json`.

### B-INT-05 — Effective state classification

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** ≥246 effective bits supported by the construction analysis; state capacity not confused with entropy.

**Method:** Inventory secret-dependent computational state, public counters and derived components. Justify classification using selected construction, not just storage size.

**Artifact:** `bench/b-int-05.json`.

### B-INT-06 — Seeding admission and provenance

**First gate:** G4 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** B-ARG-03 accepted; implementation consumes sufficient unique qualified seed and rejects insufficient/invalid input.

**Method:** Use source ICA and PTG.3 generation accounting plus seed reservations. Verify actual state transitions via B-ENT-08. A count of 240,000 input millibits alone is not the transfer argument.

**Artifact:** `bench/b-int-06.json`.

### B-INT-07 — Selected primitive KATs

**First gate:** G3 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Applicable official vectors pass and selected negative mutants are detected on qualified target.

**Method:** Use FIPS 202/185 for selected Keccak functions, FIPS 180-4 plus 90A vectors for selected SHA-2/DRBG. Record exact vector provenance. Corrupt a constant, an operation/order and output length as applicable; no unrelated primitive required.

**Artifact:** `bench/b-int-07.json`.

### B-INT-08 — Fault/timer handling

**First gate:** G6 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** All relevant component failures yield specified client/release behavior within declared bounds.

**Method:** Exercise genuine architecture-specific faults, infinite loop/watchdog, timer stall, health/generator/API crash and fault-handler failure handling. Unaligned access is not necessarily a fault on every ISA. Measure health-silence closure by expiry; do not claim immediate stop.

**Artifact:** `bench/b-int-08.json`.

### B-INT-09 — Release commit protocol

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Snapshot/permit/epoch/lease validation and bounded commit obey the frozen contract under every enumerated interleaving.

**Method:** Test physical fault at window end, absent covering verdict, health alarm during snapshot and commit, permit exhaustion, request cancellation, queued work, reinitialization and partial-fill errors. Reject after closure; account for pre-close committed chunks and inaccessible/uncommitted bytes.

**Artifact:** `bench/b-int-09.json`.

### B-INT-10 — DMA confinement/trust profile

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Enforced profile blocks out-of-region device writes with independently protected policy; otherwise A-DMA-1 explicit.

**Method:** M0 probe establishes feasible target approach; G6 repeats real misprogrammed-descriptor and stream-ID/policy tests across allowed/forbidden regions. Verify external memory unchanged and fault observed. Trusted profile has no enforcement result and weakens isolation claim; registry presence is not a hardware test.

**Artifact:** `bench/b-int-10.json`.

### B-INT-11 — Snapshot and authorization binding

**First gate:** G5 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** Consumed bytes are the tested immutable snapshot; altered identity/range/configuration/provenance is rejected.

**Method:** Mutate producer memory before/during/after snapshot and after test. Private snapshot changes are prevented by permissions. Verify tags on the consumed snapshot if used. Test ICA credit and ORA release separately; no single record authorizes both unbounded operations.

**Artifact:** `bench/b-int-11.json`.

### B-INT-12 — Acquisition monitor scope

**First gate:** G1 · **Level:** BLOCKING · **Tier:** Campaign

**Acceptance:** For each monitor, ≥0.99 per-class detection lower bound where claimed; demonstrated negative cases match documented limitations.

**Method:** Default 299 independent zero-miss positive trials; at least one documented non-detection scenario per limitation. A varied-video replay passing the freeze test is evidence of scope, not a detector success.

**Artifact:** `bench/b-int-12.json`.

### B-EVD-01 — Applicable evidence coverage

**First gate:** G1 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Every gate-active evidence item maps to a specific artifact; full selected set by G7.

**Method:** Use explicit applicability rather than a fixed superset of PTG.2 and PTG.3 items. Guidance remains useful even where an inner-PTRNG evidence ID is omitted.

**Artifact:** `bench/b-evd-01.json`.

### B-EVD-02 — Requirement traceability

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Every gate-active requirement has an owner and argument/proof/test plan; final selected PTG.3 and DRG.4 requirements have accepted evidence.

**Method:** Machine join IDs with artifacts, assumptions and gate status. Include DRG.4.1, .8 and .11 as well as request/state limits. No unknown ID or a statistical-only PTG.3.5 mapping.

**Artifact:** `bench/b-evd-02.json`.

### B-EVD-03 — Reproducible analysis and builds

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Clean tagged checkout reproduces deterministic build/analysis outputs under pinned configuration.

**Method:** Separate replaying archived acquisition analysis from physically recapturing entropy. Preserve raw data, metadata, tool hashes, seeds for synthetic fixtures, scripts, versions and applicable confidence settings. Reference external capture storage by hashes, not an assertion of identical future physical samples.

**Artifact:** `bench/b-evd-03.json`.

### B-EVD-04 — Independent argument review

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** Every gate-active B-ARG item has a non-author reviewer and accepted disposition; all nine completed by G7.

**Method:** Unresolved substantive objections keep the gate open. Review reports and script outputs are evidence, not fabricated attestations.

**Artifact:** `bench/b-evd-04.json`.

### B-EVD-05 — Build/data provenance

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Commit

**Acceptance:** Selected profile implementations, proof artifacts, toolchains, sensor firmware/configuration and data hashes recorded.

**Method:** Pin concrete versions and distinguish implementation functional proof, leakage proof and unsupported target claims. Conditional backend applicability is machine-readable.

**Artifact:** `bench/b-evd-05.json`.

### B-EVD-06 — Assumptions in guidance and ST

**First gate:** G0 · **Level:** BLOCKING · **Tier:** Review

**Acceptance:** All gate-active assumptions documented; final ST/guidance carry operational obligations and technical assurance limits appropriately.

**Method:** Not every toolchain/compiler assumption is an environmental ST assumption: map it to the correct assurance/TOE/environment category. User responsibilities appear in guidance; internal technical trust remains in the assurance case.

**Artifact:** `bench/b-evd-06.json`.

## 5. Selected-profile applicability

| Profile choice | Required oracle/vectors | Formosa requirement |
|---|---|---|
| Keccak + supported Formosa artifact | Applicable FIPS 202/185 vectors and independent implementation | Exact artifact scope and target comparison required |
| Keccak soft primary | Applicable vectors and independently implemented oracle | Not applicable, with recorded target rationale |
| SHA-256-based construction | FIPS 180-4, applicable 90A/construction vectors and independent SHA-256 reference | Not applicable unless an actual selected artifact is used |

The profile manifest lists target, construction, primitive/backend, artifact/proof coverage, oracle identity and active benchmarks. 'Not applicable' requires an explicit registry/profile rule; it is not a waiver for a missing selected implementation. Gate success cannot rely on comparing an implementation with itself.

## 6. Timing and resource plan

Separate buffered requests (B-PERF-02), cached qualified refresh (07), uncached/source-starved behavior (10), quarantine/eligibility delay (09) and release revocation (11). Define request load, buffer occupancy, release chunk, lease, reliable clock and scheduling assumptions for each. Cached seed age/non-reuse/compromise exposure belongs to B-ARG-03/04, not just the latency report.

For N independent opportunities at duration/stride tau, campaign wall clock is at least `N*tau`, plus settling/restarts and unavailable rig time. Three million windows take 3.47 days at 100 ms, 34.72 days at 1 s and 347.22 days at 10 s. Correlated overlapping windows cannot be counted as independent to shorten the campaign. The G5 plan must fit real rig capacity or revise the detector/claim before acceptance.

One T_irn acquisition takes `2,040,000 / qualified_ptg_rate` seconds. Calculate the 54-cell schedule including the permitted repeat, physical settling, analysis and failures. Use measured qualified rates, not the illustrative 19.44 kbit/s arithmetic.

## 7. CI, staleness and result schema

| Tier | Typical checks | Cadence |
|---|---|---|
| Commit | Builds, unit/property/compile-fail tests, mandatory fast Creusot proofs, symbol checks, vectors and regressions | Each change; target ≤15 min |
| Scheduled | Full proof replay, larger differential tests, archive analyses, fuzz shards | Nightly/weekly; ordinary job target ≤4 h; named 24 h fuzz is separate |
| Campaign | Physical entropy/health/environmental/performance qualification | Gate or invalidating change; explicit rig schedule |
| Review | Arguments, trust/provenance/requirements | At applicable gate and dependent change |

`bench/deps.toml` records transitive content/configuration dependencies. A source/model/conditioner/primitive/health/release/target change invalidates all dependent artifacts. G7 may reuse unchanged physical captures only if acquisition identity and configuration remain valid; rerun the final analysis. Never claim that archive replay recreates fresh physical data.

`bench/summary.json` fields: `benchmark_id, revision, profile, boundary, condition, method_version, value, unit, threshold, n, events, confidence_level, confidence_scope, interval_method, independence_basis, verdict, applicability_reason, commit, dependency_hashes, timestamp, artifact_paths, toolchain`.

Detection/false-alarm entries require counts and interval basis; deterministic proof/review entries declare those fields not applicable. Verdicts are `pass`, `fail`, `pending`, or profile-authorized `not_applicable`. Provisional engineering targets are not qualifying passes. A gate cannot silently lower a confidence target, waive an unresolved mandatory proof, or reinterpret missing data as success.
