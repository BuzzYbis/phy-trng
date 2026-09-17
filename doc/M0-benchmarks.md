# M0 — Benchmarks

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Gate:** G0 · **Paired design:** [M0-architecture.md](M0-architecture.md)

## Gate scope

Probe verdicts supplement benchmark rows: P1 must identify an actually viable acquisition path before G1 qualification; P2 fixes enforced/trusted DMA and time-service feasibility; P3 chooses applicable backends/oracles; P4 discharges a representative signature obligation; P5 scopes authenticity. No measured entropy result is expected.

All prior applicable blocking results remain required. Check transitive content/configuration dependencies before reuse. A pending analytic argument or incomplete mandatory proof cannot pass through a numeric benchmark.

## Newly active registry entries

| ID | Level | Acceptance |
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

## Methods and required artifacts

### B-ARG-08 — Assumptions and complete TCB

**Method:** Independent review starts with M0-active assumptions and expands at each gate. Include acquisition, DMA, primitive proof scope, concurrent memory model, zeroization, clock, fault service, boot/scheduling configuration, compiler/library/kernel/platform dependencies. A document entry does not itself prove an assumption. Store reviewer identity (not author), review scope, objections and accepted dispositions. Re-review on dependent changes.

**Artifact:** `evidence/arguments/B-ARG-08.md` · **Tier:** Review.

**Acceptance:** Every gate-active assumption has scope, consequence, owner and acceptance status; final register includes all supporting dependencies. Independent review accepted; no unresolved substantive objection.

### B-FOOT-04 — No runtime heap

**Method:** Analyze final linked images, imports and transitive allocation paths; scan allocator symbols as a complementary check. Tool/host allocations are outside runtime.

**Artifact:** `bench/b-foot-04.json` · **Tier:** Commit.

**Acceptance:** Zero reachable allocation operations in runtime entry points of qualified profiles.

### B-FOOT-06 — Unsafe scope

**Method:** Allow HAL, selected FFI/hardware backends, low-level synchronization/zeroization and seL4 glue. Report transitive dependency scope separately from first-party token counts.

**Artifact:** `bench/b-foot-06.json` · **Tier:** Commit.

**Acceptance:** Zero project unsafe outside the permitted module/crate list; all unsafe/trusted dependencies enumerated.

### B-VER-02 — Proof replay

**Method:** Replay the pinned Rust/Creusot, Why3 and solver pipeline, with library specifications and proof-session hashes. Cold/warm timings and per-obligation results. A time target cannot excuse an unresolved proof; gate distinguishes performance target from proof success.

**Artifact:** `bench/b-ver-02.json` · **Tier:** Scheduled.

**Acceptance:** All gate-active mandatory proofs replay; toy pipeline at G0, full reference target ≤20 min local/≤45 min scheduled target by G4.

### B-VER-04 — Trusted-boundary inventory

**Method:** Review semantic breadth, not just annotation count. One giant trusted function is not a small trust boundary. Record crypto and compiler artifact scope.

**Artifact:** `bench/b-ver-04.json` · **Tier:** Review.

**Acceptance:** Every trust item has spec, scope, owner, rationale and control; baseline ≤12 review entries or explicitly revised design inventory.

### B-INT-10 — DMA confinement/trust profile

**Method:** M0 probe establishes feasible target approach; G6 repeats real misprogrammed-descriptor and stream-ID/policy tests across allowed/forbidden regions. Verify external memory unchanged and fault observed. Trusted profile has no enforcement result and weakens isolation claim; registry presence is not a hardware test.

**Artifact:** `bench/b-int-10.json` · **Tier:** Campaign.

**Acceptance:** Enforced profile blocks out-of-region device writes with independently protected policy; otherwise A-DMA-1 explicit.

### B-EVD-02 — Requirement traceability

**Method:** Machine join IDs with artifacts, assumptions and gate status. Include DRG.4.1, .8 and .11 as well as request/state limits. No unknown ID or a statistical-only PTG.3.5 mapping.

**Artifact:** `bench/b-evd-02.json` · **Tier:** Commit.

**Acceptance:** Every gate-active requirement has an owner and argument/proof/test plan; final selected PTG.3 and DRG.4 requirements have accepted evidence.

### B-EVD-03 — Reproducible analysis and builds

**Method:** Separate replaying archived acquisition analysis from physically recapturing entropy. Preserve raw data, metadata, tool hashes, seeds for synthetic fixtures, scripts, versions and applicable confidence settings. Reference external capture storage by hashes, not an assertion of identical future physical samples.

**Artifact:** `bench/b-evd-03.json` · **Tier:** Commit.

**Acceptance:** Clean tagged checkout reproduces deterministic build/analysis outputs under pinned configuration.

### B-EVD-04 — Independent argument review

**Method:** Unresolved substantive objections keep the gate open. Review reports and script outputs are evidence, not fabricated attestations.

**Artifact:** `bench/b-evd-04.json` · **Tier:** Review.

**Acceptance:** Every gate-active B-ARG item has a non-author reviewer and accepted disposition; all nine completed by G7.

### B-EVD-05 — Build/data provenance

**Method:** Pin concrete versions and distinguish implementation functional proof, leakage proof and unsupported target claims. Conditional backend applicability is machine-readable.

**Artifact:** `bench/b-evd-05.json` · **Tier:** Commit.

**Acceptance:** Selected profile implementations, proof artifacts, toolchains, sensor firmware/configuration and data hashes recorded.

### B-EVD-06 — Assumptions in guidance and ST

**Method:** Not every toolchain/compiler assumption is an environmental ST assumption: map it to the correct assurance/TOE/environment category. User responsibilities appear in guidance; internal technical trust remains in the assurance case.

**Artifact:** `bench/b-evd-06.json` · **Tier:** Review.

**Acceptance:** All gate-active assumptions documented; final ST/guidance carry operational obligations and technical assurance limits appropriately.

## Evidence completeness at G0

Five probe verdicts; `config/profiles.toml`; target/backend/oracle applicability; initial reviewed assumption register; reproducible toy proof and harness.

## Reporting and execution

Every report names profile, boundary, condition, commit/dependency hashes and method version. Statistical results include n, events, event unit, dependence basis, confidence scope and exact interval method; proofs/reviews declare these fields not applicable. Observed maxima are not universal worst-case proofs.

Planned project commands (to be implemented, not claimed to exist yet):

```sh
make bench PROFILE=reference MILESTONE=M0
make verify PROFILE=reference
make gate G0 PROFILE=reference
```

A gate fails on missing, failed, stale or pending applicable blocking evidence. Profile-approved not-applicable results require the registry applicability rule. The complete shared definitions are in [BENCHMARKS.md](BENCHMARKS.md).
