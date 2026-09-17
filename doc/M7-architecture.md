# M7 — Environmental qualification and evidence

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Effort:** 120 h provisional · **Productive weeks:** 83–94 · **Gate:** [G7](GATES.md#g7)

## Objective and entry

Qualify the final selected hardware/software profile over its supported envelope and assemble evidence whose claims match what was proved, measured and assumed. G6 supplies functional and deployed protocol qualification. Evaluation-ready is the target; certification remains a separate process.

## Work packages — 120 h provisional

| Package | Hours | Output |
|---|---:|---|
| Environmental campaigns | 34 | All selected cells, transitions and robustness |
| Regressions and dependency review | 16 | Final-profile evidence validity |
| Evidence assembly | 46 | Applicable developer documents and source references |
| Assumption/TCB integration | 12 | Technical/operational trust mapped correctly |
| Traceability and final review | 12 | Complete requirement-to-evidence matrix |

## Schedule from measured quantities

Enumerate all 54 candidate supported cells; retain a disposition row for every one. Do not plan for 25 unspecified points. Exclude a physically impossible/unsupported cell only with a versioned rationale and narrower advertised envelope. Record equilibrated sensor parameters or the defined warming trajectory, rather than only ambient labels.

T_irn acquisition per run is 2,040,000/qualified_ptg_rate seconds. Multiply by actual cells and permitted repeats, then add physical settling, analysis, rig transitions and rework. Burn-in takes at least 500 uninterrupted operating hours; thermal cycling takes dwell plus measured settling/ramp time. Recompute the false-alarm campaign from the actual independent opportunity cadence if dependent changes invalidate it.

A second rig helps only if its unit/configuration and cross-unit applicability are justified. Preserve serial numbers and do not silently combine unmatched boards/sensors. Calendar dates depend on hardware and reviewer availability, not only coding hours.

## Environmental and robustness evidence

Run PTG.3 T_irn and the relevant model/assessment checks across every supported cell; report DRG.4 statistics at its separate boundary. Out-of-range/fault conditions are graded on correct operation/refusal, never forced to emit random data.

Thermal cycling: 50 cycles, supported extremes, at least 20 min dwell or longer if the measured settling model requires it; inspect early/middle/late cycles and transitions. Credit remains justified even if measured entropy moves; a 10% drift triggers review rather than automatically proving failure or success.

Burn-in: 500 h with hourly diagnostics, configuration checks and alarm records; daily T_irn. Predeclare trend/incident rules and preserve failures. Restart storm: 1,000 deployment-realistic restarts with startup, fresh seed, reset/replay behavior and no pre-eligibility output checked. Report actual confidence of the success count (~0.9970 lower bound for 1,000/1,000), not an invented 99.9% qualification.

## Applicable evidence package

| Set | Planned content |
|---|---|
| PTG.3 | HP.1–HP.7, all selected PTG.3 requirements, B-ARG-09 output derivation |
| Inner PTRNG | P.2–P.7, P.9–P.15, P.18, P.20 for the non-PTG.2 variant, with P.12 adapted |
| DRG.4 | HD.1–HD.5, D.1–D.17 as applicable, actual seeding/composition and secrecy selections |
| Guidance | Supported envelope, installation/protection duties, API/error handling, acquisition/DMA scope, startup/refresh behavior |
| ST | Completed FCS_RNG.1 selections/assignments and correctly categorized TOE/environment assumptions |
| Technical assurance | Nine reviewed arguments, proof obligations, trust/TCB inventory, time/release contract, artifacts and implementation provenance |

Follow UPD25's applicability rather than presenting omitted inner-PTRNG evidence IDs as mandatory. Guidance may still contain useful material regardless of that omission. Every stated claim names the selected profile, output boundary and assumptions.

## Trust and review

List acquisition and DMA trust, selected crypto artifact coverage, memory ordering, zeroization, reliable time, fault/boot/scheduler configuration, libraries and compiler/kernel/platform assumptions. Do not classify every technical toolchain assumption as an operational environmental ST assumption. User obligations go in guidance; technical trust goes in the assurance case.

All nine B-ARG items need a non-author reviewer, accepted dispositions and no unresolved substantive objection. Review document presence alone is insufficient. Any change to code, physical configuration or model reopens dependent arguments/results.

## Reproducibility and final gate

Generate traceability columns `requirement, profile, boundary, argument_ids, proof_ids, benchmark_ids, documents, gate, assumptions, dependency_hashes`. Include DRG.4.1/.8/.11, not just the numerical limits. PTG.3.5 points to B-ARG-09; state entropy points to B-ARG-03; B-ENT-08 is implementation evidence only.

Archive raw captures/configuration hashes and reproducible analysis scripts. Fresh physical recapture is not bit-for-bit reproducible and is not claimed to be. Rebuild final code and replay analysis; reuse prior campaigns only where the complete dependency map remains valid. Missing/failed/stale evidence blocks G7.

The package contains the final supported profile, traceability, independent arguments, benchmark report, proof status, assumption/TCB record, provenance and capture manifests. The pipeline explorer is a navigational/explanatory view of the specification, not measured telemetry or a cryptographic simulator.

## Acceptance and dependencies

All 54 cells qualified or explicitly excluded with narrowed guidance; robustness results; all nine accepted independent arguments; traceability, trusted inventory, selected-profile provenance and final evidence package.

Canonical acceptance criteria are in [BENCHMARKS.md](BENCHMARKS.md); gate aggregation is in [GATES.md](GATES.md). The paired [milestone benchmarks](M7-benchmarks.md) list newly active items and methods. Prior gate results remain required only when applicable and dependency-valid. See [architecture](ARCHITECTURE.md) for authority, units and trust definitions.
