# M7 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G7 · **Paired design:** [M7-architecture.md](M7-architecture.md)

## Gate scope

Re-run final analysis of all dependent captures. Qualify all selected environmental cells and record every exclusion. Every B-ARG-01…09 review must be complete. Archived acquisition replay is distinct from fresh hardware campaigns.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
|---|---|---|
| B-ROB-01 | BLOCKING | PTG.3 T_irn and relevant entropy/model checks pass for all 54 supported cells, unless an exclusion was explicitly approved before campaign. |
| B-ROB-04 | BLOCKING | No unexplained operation outside qualified bounds; detector/refusal behavior matches policy; model remains adequate. |
| B-ROB-05 | BLOCKING | 500 h completes without unexplained claim violations; each alarm and trend adjudicated under predefined rules. |
| B-ROB-06 | BLOCKING | 1,000/1,000 specified restart behaviors correct; report one-sided 95% lower success bound (~0.9970). |

## Methods and required artifacts

### B-ROB-01 — Supported-envelope qualification

**Method:** Cells defined in BENCHMARKS §2. Pruning requires a named configuration constraint and updated advertised envelope; no informal approximation to 25 cells. Include transitions/aging checks separately.

**Artifact:** `bench/b-rob-01.json` · **Tier:** Campaign.

**Acceptance:** PTG.3 T_irn and relevant entropy/model checks pass for all 54 supported cells, unless an exclusion was explicitly approved before campaign.

### B-ROB-04 — Thermal transitions

**Method:** 50 cycles between supported extremes, 20 min dwell plus measured settling requirement; inspect cycles 1/25/50 and transition behavior. A fixed runtime credit should remain justified; report measured parameter/entropy drift. 10% drift is an investigation trigger, not a theorem or evidence that wax temperature is irrelevant.

**Artifact:** `bench/b-rob-04.json` · **Tier:** Campaign.

**Acceptance:** No unexplained operation outside qualified bounds; detector/refusal behavior matches policy; model remains adequate.

### B-ROB-05 — Burn-in

**Method:** Hourly diagnostics, health statistics, configuration readback and daily T_irn at the named boundary. Archive data/versions; preserve restart gaps and replaced hardware identity.

**Artifact:** `bench/b-rob-05.json` · **Tier:** Campaign.

**Acceptance:** 500 h completes without unexplained claim violations; each alarm and trend adjudicated under predefined rules.

### B-ROB-06 — Restart storm

**Method:** Use the G2/M5-defined real restart process. Verify startup, fresh seed, no reuse of state/permits, new session/epoch initialization and no pre-startup output. Runtime restart and whole power loss may need separate cases.

**Artifact:** `bench/b-rob-06.json` · **Tier:** Campaign.

**Acceptance:** 1,000/1,000 specified restart behaviors correct; report one-sided 95% lower success bound (~0.9970).

## Evidence completeness at G7

All 54 cells qualified or explicitly excluded with narrowed guidance; robustness results; all nine accepted independent arguments; traceability, trusted inventory, selected-profile provenance and final evidence package.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M7
make verify PROFILE=reference
make gate G7 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
