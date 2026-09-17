# M3 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G3 · **Paired design:** [M3-architecture.md](M3-architecture.md)

## Gate scope

B-ARG-09 is the new mandatory output-entropy gate. Final n_int, m_ptg, c_rate, v_out and PTG.3 rate target are configuration outputs of this gate. Soft-only and SHA-256 choices select applicable vector/oracle evidence rather than failing an irrelevant Formosa comparison.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
|---|---|---|
| B-ARG-02 | BLOCKING | Chosen construction supports the selected DRG.3/DRG.4 properties. Independent review accepted; no unresolved substantive objection. |
| B-ARG-03 | BLOCKING | Each qualifying DRG.4 seeding or refresh establishes ≥240 bits min-entropy in the effective state. Independent review accepted; no unresolved substantive objection. |
| B-ARG-04 | BLOCKING | PTG.3 and DRG.4 have separate state, acyclic seeding and explicit boundary/range accounting. Independent review accepted; no unresolved substantive objection. |
| B-ARG-06 | BLOCKING | PTG.3.4 c_rate≥1 per intermediate input, with all internal bottlenecks and output counts accounted for. Independent review accepted; no unresolved substantive objection. |
| B-ARG-09 | BLOCKING | The selected explicit PTG.3.5 min-entropy bound holds for the complete Stage 2 mapping under its declared assumptions. Independent review accepted; no unresolved substantive objection. |
| B-PERF-04 | ADVISORY | Report cycles/operation and cycles/byte against a matched ISA/configuration baseline. |
| B-VER-08 | BLOCKING | Selected backend matches an independent oracle and applicable KATs on 10^6 host cases and 10^4 target cases. |
| B-INT-07 | BLOCKING | Applicable official vectors pass and selected negative mutants are detected on qualified target. |

## Methods and required artifacts

### B-ARG-02 — Generator construction security

**Method:** Specify the nine-tuple, request/persistent state evolution, irreversible update assumptions, additional input, domain separation, arbitrary-time state exposure, enhanced-backward-secrecy granularity, conceptual atomicity if selected, erasure scope and known security limits. Cover each applicable DRG.3.3 and .5–.9 and DRG.4 security obligation. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-02.md` · **Tier:** Review.

**Acceptance:** Chosen construction supports the selected DRG.3/DRG.4 properties. Independent review accepted; no unresolved substantive objection.

### B-ARG-03 — DRG.4 seeding/refresh transfer

**Method:** Analyze the complete transfer from qualified PTG.3 seed to effective state, with personalization, previous state and adversary knowledge. State effective state size separately from entropy. Explain reservoir freshness, compromise scope, non-reuse and entropy losses. No test of generated output can discharge this item. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-03.md` · **Tier:** Review.

**Acceptance:** Each qualifying DRG.4 seeding or refresh establishes ≥240 bits min-entropy in the effective state. Independent review accepted; no unresolved substantive objection.

### B-ARG-04 — Two-instance composition

**Method:** Show PTG.3 output consumption, seed reservations, bounded computational expansion, output provenance and release authority. Give the boundary for every benchmark and counter. Specify trust in generator correctness separately from hostile-generator release confinement. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-04.md` · **Tier:** Review.

**Acceptance:** PTG.3 and DRG.4 have separate state, acyclic seeding and explicit boundary/range accounting. Independent review accepted; no unresolved substantive objection.

### B-ARG-06 — Effective compression

**Method:** Use minimum guaranteed n_int for variable inputs, no sliding averages, actual intermediate mapping widths and generated (not merely delivered) output. Demonstrate why KS24 ¶388 pathology cannot occur. Width/compression compliance does not discharge PTG.3.5. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-06.md` · **Tier:** Review.

**Acceptance:** PTG.3.4 c_rate≥1 per intermediate input, with all internal bottlenecks and output counts accounted for. Independent review accepted; no unresolved substantive objection.

### B-ARG-09 — PTG.3 Stage 2 output entropy

**Method:** Follow KS24 ¶391–413 for the chosen construction. Specify n_int, intermediate block entropy, old-state conditioning, reseed/absorb mappings, bottlenecks, final output map, truncation, m_ptg and the applicable undercut probability (including the 2^-16 criterion where applicable). Account for latest-input credit per ¶402. Derive v_out≥0.98 for the selected claim; 240 seeded-state bits, c_rate≥1, width and T_irn do not substitute. Freeze the attainable throughput only after this argument closes. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-09.md` · **Tier:** Review.

**Acceptance:** The selected explicit PTG.3.5 min-entropy bound holds for the complete Stage 2 mapping under its declared assumptions. Independent review accepted; no unresolved substantive objection.

### B-PERF-04 — Selected primitive performance

**Method:** Keccak only if selected; SHA-256 if selected. Compare the exact qualified implementations at matched sizes/compiler/clock. A ≤1.2× assembly or ≤3× soft ratio is advisory where a comparable baseline exists; a slow soft ratio alone does not prove source throughput failure.

**Artifact:** `bench/b-perf-04.json` · **Tier:** Campaign.

**Acceptance:** Report cycles/operation and cycles/byte against a matched ISA/configuration baseline.

### B-VER-08 — Selected backend differential agreement

**Method:** A selected Formosa artifact is compared where supported; soft-only and SHA-256 profiles use an appropriate independent reference. Message/state boundary cases include all-zero, all-one, single bits and rate/block limits ±1. Applicability is decided by the build matrix; no empty/oracle-identical comparison counts.

**Artifact:** `bench/b-ver-08.json` · **Tier:** Scheduled.

**Acceptance:** Selected backend matches an independent oracle and applicable KATs on 10^6 host cases and 10^4 target cases.

### B-INT-07 — Selected primitive KATs

**Method:** Use FIPS 202/185 for selected Keccak functions, FIPS 180-4 plus 90A vectors for selected SHA-2/DRBG. Record exact vector provenance. Corrupt a constant, an operation/order and output length as applicable; no unrelated primitive required.

**Artifact:** `bench/b-int-07.json` · **Tier:** Campaign.

**Acceptance:** Applicable official vectors pass and selected negative mutants are detected on qualified target.

## Evidence completeness at G3

B-ARG-02/03/04/06/09 accepted; selected primitive/backend applicability; final Stage 2 dimensions and attainable rate; updated G2 analysis if dimensions changed.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M3
make verify PROFILE=reference
make gate G3 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
