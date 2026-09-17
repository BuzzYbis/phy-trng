# Phy-TRNG — Architecture

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

> A `no_std`, allocation-free physical RNG research and engineering project targeting AIS 31 PTG.3, with a separately instantiated DRG.4 consumer interface and a seL4 deployment. Assurance is stated per layer and per supported build profile.

## 1. Scope, claims and decision status

The physical source is CMOS photon/read noise under controlled illumination. The lava lamp supplies a changing scene and is credited **zero entropy**. Its illumination and temperature still affect the noise model. General stream substitution is outside the default acquisition threat model; frame monitors are failure detectors, not authenticity mechanisms.

| Boundary | Intended claim | Required evidence |
|---|---|---|
| Raw samples | Model-supported conditional block entropy | B-ARG-05; B-ENT-01/02/03/07 |
| Stage 1 output | PTG.3.3 intermediate entropy, provisionally `v_m = 0.5` | B-ARG-01, source-specific extraction argument |
| Stage 2 output | PTG.3.5 explicit min-entropy claim, provisionally ≥0.98 per bit | **B-ARG-09**, complete output-entropy transfer |
| DRG.4 effective state | ≥246 effective state bits and ≥240 bits min-entropy after qualifying seeding/refresh | B-ARG-02/03; B-INT-05/06 |
| DRG.4 output | Computational expansion with request/refresh bounds | B-ARG-02/04; B-INT-03/04; B-STAT-04 |

PTG.3 is primary. The inner PTRNG meets PTG.3.1 and PTG.2.{3,4,5} without necessarily meeting PTG.2 in full. Apply [UPD25] HP.2: adapt P.12 and omit P.{8,16–17,19,21} when that variant applies. DRG.4 is a distinct downstream instance. PTG.2 is a separate future claim: it can use a justified fixed algorithmic map, qualifying universal hashing, or appropriately analyzed cryptographic post-processing. It is not automatically obtained by implementing a particular route.

Only the min-entropy variant is selected for v1. Shannon estimates may be diagnostic; no Shannon-specific claim or test obligation is silently added. A future selection change revises the evidence and gates.

Open choices are research outputs, not missing implementation defaults: source parameters and Stage 1 map at G2; construction, Stage 2 output bound and final block dimensions at G3; detector timing and release bounds at G5; per-target deployment qualification at G6.

## 2. Normative and supporting baseline

| Ref | Document | Use |
|---|---|---|
| KS24 | Functionality Classes for RNGs, v3.0, 2024-09-10 | AIS class definitions, requirements, application notes and T_irn |
| UPD25 | BSI Updates to Developer Evidence and ETR Templates, 2025-07-04 | Applicable evidence items and template changes |
| PTGDEV | Developer evidence for a physical true RNG, v0.8 | Base evidence text, subject to UPD25 |
| ERNG | Evaluation of random number generators, v0.10 | ST/PP and FCS_RNG.1 framing |
| 90B | NIST SP 800-90B, 2018; record applicable published errata | Noise-source assessment and health tests; use its own notation |
| 90A | NIST SP 800-90Ar1 | Candidate standardized DRBG mechanisms |
| 202 / 185 | FIPS 202 / SP 800-185 | SHA-3/SHAKE / cSHAKE/KMAC, if selected |
| 180 | FIPS 180-4 | SHA-256 and SHA-2, if selected |
| 22 | NIST SP 800-22r1a | Optional diagnostic statistical suite, never an entropy proof |
| 90C | NIST SP 800-90C, September 2025 | Reference for RBG composition; no NIST construction-conformance claim without a separate mapping |

The supplied reference PDFs are the baseline reading set. Pin document edition, relevant errata, exact implementation/tool versions and section references in the evidence package. Using NIST estimators does not imply NIST validation. AIS numbering always follows KS24 v3.0.

## 3. Constraints and build profiles

| Constraint | Enforcement |
|---|---|
| No runtime allocation | Caller-owned bounded buffers; final-binary allocator checks |
| No reachable runtime panics | Mandatory proof obligations plus linked-entry-point analysis |
| `no_std`, static dispatch | Per-profile build matrix; host tools are separate `std` binaries |
| Rust + Creusot contracts | Deterministic components and sequential models; pinned proof toolchain, explicit trusted boundaries |
| Bounded resources | Loop variants, explicit memory/buffer schedule and stack bounds |
| Fail closed | A specified release protocol with finite timing bounds, not an informal flag |
| Raw containment | Production external API has no raw/evidence tap; capability audit |
| Controlled unsafe | Only HAL, crypto FFI/hardware, synchronization/zeroization primitives and seL4 glue; every assumption inventoried |

M0 chooses one reference board/ISA. Other profiles are marked compile-only or fully qualified. A portable core build on `thumbv7em-none-eabihf` is not a claim that the full camera/seL4 system runs there. AArch64 and x86-64 are candidate deployment profiles; support is demonstrated, not inferred from a target triple.

## 4. End-to-end pipeline and boundaries

1. Physical photon/read fluctuations are digitized by the configured sensor.
2. Trusted acquisition records full frame metadata and selects the fixed ROI/LSB stream.
3. Health takes a **private snapshot first**, then tests that snapshot and any required subsequent observation horizon.
4. A finalized sample range receives an InputCreditAuthorization (ICA), consumed once by accounting/Stage 1.
5. Stage 1 maps the accepted block to intermediate random numbers under B-ARG-01.
6. The PTG.3 instance incorporates one intermediate input and produces only the output authorized by B-ARG-06/09.
7. Qualified PTG.3 output seeds or refreshes a **separate** DRG.4 state. PTG.3 output supplied as seed is itself counted at the PTG.3 boundary.
8. DRG.4 produces request-bounded computational output into staging, with a generation identifier and reseed-generation provenance.
9. `pd_release` consumes an independently issued OutputReleaseAuthorization (ORA), snapshots staging into its own commit buffer, validates current state and commits a bounded chunk to the client protocol.

Raw, intermediate, PTG.3 and DRG.4 bit rates have separate benchmark IDs. Test taps used to measure internal boundaries are disabled in production. Every generated DRG.4 block counts toward the refresh counter, including discarded or partially delivered blocks.

### 4.1 Ratios, widths and entropy quantities

| Symbol | Meaning |
|---|---|
| `N_raw` | Raw bits in one Stage 1 input block |
| `n_int` | Bits in one intermediate input to Stage 2 |
| `m_ptg` | PTG.3 bits produced before the next intermediate input |
| `r_ext = N_raw/n_int` | Stage 1 data compression; not an extraction theorem |
| `c_rate = n_int/m_ptg` | PTG.3.4 rate, per intermediate input, never a sliding average |
| `w_eff` | Documented entropy bottleneck of the chosen Stage 2 path; distinguish physical state size and effective computational state size |
| `h_credit` | Conservative runtime raw credit per bit, derived at G2 |
| `v_m`, `v_out` | Intermediate and PTG.3 output min-entropy claims, respectively |

PTG.3.4 requires `c_rate ≥ 1` and appropriate compression (KS24 ¶386–388). Arithmetic satisfying those checks is insufficient for PTG.3.5. B-ARG-09 analyzes the complete input-to-output mapping, including reseeding, any narrow intermediate map and final output transformation. KS24 ¶391–413 is the reference path. The ¶411(i) example shows why even a uniformly entropic 256-bit state followed by a particular hash mapping does not automatically justify 0.98 per output bit.

For the explicit PTG.3.5 claim, account for the latest intermediate input as required by ¶402; do not use accumulated historical state entropy to justify arbitrary continued PTG.3 output. Any failure-bridging argument is separate and does not silently change this normal-operation claim.

### 4.2 Illustrative rate calculation — not frozen parameters

| Quantity | Illustration |
|---|---|
| Sensor / ROI | 1920×1080 at 30 fps, 1 pixel in 32, one selected bit |
| Raw rate | 1,944,000 bit/s |
| Runtime credit | 0.01 entropy bit/raw bit |
| Credited entropy flux | 19,440 entropy bit/s |
| Stage 1 candidate | `r_ext = 50`, intermediate 38,880 bit/s, `v_m = 0.5` subject to B-ARG-01 |
| Stage 2 candidate | `n_int = 512`, `m_ptg = 256`, `c_rate = 2`; **unqualified until B-ARG-09** |
| Ideal budget envelope at `v_out = 0.98` | 19,440/0.98 ≈19,837 output bit/s, before losses |
| PTG.3 engineering aspiration | 16 kbit/s; G3 derives and freezes the attainable qualified target |

The budget envelope is a limit of the proposed credit policy, not a measured upper bound on physical entropy. Exceeding it invalidates that justification; it does not demonstrate creation of entropy. G3 may require more input, a wider state, output truncation or a lower rate. Startup inventory and finite measurement windows are reconciled separately from steady-state rate.

### 4.3 Stage 1 extraction routes

**Default candidate: Route B, fixed map with a source-specific bound.** Establish conditional block min-entropy from the physical model and derive its transfer through the actual selected map. Full matrix rank is a structural check, not an entropy theorem: an input distribution concentrated in a map's kernel can be destroyed by a full-rank linear map. Do not sum marginal pixel entropies without the required dependence assumptions.

**Alternative: Route A, randomized universal hashing.** Identify the applicable KS24 ¶337–342 conditions and selected functionality class. For the PTG.2 universal-hashing route these include per-output random selection, the required averaging/undercut conditions, secret indices, sufficient family size and the specified inter-index dependence limits. Address seed generation and its cost; do not substitute a DRG.3 index stream or permanently fixed matrix and still cite the same lemma. Adapt applicability to the selected PTG.3 inner claim explicitly with independent review; do not silently import a different entropy threshold.

For either route, state whether entropy is worst-case conditional or another precise conditional definition, the adversary's knowledge, accepted-data selection effects and the confidence/model assumptions. The required conditioned variables include scene, illumination, temperature, shared readout effects, previous frames and relevant earlier outputs. Measurement supports parameter/model checks; it does not certify arbitrary large-block entropy by itself.

## 5. Physical model, assessment and runtime credit

Use `P ~ Poisson(lambda)` and `X = Q(g P + R + b)`, including clipping in deterministic `Q`. Specify gain, offset, dark-current treatment, read-noise distribution, spatial/temporal dependencies and parameter uncertainty. Quantization is not an independent entropy source. Validate the model against falsifiable physical predictions and held-out captures.

Do not conflate the following quantities:

| Quantity | Role |
|---|---|
| `H_model` | Source/model-supported per-bit lower bound with declared conditions |
| `H_submitter` | Submitter estimate used in the 90B procedure; source-derived, not the reduced runtime credit |
| `H_original`, `H_bitstring` | 90B estimator outputs in their specified units |
| `H_I` | Initial 90B estimate; for binary sources `min(H_original,H_submitter)` |
| `H_r`, `H_c`, `H_90B` | Restart row/column assessments and final assessment under the actual 90B rules |
| `h_credit` | Runtime credit: at most `0.5 × min(H_model,H_90B)` under the project's selected margin policy |

Reject on a 90B sanity/validation failure before applying the margin. For non-binary assessment, include the prescribed bitstring track and alphabet reduction; record bits/sample versus bits/bit conversions. A positive runtime credit requires both the model argument and successful assessment. An estimator/model disagreement triggers investigation, not an automatic claim that one is infallible.

The restart process must represent actual use (90B §3.1.4); include startup inhibition and transient handling. M2's provisional startup policy is requalified after M5 fixes the real health implementation.

## 6. Acquisition and device trust

**A-ACQ-1:** sensor, physical interface and acquisition software are trusted for provenance inside the protected acquisition boundary. Stream substitution, including replay of varied valid frames by a compromised acquisition path, is outside the default claim. State the physical protection, firmware/configuration controls and user obligations explicitly. SeL4 memory isolation does not establish photodiode provenance.

Monitors detect identical frames, counter discontinuities, timeout, darkness, saturation and specified variance failures. Their reports name positive and negative cases. Option B authenticated physical freshness is an M0 feasibility study, not a shipped v1 feature.

For each deployment target, either confine device DMA with an independently protected IOMMU/SMMU configuration or declare **A-DMA-1**: the driver/device are trusted for DMA and their compromise can invalidate system isolation. The untrusted driver must not own the authority to broaden its own DMA mappings. Record device stream IDs, all DMA-capable paths, protected tables and fault routing for an enforced profile.

## 7. Health authorizations and protected data transfer

### 7.1 Snapshot ownership

Default: health copies raw input into a buffer writable only by health, finishes that copy, then evaluates tests on that stable snapshot. The same immutable bytes are handed to Stage 1. Slot reuse is prohibited until the downstream acknowledgement is checked. The assumed-trusted acquisition path covers whether the captured values are physically authentic; snapshot isolation covers later mutation.

An alternative ownership-transfer protocol must enforce immutability, publication ordering and lifetime. A tag over a producer-writable buffer is insufficient if the bytes can change after checking. Verify a tag against the same private snapshot subsequently consumed. Cache coherency, DMA completion, byte ordering and checked local copies of shared indices are explicit transport assumptions.

### 7.2 Two separate authorization records

| Field | InputCreditAuthorization (ICA) | OutputReleaseAuthorization (ORA) |
|---|---|---|
| Authority | Direct authenticated health channel | Direct authenticated health-to-release control channel |
| Identity | Boot session, epoch, unique ICA ID | Boot session, epoch, unique ORA ID |
| Binding | Source/configuration; immutable snapshot/slot generation; sequence range; length | Boundary; request ID; generation/reseed-generation ID; output sequence interval |
| Limit | Credited millibits, exact tested samples | Maximum committed output bytes/chunks; health lease/deadline |
| Consumer | Accounting / conditioner | `pd_release` only |
| Replay defense | Per-epoch trusted consumed-ID/range ledger | Per-epoch trusted consumed-ID/output-range ledger |

The two records are not one transferable token. Derive a release authorization only from the finalized health coverage and declared generation context. DRG.4 permits authorize a bounded computational expansion; they do not add physical entropy credit. ICA issuance is impossible before startup success and finalization of the relevant tests.

Rust non-`Copy` types support local ownership but provide **no cross-PD anti-replay guarantee**. Receiver ledgers and channel provenance enforce that guarantee. Reject reused/overlapping ranges, wrong configurations, old sessions/epochs and expired records. Reject counter overflow; never wrap identifiers. After whole-system reset, clear channels/buffers and establish a new boot-session identity before accepting traffic. Persist monotone identity or use a justified fresh identity if prior-session replay can survive reset.

Consume permits conservatively before commit; interruption burns the reserved range. Never refund a partially consumed authorization and release the same interval twice. Private Rust constructors live with the issuing implementation; cross-crate privilege is established through a concrete authority API, not an assumed Rust friend-crate feature.

### 7.3 Trust scope for a hostile generator

A hostile `pd_cond_drbg` may write staging but cannot directly write client output, forge issuer-channel messages, extend a lease or cause commits without an accepted ORA. With a valid ORA it may supply arbitrary bytes: the release component does **not** verify their randomness. Entropy correctness trusts the qualified generator implementation; hostile-generator testing establishes release confinement only. Count those claims separately in the assurance table.

## 8. Release protocol, time and failure handling

### 8.1 State machine and commit point

Release states are `Closed → Startup → Ready`, with `Ready → Revoking → Closed` on alarm/fault, and `Closed → Startup` only by full reinitialization. A lease expiry enters `Closed`. Refresh starvation is a blocked availability state, not necessarily an entropy alarm; it cannot authorize further output.

Only release owns the client-visible commit descriptor and output write capability. It copies a bounded staged chunk to a private commit buffer; validates its trusted ORA, epoch, lease and remaining byte budget; then publishes the bounded client chunk/descriptor at a named linearization point. The generator cannot rewrite the private commit buffer. Client protocols must prohibit consumption before commit.

On error the byte-oriented API reports `written` for diagnostics, but the caller must discard the whole request buffer. Bytes previously committed cannot be recalled. Generated/discarded output still debits all relevant generation counters. Request IDs, partial completion and duplicate retries are explicit protocol cases.

### 8.2 Three instants and the actual guarantee

| Instant | Meaning | Required bound |
|---|---|---|
| `t_fault` | Physical/source fault begins | Detector-specific latency/miss model |
| `t_alarm` | Health detects it | Propagation and scheduling bound to release |
| `t_close` | Release observes revocation and stops commits | Includes any bounded non-preemptible commit section |

After `t_close`, no commit using the revoked epoch is permitted. Between `t_alarm` and `t_close`, the specification bounds possible commits/bytes and explains their security. Health silence stops commits no later than the lease deadline plus the specified clock/check/commit tolerance. Enforce expiry using a trusted monotone clock accessible to release; reserve scheduling budget so a hostile producer cannot starve revocation handling.

Do not claim instantaneous distributed revocation. Define `Delta_detect`, `Delta_propagate`, `Delta_commit`, clock tolerance and maximum outstanding authorized bytes at G5; verify cross-domain bounds at G6. A bound on bytes cannot rely on average throughput. Limit pending permits and per-permit bytes structurally. `pd_fault`, the timer and relevant boot/scheduling configuration are in the supporting TCB.

### 8.3 Quarantine and bridging

Default candidate: quarantine accepted input/output until all required tests and a detector-specific **observation horizon** complete. Compute the holdback from the fault model, detector look-ahead, buffering and propagation assumptions. Closing one statistical window does not prove every physical fault has been detected.

For fault classes with a justified deterministic detection bound and adequate holdback, prove a conditional no-post-fault-dependent-release property. For statistical defects, state the miss probability and exposure bound; never relabel a probabilistic test as a structural guarantee. Test fault onset at every relevant phase, including the end of a window and during commit.

Bounded cryptographic bridging is an alternative requiring its own analysis under PTG.3.8 and the applicable output boundary. It specifies state compromise assumptions, entropy/security retained during detection, maximum emitted bits and stop conditions. An authorization lease is not itself a bridging proof. No production configuration passes G5 with an unproved bridging assumption.

## 9. Generator selection, composition and accounting

Choose at G3 by security evidence: a specified sponge/duplex construction with a justified ratchet, Hash_DRBG under 90A, or the KS24 ¶994–995 construction. An invertible Keccak permutation alone does not establish a one-way state transition. Describe the full nine-tuple, request-state evolution, additional input, domain separation, reseeding, erasure and exposure at every relevant point.

Select enhanced-backward-secrecy granularity explicitly. Per-request granularity needs conceptual atomicity; per-number granularity needs an argument over the actual request-state and persistent-state schedule. Do not infer security from the location of a single function call. Additional input must satisfy the chosen construction's adversarial-input argument; 'absorbed' alone is not a proof.

PTG.3 and DRG.4 have separate states and labels. B-ARG-03 derives entropy in each qualifying seeded/refreshed DRG.4 state; B-ARG-09 independently derives PTG.3 output entropy. B-ARG-04 closes their acyclic composition, including non-reuse and freshness of seed material.

DRG.4 requests are byte-oriented, **1–65,536 bytes**; a zero-length request is a no-op with no state/counter change. Requests larger than 65,536 fail before mutation. Internally check conversions without overflow. At ≥2^17 generated bits since refresh, admit no new generating request. A request admitted below that threshold may complete under KS24 ¶239, but has at most 2^19 bits. An implementation-independent bound before the next refresh is strictly below `2^17 + 2^19` bits; document a tighter block-aligned bound if used. Alarm/expiry always overrides the completion permission.

Use three tagged accounts: raw credited entropy, intermediate entropy, and retained state entropy. Transfer/debit claims according to their arguments, never by copying a balance between accounts. Round credits down and required debits up. A saturating accumulator must not conceal overlap/replay or lost debits. Exhaustion blocks output or requests more input; overflow of identity/counters fails closed.

Reservations for reseeding are unique, secret, age-bounded and health-authorized. A state-compromise recovery claim cannot rely on a reservoir exposed by that compromise: require post-compromise fresh material or a separately protected reservoir with an explicit argument. Cached/uncached refresh latency are separate benchmarks.

## 10. Workspace and deployment

| Crate | Responsibility | Assurance |
|---|---|---|
| `ptrng-core` | Errors, amounts, epochs, identifiers, budget models | Mandatory contracts |
| `ptrng-spsc` | Sequential ring | Sequential FIFO/ownership proof |
| `ptrng-xfer`, `ptrng-sync` | ISR/cross-domain transport and low-level primitives | Hostile-index proofs; explicit ordering assumptions |
| `ptrng-source`, `ptrng-hal-*`, source implementations | Acquisition, model-linked configuration, monitors | Safe transforms proved; HAL/provenance trusted |
| `ptrng-health` | Tests, stable snapshots, ICA/ORA issuance | Contracts plus statistical rationale |
| `ptrng-cond` | Chosen Stage 1 route | Implementation refinement plus B-ARG-01 |
| `ptrng-crypto`, selected backends | Selected primitives and KATs | Per-artifact proof scope; independent reference |
| `ptrng-drbg` | Two generator instances | Contracts plus B-ARG-02/03/04/06/09 |
| `ptrng-release`, `ptrng-api` | Commit gate, replay ledgers, byte API | Mandatory release/protocol properties |
| `ptrng-evidence`, `ptrng-tools` | Evidence, capture, analysis, gates | Host tools; reviewed analysis infrastructure |
| `sel4-phytrng` | Deployment description, timer/fault/bootstrap glue | Capability/configuration argument |

SHA-256 selection requires an actual SHA-256 backend and FIPS 180-4/90A vectors. Keccak selection requires the selected FIPS 202/185 mechanisms only. Formosa is conditional on available target/artifact support. A soft-primary profile uses an independent oracle and its own proof scope; it is never blocked by an inapplicable Formosa differential requirement.

| PD | Data rights and authority |
|---|---|
| `pd_sensor` | Camera/device and confined DMA region; no authority to broaden protected SMMU policy |
| `pd_source` | Read completed frames; publish raw stream |
| `pd_health` | Read raw stream; own snapshot write rights; publish ICA and ORA directly to their consumers; publish alarm/epoch |
| `pd_cond_drbg` | Read immutable accepted snapshots and ICA; own generator states; write staging; no client write mapping |
| `pd_release` | Read authentic ORA/epoch channel and trusted clock; read staging; own private commit buffer and client write/commit capability |
| `pd_api` | Client endpoints and request routing; no raw or generator-state mapping |
| `pd_fault` | Fault notifications; bounded shutdown/revocation control |

Timer/bootstrap/scheduling support may be separate PDs or trusted platform services; list them in the actual profile. Release erases its **own writable commit buffer**. The generator erases staging during cooperative cleanup; restart management scrubs/reinitializes shared staging after a crash. Do not require a read-only mapping to zeroize memory, or rely on a hostile generator to do so.

The entropy boundary includes sensor, source, health, both generators and release. The supporting TCB also includes fault/time/bootstrap, SMMU configuration where used, dependent libraries, compiler assumptions and relevant kernel/platform assumptions. Report application SLOC separately from complete dependency inventory; a 300-line release module is a reviewability target, not proof that its dependencies are absent.

## 11. Assurance and evidence

| Layer | Supported claim |
|---|---|
| Core/sequential code | Named functional properties, termination and panic freedom |
| Concurrent transport | Bounds/ownership properties plus stated memory-ordering assumptions |
| Primitive implementation | Exactly the functional/leakage properties covered by the selected artifact |
| Generator construction | Reviewed security argument under named cryptographic assumptions |
| Physics | Conditional model-derived entropy supported by measurements |
| Deployment | Composition under capability, hardware, timing and acquisition assumptions |

Creusot remains the selected contract-verification tool for deterministic Rust components and sequential models. Pin compatible Rust/Creusot, Why3 and solver versions, library specifications and proof sessions; replay from a clean checkout. Its proved model does not automatically cover interrupt ordering, FFI, DMA, physics or cryptographic hardness. M0 validates expressiveness before the implementation depends on a signature.

All mandatory obligations must be discharged: no `admitted`, skipped, unresolved or timeout result may count as proof. A trusted boundary is separately listed and justified; it does not become a discharged proof by annotation. Coverage is a secondary metric. Track loop termination, failed-call effects, amount rounding, identifiers, buffer lifetime, range disjointness and release linearization explicitly.

Zeroization claims concern identified buffers and compiled code paths. Document residual register/spill/copy/fault risks and inspect generated code for selected secret-bearing types. No broad physical-erasure claim follows merely from `Drop`.

Nine independent argument items are mandatory by their gates: B-ARG-01 extraction, 02 construction, 03 seeding, 04 composition, 05 stochastic model, 06 effective compression, 07 acquisition integrity, 08 assumptions, **09 PTG.3 output entropy**. Review completion requires dispositions accepted or explicitly unresolved; a response alone does not close a substantive objection.

The evidence matrix links requirement → argument/proof/test → code/configuration → artifact → assumption. Pin artifacts and data hashes. A change invalidates dependent results by content/configuration dependency, not only by filename or timestamp. One command reproduces analysis of archived acquisition; physical recapture is a separately identified campaign.

## 12. Decisions and freeze points

| Decision | Status / gate |
|---|---|
| Min-entropy variant; separate PTG.3/DRG.4 states; byte API | Fixed for v1 |
| Wax = zero credit; trusted acquisition plus bounded detectors | Fixed default; A-ACQ-1 |
| Per-target DMA enforcement or explicit trust | M0 choice, M6 qualification |
| Stage 1 Route B candidate and source model | G2; numeric freeze may reopen at G3 |
| Construction, exact primitive set, Stage 2 output proof, final dimensions | G3 |
| ICA/ORA separation, private snapshots, trusted commit owner | Fixed architectural contract |
| Detector observation horizons, lease/propagation/commit bounds | G5 then cross-domain G6 |
| Reference target first, other targets explicitly qualified | M0 profile choice |
| RO-jitter fallback | Separate source model/health/environmental budget; provisional +120 h |

## 13. Second-review closure map

| Finding | v0.3 resolution |
|---|---|
| Missing Stage 2 entropy proof | B-ARG-09 and G3; final rate conditional on proof |
| Seed-state entropy inferred from output | B-ENT-08 now implementation regression only |
| Tokens treated as IPC anti-replay | Separate ICA/ORA plus trusted receiver ledgers and channel provenance |
| Quarantine overclaim | Three instants, detector horizons, probabilistic/deterministic scope and explicit closure bounds |
| Reversed confidence formula | Exact binomial lower/upper bounds and predeclared acceptance rules |
| 90B/runtime claim conflation | H_submitter/H_I/H_90B separated from h_credit |
| Optional backend blocks gate | Build-profile applicability matrix and independent-oracle fallback |
| Timing and campaign assumptions | Buffered/uncached cases; formula-based campaign plan; 54 explicit envelope cells |

Companion files: [benchmarks](BENCHMARKS.md), [gates](GATES.md), [roadmap](ROADMAP.md), and the offline [interactive pipeline explorer](pipeline-explorer.html). All milestone pairs are in this directory.
