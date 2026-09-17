# M2 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G2 · **Paired design:** [M2-architecture.md](M2-architecture.md)

## Gate scope

Use held-out captures, exact 90B notation and all 54 cell dispositions. Blocked-alphabet reductions and bit/sample conversions are recorded. Startup/restart evidence is provisional until real M5 inhibition is fixed. G2 values may reopen at G3 if Stage 2 demands different block dimensions.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
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

## Methods and required artifacts

### B-ENT-01 — 90B sequential assessment

**Method:** Use ≥1,000,000 contiguous raw samples per supported cell, full applicable non-IID track, all estimator outputs and versions. Define H_submitter separately from runtime h_credit. Binary H_I=min(H_original,H_submitter); non-binary assessment follows §3.1.3 including bitstring track and unit conversion. An estimator disagreement triggers model/data investigation. Do not test conditioned/DRBG output to infer source entropy.

**Artifact:** `bench/b-ent-01.json` · **Tier:** Campaign.

**Acceptance:** 90B assessment succeeds, and final h_credit is ≤0.5×min(H_model,H_90B) after restart assessment.

### B-ENT-02 — 90B restart assessment

**Method:** Define a restart representative of deployment, including startup inhibition and warm-up, then collect 1,000 restarts ×1,000 samples as specified in 90B §3.1.4. Record all row/column/sanity results; no invented exemption from validation. Requalify after M5 changes startup behavior. H_submitter is not silently set to h_credit: doing so while demanding H_90B≥2h_credit would be contradictory.

**Artifact:** `bench/b-ent-02.json` · **Tier:** Campaign.

**Acceptance:** Prescribed sanity check passes; min(H_r,H_c)≥H_I/2; derive H_90B=min(H_r,H_c,H_I), then apply the runtime margin.

### B-ENT-03 — Model-tailored predictors

**Method:** At least spatial, temporal, illumination-conditioned and shared-readout predictors on ≥10^7 raw bits each where applicable. Separate fitting/tuning and validation captures. Declare each null bound and dependence assumptions; control the campaign family-wise false-rejection probability at 1% using a specified method such as Holm adjustment. Report adjusted and unadjusted results and the assumption attacked.

**Artifact:** `bench/b-ent-03.json` · **Tier:** Campaign.

**Acceptance:** No held-out predictor result rejects the declared model under the predeclared multiplicity-adjusted decision rule.

### B-ENT-04 — Runtime claim margin

**Method:** Check units and the model-derived bound for the actual accepted-block regime. Apply the margin after successful 90B assessment. Record model/estimator uncertainty and configuration. This project margin is not a NIST requirement or a repair for a false physical model.

**Artifact:** `bench/b-ent-04.json` · **Tier:** Commit.

**Acceptance:** h_credit≤0.5×min(H_model,H_90B) across the supported envelope; credits rounded down.

### B-ENT-07 — Dependence and model-parameter support

**Method:** Measure small joint blocks (2/4/8/16 selected bits), conditional distributions, illumination strata and shared readout structure on held-out data. Direct small-alphabet estimates require finite-sample bounds. A 16-bit alphabet has up to 65,536 symbols; for 90B use its prescribed ≤256-symbol reduction and bitstring procedure, documenting losses and units. Do not equate a reduced-alphabet estimate with full-block entropy or extrapolate 16-bit measurements to N_raw without the physical dependence argument.

**Artifact:** `bench/b-ent-07.json` · **Tier:** Campaign.

**Acceptance:** Measurements do not contradict the model assumptions after uncertainty/dependence treatment; B-ARG-01/05 independently justify the actual extraction block.

### B-ARG-01 — Stage 1 extraction

**Method:** State route applicability, actual map, input dependencies, conditioning variables, accepted-data selection effects, seed/index distribution, secrecy, reuse policy and cost. Distinguish fixed-map analysis from a randomized-family theorem. Prove the claimed v_m; ratios and matrix rank alone are insufficient. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-01.md` · **Tier:** Review.

**Acceptance:** A source-specific conditional block bound is transferred through the selected map. Independent review accepted; no unresolved substantive objection.

### B-ARG-05 — Stochastic source model

**Method:** P~Poisson(lambda), deterministic Q(gP+R+b), calibrated parameters/uncertainty, dark current and shared readout treatment, time-local stationarity, environmental support, conditional dependence, model predictions and limits. Wax receives zero credit; environment still changes the parameters. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-05.md` · **Tier:** Review.

**Acceptance:** Physical model and conditional block assumptions are substantiated and independently reviewed. Independent review accepted; no unresolved substantive objection.

### B-ROB-02 — Entropy envelope sweep

**Method:** Run sequential assessment and model checks with equilibration protocol; preserve failed runs and physically unavailable cells as unresolved rather than silently omitting.

**Artifact:** `bench/b-rob-02.json` · **Tier:** Campaign.

**Acceptance:** Model/assessment support h_credit in every supported cell; report distinct extrema for entropy and later detector metrics.

### B-ROB-03 — Cold/out-of-range behavior

**Method:** At least 50 cold starts with conditions/observed outcomes reported (no unsupported 99.9% claim). Before real health at M5, acquisition/model verdicts are provisional. Out-of-range conditions are not required to emit T_irn data.

**Artifact:** `bench/b-rob-03.json` · **Tier:** Campaign.

**Acceptance:** Each trial yields justified operation or a clean refusal; no unjustified output.

## Evidence completeness at G2

Reviewed physical model and Stage 1 argument; 54-cell disposition; 90B/restart analysis; model/assessment/runtime-credit variables; provisional parameters and reviewer dispositions.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M2
make verify PROFILE=reference
make gate G2 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
