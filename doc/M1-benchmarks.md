# M1 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G1 · **Paired design:** [M1-architecture.md](M1-architecture.md)

## Gate scope

B-INT-02 here concerns the external production surface; internal source traits must still carry raw data. Acquisition monitor confidence is per declared fault class. A genuine varied-frame replay non-detection is a scope demonstration, not a failed promised detector.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
|---|---|---|
| B-STAT-03 | BLOCKING | Complete labelled characterization at ≥4 supported cells by G1; full selected campaign set by G2. No arbitrary raw-randomness pass threshold. |
| B-ARG-07 | BLOCKING | A-ACQ-1 and monitor limitations are explicit and consistent with the chosen hardware boundary. Independent review accepted; no unresolved substantive objection. |
| B-PERF-01a | BLOCKING | ≥1 Mbit/s sustained for 1 h; zero silent gaps; report all observed drops. |
| B-INT-02 | BLOCKING | No production external raw/evidence output; internal capabilities follow the entropy boundary. |
| B-INT-12 | BLOCKING | For each monitor, ≥0.99 per-class detection lower bound where claimed; demonstrated negative cases match documented limitations. |
| B-EVD-01 | BLOCKING | Every gate-active evidence item maps to a specific artifact; full selected set by G7. |

## Methods and required artifacts

### B-STAT-03 — Raw characterization

**Method:** Report pixel bias; spatial correlation with uncertainty; temporal lags 1–64; full-value mean/variance; shared row/column noise; read-noise estimation method; frame/sample sequence gaps. Distinguish selected ROI cadence from accidental missing samples. Record actual dropped frames separately from silent drops.

**Artifact:** `bench/b-stat-03.json` · **Tier:** Campaign.

**Acceptance:** Complete labelled characterization at ≥4 supported cells by G1; full selected campaign set by G2. No arbitrary raw-randomness pass threshold.

### B-ARG-07 — Acquisition integrity

**Method:** Review physical/interface/software trust, access protection, sensor configuration and firmware controls, out-of-scope replay, failure-detector scope and user guidance. Update after target integration; authenticated freshness is not claimed unless implemented and qualified. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-07.md` · **Tier:** Review.

**Acceptance:** A-ACQ-1 and monitor limitations are explicit and consistent with the chosen hardware boundary. Independent review accepted; no unresolved substantive objection.

### B-PERF-01a — Raw acquisition rate

**Method:** Reference profile capture with frame/sample IDs and timing. A qualification capture used as contiguous data has zero unexplained gaps. A deliberate sampling cadence is part of the model.

**Artifact:** `bench/b-perf-01a.json` · **Tier:** Campaign.

**Acceptance:** ≥1 Mbit/s sustained for 1 h; zero silent gaps; report all observed drops.

### B-INT-02 — Raw containment

**Method:** API/feature checks plus linked/configuration audit; at G6 add probe PD and all diagnostic/crash-report paths. Internal NoiseSource APIs legitimately carry raw types; do not require their disappearance from the whole workspace.

**Artifact:** `bench/b-int-02.json` · **Tier:** Campaign.

**Acceptance:** No production external raw/evidence output; internal capabilities follow the entropy boundary.

### B-INT-12 — Acquisition monitor scope

**Method:** Default 299 independent zero-miss positive trials; at least one documented non-detection scenario per limitation. A varied-video replay passing the freeze test is evidence of scope, not a detector success.

**Artifact:** `bench/b-int-12.json` · **Tier:** Campaign.

**Acceptance:** For each monitor, ≥0.99 per-class detection lower bound where claimed; demonstrated negative cases match documented limitations.

### B-EVD-01 — Applicable evidence coverage

**Method:** Use explicit applicability rather than a fixed superset of PTG.2 and PTG.3 items. Guidance remains useful even where an inner-PTRNG evidence ID is omitted.

**Artifact:** `bench/b-evd-01.json` · **Tier:** Commit.

**Acceptance:** Every gate-active evidence item maps to a specific artifact; full selected set by G7.

## Evidence completeness at G1

At least 20 h of labelled captures across four cells; hashes/readback logs; monitor-scope document; reviewed A-ACQ-1 argument.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M1
make verify PROFILE=reference
make gate G1 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
