# M6 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G6 · **Paired design:** [M6-architecture.md](M6-architecture.md)

## Gate scope

Apply the true selected deployment capabilities, clock, scheduler and DMA authority. Replay serialized ICA/ORA bytes against the receiver ledgers. A valid ORA does not certify malicious generator data as random. Compare overhead to a fully equivalent real-health baseline.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
|---|---|---|
| B-PERF-08 | ADVISORY | Report throughput and latency at all boundaries; target ≤15% throughput loss against the same functional/release configuration. |
| B-PERF-11 | BLOCKING | No commit after the specified release-local closure point; alarm/expiry-to-close and pre-close exposure stay inside the frozen bounds. |
| B-FOOT-07 | BLOCKING | Complete application/support/dependency TCB inventory; unexplained omissions fail. |
| B-VER-09 | BLOCKING | Arbitrary partner-controlled indices cannot cause out-of-bounds access/overflow; proof discharges and 24 h adversarial fuzz campaign is clean. |
| B-INT-01 | BLOCKING | No direct client writes; no commit without valid current ORA, trusted issuer provenance and unused range; scope excludes randomness correctness of malicious staged data. |
| B-INT-08 | BLOCKING | All relevant component failures yield specified client/release behavior within declared bounds. |

## Methods and required artifacts

### B-PERF-08 — Cross-PD overhead

**Method:** Match block sizes, source rate, backend, clock and health/release policy to the single-address-space comparison. Do not compare a stub-health baseline with the full deployment.

**Artifact:** `bench/b-perf-08.json` · **Tier:** Campaign.

**Acceptance:** Report throughput and latency at all boundaries; target ≤15% throughput loss against the same functional/release configuration.

### B-PERF-11 — Release revocation timing

**Method:** Record t_fault/t_alarm/t_close/commit, independent clock tolerance, pending ORAs, maximum chunk and non-preemptible section. Test scheduler contention, timer failure and hostile generation. Use finite permit budgets rather than average throughput to bound exposure.

**Artifact:** `bench/b-perf-11.json` · **Tier:** Campaign.

**Acceptance:** No commit after the specified release-local closure point; alarm/expiry-to-close and pre-close exposure stay inside the frozen bounds.

### B-FOOT-07 — TCB inventory and review size

**Method:** Report release application logic separately (≤300 SLOC review target) and first-party entropy-boundary logic (≤3,000 SLOC target). Include timer/fault/boot/scheduling/SMMU configuration, libs, compiler/kernel/platform assumptions. Targets do not exclude dependencies or substitute for security review.

**Artifact:** `bench/b-foot-07.json` · **Tier:** Campaign.

**Acceptance:** Complete application/support/dependency TCB inventory; unexplained omissions fail.

### B-VER-09 — Hostile transport safety

**Method:** Read shared values into checked local snapshots before use, with specified memory semantics. Fuzz mutation between loads, wrap values, inconsistent lengths and slot reuse. This does not prove physical provenance or sample integrity.

**Artifact:** `bench/b-ver-09.json` · **Tier:** Campaign.

**Acceptance:** Arbitrary partner-controlled indices cannot cause out-of-bounds access/overflow; proof discharges and 24 h adversarial fuzz campaign is clean.

### B-INT-01 — Hostile-generator release confinement

**Method:** Give attacker exactly generator capabilities. Confirm staging writes succeed, direct client writes fail, forged/wrong-channel authorization fails, replay/expired/old-epoch/overlap fails. Test a valid authorization separately: accepted bytes may be arbitrary, which is an explicit limit of confinement.

**Artifact:** `bench/b-int-01.json` · **Tier:** Campaign.

**Acceptance:** No direct client writes; no commit without valid current ORA, trusted issuer provenance and unused range; scope excludes randomness correctness of malicious staged data.

### B-INT-08 — Fault/timer handling

**Method:** Exercise genuine architecture-specific faults, infinite loop/watchdog, timer stall, health/generator/API crash and fault-handler failure handling. Unaligned access is not necessarily a fault on every ISA. Measure health-silence closure by expiry; do not claim immediate stop.

**Artifact:** `bench/b-int-08.json` · **Tier:** Campaign.

**Acceptance:** All relevant component failures yield specified client/release behavior within declared bounds.

## Evidence completeness at G6

Per-PD capability table, supporting TCB, immutable snapshot transport, authoritative time/epoch paths, DMA qualification/trust declaration and measured/proved closure/exposure bounds.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M6
make verify PROFILE=reference
make gate G6 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
