# Phy-TRNG — Roadmap

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

## Capacity and status

One developer, about 10 effective hours per productive week and 44 productive weeks/year: approximately 440 h/year. The specified baseline is **940 h =94 productive weeks ≈25.6 calendar months**. This is a provisional implementation/analysis estimate, not a promised evaluation date. Reviewer availability, hardware changes, campaigns and unresolved Stage 1/Stage 2 analysis may extend it.

Sixteen paired milestone documents retain M0–M7 identifiers. Each gate references the canonical benchmark registry. None of the figures below means work has already been completed.

## Sequence

| Milestone | Work | Effort | Productive weeks | Gate |
|---|---|---:|---|---|
| [M0](M0-architecture.md) | Feasibility and assurance profiles | 80 h | 1–8 | G0 |
| [M1](M1-architecture.md) | Acquisition and capture | 90 h | 9–17 | G1 |
| [M2](M2-architecture.md) | Source model and Stage 1 argument | 150 h | 18–32 | G2 |
| [M3](M3-architecture.md) | Generator construction and both entropy transfers | 90 h | 33–41 | G3 |
| [M4](M4-architecture.md) | Single-target vertical slice | 150 h | 42–56 | G4 |
| [M5](M5-architecture.md) | Health, authorization and release | 140 h | 57–70 | G5 |
| [M6](M6-architecture.md) | Deployment isolation and timing | 120 h | 71–82 | G6 |
| [M7](M7-architecture.md) | Environmental qualification and evidence | 120 h | 83–94 | G7 |

## M0 — feasibility first

Five probes: sensor access (18 h), DMA/time-service feasibility (14 h), primitive/backend/oracle support (18 h), hardest proof/transport signature (14 h), physical freshness feasibility (8 h), plus 8 h minimum scaffolding/review setup. Choose one reference profile; label other targets compile-only until qualified. Secure independent reviewers for the gate-active assumption, physical and cryptographic arguments early.

No optional backend becomes an unconditional later gate. A failed sensor probe needs a verified alternative before qualified acquisition, not just an order receipt. Probe code may be discarded.

## M1 — real acquisition and honest scope

Source/metadata contracts, verified configuration/readback, ROI extraction, failure monitors, containment and ≥20 h labelled captures at four or more cells. Physical provenance rests on A-ACQ-1; the monitors' inability to detect general varied-video replay is demonstrated and documented.

## M2 — source and extraction together

Write B-ARG-05 physical/dependence model and B-ARG-01 actual Stage 1 map analysis together. Assess the source using 90B's variables and rules; only afterward derive the reduced runtime h_credit. Collect separate fitting and validation data; define and justify restart behavior; enumerate the 54-cell envelope.

G2 is the source decision: continue, assess a separately modeled RO-jitter alternative (provisional +120 h), or stop. Model/source-independent review is a real dependency. Candidate Stage 1 dimensions remain linked to M3 needs; do not freeze w_eff before choosing the construction.

## M3 — construction and complete Stage 2 proof

Select construction/profile and close B-ARG-02 security, B-ARG-03 DRG.4 state entropy, B-ARG-04 composition, B-ARG-06 effective compression and **B-ARG-09 PTG.3 output entropy**. Build only the required primitive implementations/vectors and independent oracle.

Freeze the actual input/output block lengths, bottleneck dimensions, rate target and reseed policy only after the complete output transfer closes. The 16 kbit/s value is an aspiration until then. If extra entropy/truncation changes Stage 1 dimensions, reopen the dependent G2 argument/measurements deliberately. Re-estimate if the analysis does not close inside 90 h.

## M4 — one-target implementation

Core, sequential ring, selected map, two generator states, three tagged accounts, byte API and local release model. Real vectors/reference transitions replace the invalid idea of measuring seed-state entropy from output. All mandatory local proof obligations must discharge.

The explicit test-only issuer makes early output checks possible; those results are not production health/release qualification. Record four boundary rates and buffered latency separately. Accept zero-byte calls as no-op and requests up to 65,536 bytes only when eligible; count generated/discarded bits against refresh policy.

## M5 — real health and temporal release

Model-derived tests, uncertainty-aware defect mapping, snapshot-first handling, separate ICA/ORA and trusted receiver ledgers. Freeze detector observation horizons, clock/lease/propagation/commit bounds and finite outstanding permit budgets. Statistical detection does not become a structural zero-leakage guarantee merely because output is quarantined.

Run predeclared confidence-bound campaigns. Schedule from window cadence: three million opportunities take 3.47 days at 100 ms, 34.72 days at 1 s or 347.22 days at 10 s. The former 'start by week 60' rule is replaced by a calculated latest start that fits G5. Revise the detector/claim/schedule before acquisition if that plan is impossible. A weaker measured bound does not silently pass.

## M6 — actual deployment

Seven application PDs plus named timer/platform services. Protected SMMU policy where enforced, authentic health-to-release control, read-only staging snapshot into release-owned commit memory, client commit descriptor and protocol. Validate cross-domain replay/closure and scheduler interference. The supporting TCB includes fault/time/boot/configuration dependencies.

Compare against the same real-health single-address-space behavior. A malicious generator may supply arbitrary bytes under a valid permit; confinement prevents unauthorized delivery, not that separate correctness failure.

## M7 — full evidence

Qualify every retained cell of the **54-cell** manifest, with justified exclusions reflected in guidance. Use measured PTG.3 rate and settling/trajectory times for the T_irn schedule. Run 500 h burn-in, 50 thermal cycles, 1,000 real-use restarts and final fault/timing regressions as applicable.

All nine independent arguments must be accepted. Rebuild final artifacts, replay final analysis and invalidate evidence by transitive configuration/content dependencies. Physical recapture is distinct from deterministic analysis reproduction. The result is an evaluation-ready evidence package if every gate passes, not a certification claim.

## Campaign and human dependencies

| Dependency | Planning rule |
|---|---|
| Independent review | Reserve reviewers at M0; scope and accepted dispositions at each gate |
| Supported envelope | 54 explicit candidate cells; no invented 25-cell budget |
| Source settling/warming | Measured trajectory/equilibration controls define usable captures |
| False alarms | Opportunities × cadence, with dependence and acceptance plan specified |
| Startup detection | 2,995 zero-miss trials per selected class by default; include reset/rig turnaround |
| T_irn | 2,040,000 / qualified_ptg_rate seconds per run, plus allowed repeat and settling |
| Burn-in | At least 500 h of specified operation; interruptions recorded |
| Rework | Source/map/crypto/health/release changes invalidate dependent campaigns |

## Session discipline and scope control

Maintain STATE.md each session: last verified state, current assumptions, next small task, open proof/measurement issue. Break work packages into ≤4 h implementation sessions; the package estimates are not themselves session-sized tasks. Record actual effort and reforecast at every gate rather than preserving the original estimate by reducing evidence.

Frozen decisions: min-entropy variant, separate instances, byte API, trusted acquisition default, distinct input/output authorizations and a single commit owner. Open research: exact source bound, extraction/construction choice, final rate, supported physical range and timing contracts. Avoid expanding to additional sources/platforms before the reference path qualifies.

## Non-goals for v1

Certification submission; NTG.1 or DRT.1; Linux /dev/random integration; universal replay protection; independent multi-source entropy addition; formal proof of HAL/entire platform; a NIST validation claim merely from using its assessment tools; every optional backend and extraction route.

The offline [pipeline explorer](pipeline-explorer.html) visualizes the data, authorization, deployment and evidence paths and exposes the provisional rate/campaign arithmetic. It is an explanatory model, not a source of measurements or proof results.
