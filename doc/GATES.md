# Phy-TRNG — Gates

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

## Gate semantics

`make gate G<n> PROFILE=<qualified-profile>` consumes the canonical benchmark registry and the result/dependency manifests. Every newly active and prior applicable BLOCKING item must pass. ADVISORY findings carry a written owner, consequence and disposition. No confidence reduction or proof admission is an advisory waiver.

1. Missing, failed, stale or pending mandatory results fail the gate.
2. A profile-authorized not-applicable result requires the registry's exact applicability rule; no Formosa requirement applies to a justified soft-only/SHA-256 profile, but independent oracle/vector evidence still applies.
3. Numeric arguments and semantic security properties are not discharged by document existence, annotation percentage or a count of tests.
4. B-ARG reviews use a reviewer other than the author; substantive objections must be resolved and accepted. Review scope expands as facts become available.
5. All mandatory proof obligations discharge. Trusted boundaries stay assumptions, never 'proved' rows.
6. Statistical entries carry event unit, n, events, interval method, confidence scope and dependence basis. A lower achieved confidence bound does not silently pass.
7. Prior results may be reused only under dependency/content validity. Rebuild final code and replay final analysis; distinguish archived evidence from new physical acquisition.
8. G0–G4 establish prototypes and arguments; they do not authorize production entropy release before G5/G6 qualifications.

The benchmark acceptance text below is generated from BENCHMARKS' registry. Milestone-specific scope is stated in the corresponding pair of documents. A configured engineering target is frozen only by the named gate; changing it later is a versioned design change that reopens dependent results.


<a id="g0"></a>

## G0 — Feasibility and assurance profiles

**Closes M0; target productive week 8.** Reference hardware, acquisition/DMA feasibility, toolchain and conditional backend applicability.

| New item | Level | Acceptance |
|---|---|---|
| B-ARG-08 | BLOCKING | Every gate-active assumption has scope, consequence, owner and acceptance status; final register includes all supporting dependencies. Independent review accepted; no unresolved substantive objection. |
| B-FOOT-04 | BLOCKING | Zero reachable allocation operations in runtime entry points of qualified profiles. |
| B-FOOT-06 | BLOCKING | Zero project unsafe outside the permitted module/crate list; all unsafe/trusted dependencies enumerated. |
| B-VER-02 | BLOCKING | All gate-active mandatory proofs replay; toy pipeline at G0, full reference target ≤20 min local/≤45 min scheduled target by G4. |
| B-VER-04 | BLOCKING | Every trust item has spec, scope, owner, rationale and control; baseline ≤12 review entries or explicitly revised design inventory. |
| B-INT-10 | BLOCKING | Enforced profile blocks out-of-region device writes with independently protected policy; otherwise A-DMA-1 explicit. |
| B-EVD-02 | BLOCKING | Every gate-active requirement has an owner and argument/proof/test plan; final selected PTG.3 and DRG.4 requirements have accepted evidence. |
| B-EVD-03 | BLOCKING | Clean tagged checkout reproduces deterministic build/analysis outputs under pinned configuration. |
| B-EVD-04 | BLOCKING | Every gate-active B-ARG item has a non-author reviewer and accepted disposition; all nine completed by G7. |
| B-EVD-05 | BLOCKING | Selected profile implementations, proof artifacts, toolchains, sensor firmware/configuration and data hashes recorded. |
| B-EVD-06 | BLOCKING | All gate-active assumptions documented; final ST/guidance carry operational obligations and technical assurance limits appropriately. |

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** Five probe verdicts; `config/profiles.toml`; target/backend/oracle applicability; initial reviewed assumption register; reproducible toy proof and harness.

<a id="g1"></a>

## G1 — Acquisition and capture

**Closes M1; target productive week 17.** Real labelled capture, acquisition-monitor scope and reviewed provenance boundary.

| New item | Level | Acceptance |
|---|---|---|
| B-STAT-03 | BLOCKING | Complete labelled characterization at ≥4 supported cells by G1; full selected campaign set by G2. No arbitrary raw-randomness pass threshold. |
| B-ARG-07 | BLOCKING | A-ACQ-1 and monitor limitations are explicit and consistent with the chosen hardware boundary. Independent review accepted; no unresolved substantive objection. |
| B-PERF-01a | BLOCKING | ≥1 Mbit/s sustained for 1 h; zero silent gaps; report all observed drops. |
| B-INT-02 | BLOCKING | No production external raw/evidence output; internal capabilities follow the entropy boundary. |
| B-INT-12 | BLOCKING | For each monitor, ≥0.99 per-class detection lower bound where claimed; demonstrated negative cases match documented limitations. |
| B-EVD-01 | BLOCKING | Every gate-active evidence item maps to a specific artifact; full selected set by G7. |

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** At least 20 h of labelled captures across four cells; hashes/readback logs; monitor-scope document; reviewed A-ACQ-1 argument.

<a id="g2"></a>

## G2 — Source model and Stage 1 argument

**Closes M2; target productive week 32.** Joint model/extraction analysis, corrected 90B assessment and runtime credit.

| New item | Level | Acceptance |
|---|---|---|
| B-ENT-01 | BLOCKING | 90B assessment succeeds, and final h_credit is ≤0.5×min(H_model,H_90B) after restart assessment. |
| B-ENT-02 | BLOCKING | Prescribed sanity check passes; min(H_r,H_c)≥H_I/2; derive H_90B=min(H_r,H_c,H_I), then apply the runtime margin. |
| B-ENT-03 | BLOCKING | No held-out predictor result rejects the declared model under the predeclared multiplicity-adjusted decision rule. |
| B-ENT-04 | BLOCKING | h_credit≤0.5×min(H_model,H_90B) across the supported envelope; credits rounded down. |
| B-ENT-07 | BLOCKING | Measurements do not contradict the model assumptions after uncertainty/dependence treatment; B-ARG-01/05 independently justify the actual extraction block. |
| B-ARG-01 | BLOCKING | A source-specific conditional block bound is transferred through the selected map. Independent review accepted; no unresolved substantive objection. |
| B-ARG-05 | BLOCKING | Physical model and conditional block assumptions are substantiated and independently reviewed. Independent review accepted; no unresolved substantive objection. |
| B-ROB-02 | BLOCKING | Model/assessment support h_credit in every supported cell; report distinct extrema for entropy and later detector metrics. |
| B-ROB-03 | BLOCKING | Each trial yields justified operation or a clean refusal; no unjustified output. |

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** Reviewed physical model and Stage 1 argument; 54-cell disposition; 90B/restart analysis; model/assessment/runtime-credit variables; provisional parameters and reviewer dispositions.

<a id="g3"></a>

## G3 — Generator construction and both entropy transfers

**Closes M3; target productive week 41.** Construction, DRG.4 state transfer and dedicated PTG.3 output entropy proof.

| New item | Level | Acceptance |
|---|---|---|
| B-ARG-02 | BLOCKING | Chosen construction supports the selected DRG.3/DRG.4 properties. Independent review accepted; no unresolved substantive objection. |
| B-ARG-03 | BLOCKING | Each qualifying DRG.4 seeding or refresh establishes ≥240 bits min-entropy in the effective state. Independent review accepted; no unresolved substantive objection. |
| B-ARG-04 | BLOCKING | PTG.3 and DRG.4 have separate state, acyclic seeding and explicit boundary/range accounting. Independent review accepted; no unresolved substantive objection. |
| B-ARG-06 | BLOCKING | PTG.3.4 c_rate≥1 per intermediate input, with all internal bottlenecks and output counts accounted for. Independent review accepted; no unresolved substantive objection. |
| B-ARG-09 | BLOCKING | The selected explicit PTG.3.5 min-entropy bound holds for the complete Stage 2 mapping under its declared assumptions. Independent review accepted; no unresolved substantive objection. |
| B-PERF-04 | ADVISORY | Report cycles/operation and cycles/byte against a matched ISA/configuration baseline. |
| B-VER-08 | BLOCKING | Selected backend matches an independent oracle and applicable KATs on 10^6 host cases and 10^4 target cases. |
| B-INT-07 | BLOCKING | Applicable official vectors pass and selected negative mutants are detected on qualified target. |

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** B-ARG-02/03/04/06/09 accepted; selected primitive/backend applicability; final Stage 2 dimensions and attainable rate; updated G2 analysis if dimensions changed.

<a id="g4"></a>

## G4 — Single-target vertical slice

**Closes M4; target productive week 56.** Two instances, accounting, byte API, selected primitives and provisional local output checks.

| New item | Level | Acceptance |
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

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** Single-target implementation; all mandatory local proofs; independent primitive and seed regressions; named generated/delivered boundaries; byte-API and refresh tests. Stub-health results explicitly test-only.

<a id="g5"></a>

## G5 — Health, authorization and release

**Closes M5; target productive week 70.** Snapshot-first health, distinct ICA/ORA, receiver ledgers and timed commit protocol.

| New item | Level | Acceptance |
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

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** Reviewed detector rationale, uncertainty-aware defect mapping, campaign plan/results, snapshot/ICA/ORA protocol and local commit-state model; real startup invalidates earlier provisional restart assumptions where changed.

<a id="g6"></a>

## G6 — Deployment isolation and timing

**Closes M6; target productive week 82.** seL4 capabilities, DMA profile, clock/fault support and cross-domain closure bounds.

| New item | Level | Acceptance |
|---|---|---|
| B-PERF-08 | ADVISORY | Report throughput and latency at all boundaries; target ≤15% throughput loss against the same functional/release configuration. |
| B-PERF-11 | BLOCKING | No commit after the specified release-local closure point; alarm/expiry-to-close and pre-close exposure stay inside the frozen bounds. |
| B-FOOT-07 | BLOCKING | Complete application/support/dependency TCB inventory; unexplained omissions fail. |
| B-VER-09 | BLOCKING | Arbitrary partner-controlled indices cannot cause out-of-bounds access/overflow; proof discharges and 24 h adversarial fuzz campaign is clean. |
| B-INT-01 | BLOCKING | No direct client writes; no commit without valid current ORA, trusted issuer provenance and unused range; scope excludes randomness correctness of malicious staged data. |
| B-INT-08 | BLOCKING | All relevant component failures yield specified client/release behavior within declared bounds. |

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** Per-PD capability table, supporting TCB, immutable snapshot transport, authoritative time/epoch paths, DMA qualification/trust declaration and measured/proved closure/exposure bounds.

<a id="g7"></a>

## G7 — Environmental qualification and evidence

**Closes M7; target productive week 94.** 54-cell qualification, robustness, final review and reproducible evidence package.

| New item | Level | Acceptance |
|---|---|---|
| B-ROB-01 | BLOCKING | PTG.3 T_irn and relevant entropy/model checks pass for all 54 supported cells, unless an exclusion was explicitly approved before campaign. |
| B-ROB-04 | BLOCKING | No unexplained operation outside qualified bounds; detector/refusal behavior matches policy; model remains adequate. |
| B-ROB-05 | BLOCKING | 500 h completes without unexplained claim violations; each alarm and trend adjudicated under predefined rules. |
| B-ROB-06 | BLOCKING | 1,000/1,000 specified restart behaviors correct; report one-sided 95% lower success bound (~0.9970). |

**Regression:** all earlier applicable blocking items; only results with valid dependency hashes may be reused.

**Artifacts:** All 54 cells qualified or explicitly excluded with narrowed guidance; robustness results; all nine accepted independent arguments; traceability, trusted inventory, selected-profile provenance and final evidence package.

## Requirement coverage

| Requirement | Gates | Principal evidence |
|---|---|---|
| PTG.3.1 | G2 | B-ARG-05, B-ENT-03, B-ENT-07 |
| PTG.3.2 | G3/G4 | B-ARG-02, B-ARG-04, B-VER-01 |
| PTG.3.3 | G2 | B-ARG-01, B-ENT-01, B-ENT-02, B-ENT-04 |
| PTG.3.4 | G3/G4 | B-ARG-06, B-PERF-01c |
| PTG.3.5 | G3/G4 | B-ARG-09, B-ARG-01, B-ARG-06, B-VER-01 |
| PTG.3.6 | G5 | B-HLT-05, B-VER-05 |
| PTG.3.7 | G5 | B-HLT-03, B-HLT-04, B-INT-09 |
| PTG.3.8 | G5/G6 | B-HLT-01, B-HLT-02, B-INT-09, B-PERF-11 |
| PTG.3.9 | G4/G7 | B-STAT-01, B-ROB-01 |
| Intermediate integrity/authenticity/secrecy (¶383) | G1/G6 | B-ARG-07, B-INT-02, B-INT-11, B-INT-12 |
| DRG.4.1 | G3/G4 | B-ARG-04, B-INT-06 |
| DRG.4.2 | G4 | B-INT-03 |
| DRG.4.3 | G3/G4 | B-ARG-02, B-INT-05 |
| DRG.4.4 | G3/G4 | B-ARG-03, B-INT-06, B-ENT-08 |
| DRG.4.5 / .6 / .7 | G3/G4 | B-ARG-02, B-VER-01 |
| DRG.4.8 | G3/G4 | B-ARG-02, B-ENT-08 |
| DRG.4.9 | G3/G4 | B-ARG-02, B-VER-08, B-INT-07 |
| DRG.4.10 incl. ¶239 | G3/G4/G5 | B-ARG-03, B-ARG-04, B-INT-04, B-PERF-07, B-PERF-10 |
| DRG.4.11 | G4/G7 | B-STAT-04 |
| Release confinement / temporal authorization | G5/G6 | B-VER-10, B-VER-11, B-INT-01, B-INT-09, B-PERF-11 |
| DMA and supporting TCB | G0/G6/G7 | B-INT-10, B-ARG-08, B-FOOT-07 |

B-EVD-02 checks the complete selected requirement list, including the exact DRG.3 subset applicable to PTG.3.2 and each declared assumption. B-ENT-08 supports implementation fidelity, never the entropy theorem. T_irn is not the principal evidence for PTG.3.5.
