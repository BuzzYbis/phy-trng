# M2 — Source model and Stage 1 argument

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Effort:** 150 h provisional · **Productive weeks:** 18–32 · **Gate:** [G2](GATES.md#g2)

## Objective and entry

Derive the physical model and Stage 1 extraction argument together, using real labelled captures. G1 supplies raw acquisition, monitor scope and configuration identity. G2 is the source decision gate; no numerical parameter is justified by the design aspiration alone.

## Work packages — 150 h provisional

| Package | Hours | Output |
|---|---:|---|
| Physical/dependence model | 60 | B-ARG-05 and parameter uncertainty |
| Stage 1 analysis | 45 | B-ARG-01, route selection and output bound |
| Assessment/predictors/restarts | 45 | Held-out campaign, corrected notation and runtime-credit derivation |

## Model specification

Start with P~Poisson(lambda), X=Q(gP+R+b). Define physical photon/dark/read components, deterministic quantization and clipping, gain calibration, offset and environmental dependence. Do not double-count the mean or add independent 'quantization entropy'. If Gaussian read-noise is used, justify its range and tails; measured variance alone does not establish that distribution or its entropy.

Define the exact raw sequence and extraction block. Bound joint/conditional min-entropy under a stated definition and attacker model: known scene/illumination/temperature, prior frames/output and shared sensor readout effects. Explain time-local stationarity and how warming trajectories fit the claim. Small pairwise correlation does not prove independence.

The real runtime accepts samples only after tests. Account for the selection event and any discarded data where it changes the distribution. A model of an unconditional stream is not silently a theorem about an arbitrarily selected stream.

## Stage 1 route and map

Route B is the candidate default: an actual fixed map, with a bound derived from this source distribution/dependence structure. Record dimensions, bit order, parameter selection, rank checks and transfer theorem. A full-rank map can still destroy entropy supported in its kernel; rank is only a structural check.

For Route A, derive the correct seeded/universal-family result and determine which AIS conditions apply to the selected class. Document index generation/secrecy/reuse, required probability guarantees and entropy cost. The PTG.2-specific requirements are not automatically identical to a low-v_m PTG.3 inner claim; justify applicability explicitly. Implement only the chosen route in v1 unless the second route has its own budget and gates.

For either route give an exact output min-entropy/statistical-distance statement, failure/undercut assumptions, conditioning variables, retained state and seed cost. Do not freeze a ratio from ceil(v_m/h_credit) and assume a theorem exists for it.

## Assessment and notation

Keep H_model, H_submitter, H_original, H_I, H_r, H_c, H_90B and h_credit separate. Run the full applicable 90B non-IID track with all estimates reported. For binary data H_I=min(H_original,H_submitter); assess restarts under the standard's own sanity and row/column rules. Only afterward choose h_credit≤0.5×min(H_model,H_90B). All quantities are normalized to per-bit units when used in this inequality.

Define a real-use restart process including provisional startup inhibition and warm-up. Collect 1,000×1,000 samples. When M5 changes real startup behavior, requalify affected restart evidence rather than assuming the early data still apply.

Small-block dependence measurements (2/4/8/16 bits) support the model. Use confidence/dependence-aware methods and enough observations; a 16-bit blocked alphabet exceeds the 90B 256-symbol limit, so document its reduction/bitstring handling or a separate justified direct estimator. No small-block measurement alone proves the full extraction-block bound.

Predictors use held-out captures and a predeclared 1% family-wise falsification rule. Analyze at least spatial, temporal, illumination-conditioned and shared-readout predictors; report which assumption is challenged. A failed test is an investigation, not permission to tune on the validation set until it passes.

## Envelope and output

Enumerate all 54 cell IDs from BENCHMARKS; every exclusion has a physical/model reason and updates the supported envelope. Name minimum-entropy cells. Prepare degradation signatures for health design, but do not assume minimum entropy is also the worst false-alarm or latency case.

G2 freezes the supported source model, assessment, h_credit, Stage 1 route/map and v_m for a **candidate** block configuration. n_int/r_ext/ROI/block dimensions may reopen at G3 when Stage 2 needs more entropy or different lengths. Record those dependencies explicitly; w_eff is not frozen before construction selection.

## Decision and review

A: source and extraction argument close at usable candidate rate; continue. B: model/rate fails, assess RO-jitter as a separately modeled source (provisional +120 h, not a guaranteed turnkey fallback). C: stop and publish the result. Independent reviewers must accept B-ARG-01 and 05; unresolved objections block G2. The final PTG.3 output rate is not a G2 claim.

## Acceptance and dependencies

Reviewed physical model and Stage 1 argument; 54-cell disposition; 90B/restart analysis; model/assessment/runtime-credit variables; provisional parameters and reviewer dispositions.

Canonical acceptance criteria are in [BENCHMARKS.md](BENCHMARKS.md); gate aggregation is in [GATES.md](GATES.md). The paired [milestone benchmarks](M2-benchmarks.md) list newly active items and methods. Prior gate results remain required only when applicable and dependency-valid. See [architecture](ARCHITECTURE.md) for authority, units and trust definitions.
