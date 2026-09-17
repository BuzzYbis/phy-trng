# M1 — Acquisition and capture

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Effort:** 90 h provisional · **Productive weeks:** 9–17 · **Gate:** [G1](GATES.md#g1)

## Objective and entry

Build the acquisition path on the M0 reference configuration and produce the data needed for a source-specific model. G0 must identify a viable configured sensor and DMA/trust profile. There is no credited entropy claim yet.

## Work packages — 90 h provisional

| Package | Hours | Output |
|---|---:|---|
| Source/metadata API | 16 | NoiseSource, Digitizer, SampleSeq and configuration identity |
| Camera HAL | 26 | Reproducible configuration/readback and DMA completion protocol |
| ROI and monitors | 22 | Bit extraction plus explicitly bounded failure detectors |
| Capture and archive | 20 | Labelled raw/frame data, metadata and hashes |
| Containment and scope review | 6 | Production tap exclusion and acquisition integrity argument |

## API contracts

`poll_raw` is nonblocking, bounded and allocation-free; it returns an initialized length no greater than the supplied slice. `Digitizer` names the raw-signal-to-number conversion independently of transport. `SampleSeq` and frame IDs are monotone within a boot session; overflow is an error. Mark EntropyClaim unvalidated and prohibit its use as runtime credit outside the explicit test harness.

Publish source/configuration identity, ROI layout, selected bit positions, integration/frame timing, sample ordering, full-value format/endianness and hardware error classes. Preserve enough metadata to reconstruct the exact estimator sequence. A configured subsampling rule is different from an accidental data gap.

## HAL and frame ownership

Write configuration then verify readback at boot and periodically during long captures. Configuration drift aborts or marks the capture invalid; no metadata copied only from intended settings. Document DMA completion, cache maintenance and CPU buffer ownership. Keep SMMU policy authority outside the potentially faulted producer in enforced profiles.

Do not invent a 'write-only frame mapping' if the platform rights do not support it. Record actual permissions and consequences. Raw producer buffers are not yet health-authorized snapshots; that ownership boundary is introduced in M5.

## Monitors and explicit negative cases

| Monitor | Positive scope | Demonstrated limitation |
|---|---|---|
| Frame equality | Repeated identical frame / selected freeze faults | Varied recorded frames can pass |
| Sequence/counter | Gaps, reorder, discontinuity | Fabricated coherent counters can pass |
| Mean/clipping band | Dark/saturated/out-of-model values | Plausible prerecorded noise can pass |
| Variance floor | Specific stuck-output cases | Variance alone does not establish entropy |
| Timeout | Missing completion/clock/data delivery | Timely substituted data can pass |

Document each detected fault and non-detection case. Physical provenance is covered by A-ACQ-1, not the statistical appearance of the stream. B-ARG-07 receives an independent initial review here and is updated after deployment.

## Capture contract

At least 20 h across four identified candidate supported cells. At 1.944 Mbit/s this is about 17.5 GB decimal for packed raw bits; full 10-bit frames are much larger, so retain representative full-frame windows deliberately. Every session stores source/unit identity, live register dump, tool/build version, temperature, voltage, illumination/lamp trajectory, frame/sample IDs and timing.

Archive captures and sidecars with immutable hashes and a manifest. Retain failures as labelled failures. Qualification sequences must be contiguous under the defined sampling rule; do not stitch separated captures into a fake uninterrupted sequence.

## Baseline measurements and handoff

Measure read-noise parameters, row/column common structure, spatial/temporal dependence, clipping, warm-up trajectory, drop rate and source throughput. These are inputs to M2, not entropy proofs. Reserve separate capture partitions for model fitting and held-out falsification.

Freeze source/metadata interfaces and capture schema. ROI spacing and raw-credit values remain open. Make mode changes versioned so M2 can invalidate the right captures. G1 delivers qualified acquisition behavior, scope statements, reviewed trust assumptions and usable data—not a working secure RNG.

## Acceptance and dependencies

At least 20 h of labelled captures across four cells; hashes/readback logs; monitor-scope document; reviewed A-ACQ-1 argument.

Canonical acceptance criteria are in [BENCHMARKS.md](BENCHMARKS.md); gate aggregation is in [GATES.md](GATES.md). The paired [milestone benchmarks](M1-benchmarks.md) list newly active items and methods. Prior gate results remain required only when applicable and dependency-valid. See [architecture](ARCHITECTURE.md) for authority, units and trust definitions.
