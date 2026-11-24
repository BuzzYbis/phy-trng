# Phy-TRNG — Glossary

**Version 0.3.1. Reading aid for the design specification; it defines terms and does not change any requirement.**

Standards terms follow [KS24] (BSI, *A Proposal for Functionality Classes for Random Number Generators*, v3.0). Where this glossary paraphrases, the standard's own wording governs. Symbols for widths, ratios and entropy quantities are defined in [ARCHITECTURE §4.1](ARCHITECTURE.md#41-ratios-widths-and-entropy-quantities) and [§5](ARCHITECTURE.md#5-physical-model-assessment-and-runtime-credit).

## Standards and certification

| Term | Meaning |
|---|---|
| AIS 20 / AIS 31 | BSI application notes for evaluating deterministic (AIS 20) and physical (AIS 31) RNGs under Common Criteria. KS24 is their mathematical-technical reference. |
| KS24, UPD25, PTGDEV, ERNG, 90A/90B/90C, 22 | Reference documents; see [ARCHITECTURE §2](ARCHITECTURE.md#2-normative-and-supporting-baseline). |
| ¶n | Numbered paragraph n of KS24, for example ¶239. |
| CC | Common Criteria (ISO/IEC 15408). |
| ST | Security Target: the CC document stating the security claims and the assumptions about the environment. |
| TOE | Target of Evaluation: the product under evaluation. |
| FCS_RNG.1 | The CC security functional requirement for random number generation; its selections name the functionality class. |
| PTRNG | Physical true RNG. A *pure* PTRNG's security rests on physical entropy alone. A *hybrid* PTRNG adds cryptographic post-processing, a second security anchor (KS24). |
| PTG.2, PTG.3 | KS24 PTRNG functionality classes. PTG.3 is a hybrid PTRNG: an inner PTRNG followed by cryptographic post-processing with memory. PTG.3.1–PTG.3.9 are its requirements. PTG.3.5 offers several choices; this project selects an explicit min-entropy claim. |
| Inner PTRNG | The physical part of a PTG.3 design that feeds the cryptographic post-processing. Here it meets PTG.3.1 and PTG.2.{3,4,5}. |
| DRNG, DRBG | Deterministic RNG (AIS term) and deterministic random bit generator (NIST term). |
| DRG.3, DRG.4 | KS24 DRNG classes. DRG.3 adds enhanced backward secrecy; DRG.4 is a hybrid DRNG seeded and reseeded from a PTRNG, which adds enhanced forward secrecy. DRG.4.1–DRG.4.11 are its requirements. |
| NTG.1, DRT.1 | KS24 classes for non-physical true RNGs and DRNG trees; both out of scope for v1. |
| Enhanced backward secrecy | Knowing the current internal state does not let an attacker derive previous outputs with practical effort (KS24 glossary). |
| Enhanced forward secrecy | Knowing the current internal state does not let an attacker derive later outputs with practical effort; DRG.4 achieves it by reseeding. |
| Nine-tuple | KS24's formal description of a DRNG: state spaces, input sets and the state-transition and output functions. |
| Raw, intermediate and internal random numbers | KS24 terms. *Raw*: digitized noise. *Intermediate*: output of Stage 1, input to Stage 2. *Internal*: the RNG's output before any external interface. |
| T_irn | KS24's black-box statistical test suite on internal random numbers (¶904 ff.): monobit, poker, MultiMMC and LZ78Y tests over 2,040,000 bits. It checks statistical inconspicuousness and is not an entropy proof. |
| HP.x, P.x, HD.x, D.x | Developer-evidence items from PTGDEV/UPD25: P = PTRNG, HP = hybrid PTRNG (PTG.3), D = DRNG, HD = hybrid DRNG (DRG.4). |
| Min-entropy | Entropy measured by the probability of the most likely value: −log₂ p_max. The only entropy variant claimed in v1. |
| RCT, APT | Repetition Count Test and Adaptive Proportion Test: the SP 800-90B health tests. |
| KAT | Known-answer test: an official test vector checked against an implementation. |
| Oracle | An independent reference implementation used for differential testing (B-VER-08). |

## Design terms

| Term | Meaning |
|---|---|
| Stage 1 | The map from accepted raw bits to intermediate random numbers (B-ARG-01). |
| Route A, Route B | Stage 1 options: randomized universal hashing (A) or a fixed map with a source-specific bound (B, the default candidate). See [ARCHITECTURE §4.3](ARCHITECTURE.md#43-stage-1-extraction-routes). |
| Stage 2 | The PTG.3 cryptographic post-processing that turns intermediate inputs into PTG.3 output (B-ARG-09). |
| Lava lamp, wax | The lamp supplies a changing scene and its wax affects illumination and temperature. Credited zero entropy. |
| ROI | Region of interest: the rule selecting which pixels and bits enter the raw stream. |
| Bayer CFA | The colour filter array over the IMX296 pixels; each pixel sees R, G or B. |
| RAW10 | 10 bits per pixel, unprocessed sensor output. |
| Unicam, CSI-2 | The BCM2711 camera receiver, and the MIPI camera interface it implements. |
| VideoCore | The Broadcom GPU/VPU on the Raspberry Pi; it runs closed firmware that boots the ARM cores. |
| RO-jitter | Ring-oscillator jitter: the alternative entropy source considered at G2 if the camera source fails. |
| Snapshot | A health-owned, immutable copy of raw data; the bytes tested are the bytes consumed. |
| ICA | InputCreditAuthorization: health's single-use permit for Stage 1 to credit one tested snapshot range. |
| ORA | OutputReleaseAuthorization: health's single-use permit for `pd_release` to commit a bounded output interval. It adds no entropy credit. |
| Boot session, epoch | Identifiers that invalidate authorizations after a reset (session) or a health alarm (epoch). |
| Lease | The deadline after which an unrenewed authorization stops all commits. |
| t_fault, t_alarm, t_close | Fault onset, detection by health, and the point after which release commits nothing. See [ARCHITECTURE §8.2](ARCHITECTURE.md#82-three-instants-and-the-actual-guarantee). |
| Observation horizon | How long accepted data is held back so a detector can still flag a fault that began inside it. |
| Bridging | A cryptographic argument that bounds output emitted between a fault and its detection; an alternative to quarantine. |
| Staging, commit buffer | Generator-writable output area, and release's private copy that clients receive. |
| A-ACQ-1 | Assumption: the sensor, interface and acquisition software are trusted for provenance. |
| A-DMA-1 | Assumption: the camera device and driver are trusted for DMA. Default on Raspberry Pi 4; see [ARCHITECTURE §6.1](ARCHITECTURE.md#61-claims-under-a-dma-1). |
| DMA, IOMMU/SMMU | Direct memory access by a device, and the hardware unit that confines it. |
| Profile | A build configuration: target, construction, crypto backend, oracle, DMA mode, clock/fault mechanism and active evidence. |

## Deployment and verification

| Term | Meaning |
|---|---|
| seL4, Microkit | Formally verified microkernel, and its framework for static systems of protection domains. |
| PD | Protection domain: an isolated seL4 Microkit component, such as `pd_health`. |
| TCB | Trusted computing base. The *entropy boundary* holds the components the entropy claim depends on; the *supporting TCB* adds time, fault, boot, configuration, libraries, compiler and platform. |
| Creusot, Why3, why3find, Coma | Rust deductive verifier, the platform it proves through, Why3's proof-search tool, and Creusot's intermediate output (`verif/`). |
| Verus, vstd | Rust verifier planned for the camera driver, and its standard library of specifications. |
| Alt-Ergo, CVC5, Z3 | SMT solvers used to discharge proof goals. |
| Trusted boundary | Code whose specification is assumed, not proved (`unsafe`, `#[trusted]`, `external_body`, FFI); inventoried in `proofs/tcb.md`. |
| Formosa | Formosa Crypto project; supplies formally verified Keccak implementations. |
| Keccak, SHA-3, SHAKE | The permutation and the hash/XOF functions built on it (FIPS 202). |
| ISA | Instruction set architecture, such as AArch64. |
| SLOC | Source lines of code. |
| ADR | Architecture decision record. |

## Plan, gates and evidence identifiers

| Term | Meaning |
|---|---|
| M0–M7 | Milestones; each has an architecture file and a benchmarks file. |
| G0–G7 | Milestone gates; G*n* closes M*n*. Defined in [GATES.md](GATES.md). |
| CI check | A script in `ci/`, which that directory calls a *gate*. `make gates` runs them. They produce evidence for the milestone gates but are not G0–G7. |
| BLOCKING, ADVISORY | Benchmark levels: a BLOCKING item must pass its gate; an ADVISORY item needs a recorded owner, consequence and disposition. |
| Commit, Scheduled, Campaign, Review | Benchmark tiers by cadence; see [BENCHMARKS §7](BENCHMARKS.md#7-ci-staleness-and-result-schema). |
| Cell, envelope | One environmental condition (temperature, voltage, lamp, ambient), such as T2-V2-L2-A2; the envelope is the 54-cell supported set ([BENCHMARKS §2](BENCHMARKS.md#2-environmental-matrix-and-campaign-manifest)). |
| B-STAT | Statistical tests on output (T_irn, SP 800-22). |
| B-ENT | Entropy assessment of the raw source, and Stage 1/seeding implementation regressions. |
| B-ARG | Independently reviewed arguments; nine in total. |
| B-HLT | Health-test efficacy and false-alarm campaigns. |
| B-PERF | Throughput, latency and timing. |
| B-FOOT | Memory, stack, allocation, unsafe and TCB footprint. |
| B-VER | Formal-verification obligations and proof replay. |
| B-ROB | Robustness across the environment, restarts and burn-in. |
| B-INT | Integration and interface properties: confinement, request limits, DMA, authorization binding. |
| B-EVD | Evidence coverage, traceability, provenance and reproducibility. |
