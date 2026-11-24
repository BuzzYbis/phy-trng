# Frame handoff contract

Status: normative cross-component contract. Revision 2, 2026-09-19.

**Nothing in this contract is implemented yet.** It specifies what the
implementation must do; it records no result. Every named type and function
below is a design commitment, not existing code.

This document owns the `FH-*` requirement identifiers. They are stable: an
identifier is never reused for a different obligation, and a change of meaning
requires a new identifier and a new
[`PROTOCOL_VERSION`](../../crates/driver-api/src/lib.rs) where the wire format
is affected.

The identifiers are mirrored in [`proofs/creusot/coverage.md`](../creusot/coverage.md)
and [`proofs/verus/coverage.md`](../verus/coverage.md). Mirroring is a review
device, not proof transfer: **there is no automatic proof transfer between
Creusot and Verus.** A review must show that the Verus guarantees discharged on
the producer side imply the preconditions the Creusot side assumes.

## 1. Parties and scope

| Party | Role | Proof owner |
| --- | --- | --- |
| Camera protection domain | Producer: programs the sensor and receiver, owns buffers, publishes descriptors | Verus |
| `driver-api` | Shared executable vocabulary: descriptor type, numeric tags, wire codec, consumer-side checks | Shared interface review plus host tests |
| Entropy protection domain | Consumer: validates descriptors, reads payloads, releases buffers | Creusot for the processing it feeds |
| Microkit system description | Mappings, IRQ and DMA assignments that make the identifiers resolvable | System configuration review |
| `camera-mmio` | Volatile accesses, barriers and cache maintenance | Audited trusted code |

A crate is a build unit, not a protection domain. Runtime isolation is defined
by `system/rpi4/`, not by this contract.

## 2. What crosses the boundary

A frame is identified by **buffer ID plus offset into a predefined shared
region**. A producer virtual pointer is never exchanged: each protection domain
resolves the buffer ID through its own mapping, and the consumer checks the
offset against the size *it* has mapped, never against a size supplied by the
producer.

Two messages exist:

1. **Publication**: a serialized `FrameDescriptor`, producer to consumer.
2. **Release**: a `ReleaseToken` (`buffer_id`, `generation`, `capture_epoch`),
   consumer to producer.

`BufferState` is producer-private and is not serialized. It is defined in
`driver-api` so that both proof domains name the same lifecycle.

## 3. Wire format

Little-endian, no padding, no reliance on `repr(C)` layout. These offsets are
normative, and the implementation's test suite must assert them directly
rather than deriving them from the Rust struct layout.

| Offset | Width | Field | Notes |
| ---: | ---: | --- | --- |
| 0 | 2 | `protocol_version` | `u16`; rejected if not implemented |
| 2 | 2 | `status` | validated tag |
| 4 | 4 | `buffer_id` | `u32` |
| 8 | 4 | `generation` | `u32`, per-buffer reuse counter |
| 12 | 4 | `capture_epoch` | `u32`, incremented per receiver restart |
| 16 | 8 | `sequence` | `u64`, within one epoch |
| 24 | 4 | `offset` | `u32`, bytes from the start of the buffer |
| 28 | 4 | `payload_len` | `u32` |
| 32 | 4 | `stride` | `u32`, row length including padding |
| 36 | 2 | `width` | `u16`, pixels |
| 38 | 2 | `height` | `u16`, rows |
| 40 | 2 | `packing` | validated tag; host-memory packing |
| 42 | 2 | `bayer_order` | validated tag |
| 44 | 4 | reserved | `u32`, must be zero on encode and on decode |
| | 48 | total | |

## 4. Obligations

The **Owner** column says who must discharge the obligation. **Intended
mechanism** names the design commitment that will carry it. None of it exists
yet, so no row here is evidence of anything: this table is the specification
against which the implementation will be reviewed.

### FH-VER — protocol agreement

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-VER-1 | The consumer rejects any descriptor whose `protocol_version` it does not implement. | Consumer | Consumer-side header validation |
| FH-VER-2 | Every raw integer tag is validated before conversion into a Rust enum. No unvalidated integer is transmuted into an enum. | Shared | Checked tag conversion in the wire decoder |
| FH-VER-3 | The serialized form has a specified byte order and specified offsets, publishes no padding or uninitialised byte, and zeroes the reserved field. | Shared | Encoder builds a fixed-size array field by field, never a struct cast |

### FH-BND — bounds

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-BND-1 | The identified range fits the buffer the consumer approved: `offset + payload_len <= mapped_size`, against the size the **consumer** mapped, never a producer-supplied size. | Consumer | Consumer-side bounds check |
| FH-BND-2 | Every size computation uses checked arithmetic and fails closed on overflow. No wrapping, and no saturation that could hide a wrong range. | Shared | `checked_*` arithmetic throughout bounds and layout checking |

### FH-LAY — layout

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-LAY-1 | `payload_len` and `stride` agree with the configured **in-memory** format. CSI-2 RAW10 on the wire does not imply tightly packed RAW10 in RAM, so the host-side packing is named explicitly by the `packing` tag. | Producer states, consumer checks | An explicit packing tag, distinct from the wire format |
| FH-LAY-2 | The stride is at least the minimum row length the packing requires for the width. It may exceed that for receiver or DMA alignment; it may never fall below it. | Consumer | Consumer-side layout check |
| FH-LAY-3 | `width` and `height` are non-zero, and `payload_len == stride * height`. | Consumer | Consumer-side layout check |
| FH-LAY-4 | The programmed sensor mode and receiver configuration actually produce the declared packing, stride and geometry. | Producer | not yet implemented; requires successful mode programming on hardware |

### FH-OWN — ownership

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-OWN-1 | The device is no longer writing a buffer when its descriptor is published. | Producer | not yet implemented; Verus against the device model plus the hardware assumptions in [`../tcb.md`](../tcb.md) |
| FH-OWN-2 | The producer cannot requeue a published buffer until the consumer releases it. Lifecycle: `Free -> DeviceOwned -> Ready -> ConsumerOwned -> Free`. | Producer | A producer-private lifecycle state per buffer |
| FH-OWN-3 | A release is applied only when `buffer_id`, `generation` and `capture_epoch` all match the buffer's current occupant, so a late release cannot free a buffer the device now owns. | Producer | A release token carrying the full identity, plus the matching rule |
| FH-OWN-4 | The consumer's access to a payload is bounded by a lease held by the layer that owns the mapping. No ordinary Rust reference is created into a region while hardware may mutate it incompatibly with that reference's guarantees. | Consumer | A lease type; a validated descriptor must not itself be a read capability |

### FH-VIS — visibility

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-VIS-1 | Required cache maintenance and ordering precede publication. | Producer, via audited primitives | not yet implemented; `camera-mmio` does not exist yet |
| FH-VIS-2 | Required cache maintenance and ordering precede consumption. | Consumer, via audited primitives | not yet implemented |

Volatile accesses are not atomic synchronization and do not replace DMA cache
maintenance or device ordering. Any claim that they do is a defect, not an
assumption.

### FH-ID — identity and freshness

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-ID-1 | Generation and epoch reject stale descriptors and stale releases. | Both | A consumer cursor, and identity carried on the release token |
| FH-ID-2 | A descriptor from another epoch is rejected. Adopting a new epoch is a deliberate act, performed only once the producer's restart protocol has completed. | Consumer | An explicit cursor restart operation, never automatic adoption |
| FH-ID-3 | Sequence numbers order frames within an epoch. They do **not** prove physical freshness; that rests on the acquisition argument `A-ACQ-1` in [`doc/ARCHITECTURE.md`](../../doc/ARCHITECTURE.md). | Review | documented here; no code can discharge it |
| FH-ID-4 | Integer exhaustion fails closed. `sequence` at `u64::MAX` cannot be advanced past; a new epoch is required. `generation` and `capture_epoch` exhaustion fails closed rather than wrapping. | Both | Fallible counter advance on both sides |

### FH-CMP — completion

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-CMP-1 | Only a status meaning "complete" may enter the entropy pipeline. | Consumer | Consumer-side header validation |
| FH-CMP-2 | The producer sets `Complete` only after a valid completion event in its hardware model with no relevant capture error. | Producer | not yet implemented |

### FH-FAIL — failure handling

| ID | Obligation | Owner | Intended mechanism |
| --- | --- | --- | --- |
| FH-FAIL-1 | A failed validation prevents the affected frame entering the entropy pipeline. | Consumer | Every validation error path |
| FH-FAIL-2 | Reset and restart races have an explicit policy: the consumer does not adopt a new epoch until the previous epoch's outstanding DMA writes have quiesced. | Both | policy stated here; producer-side quiescence argument not yet implemented |
| FH-FAIL-3 | A faulted buffer enters a quarantined state, and reset alone does not make it reusable. Reuse requires an established DMA-quiescence argument. | Producer | A quarantined lifecycle state, plus the quiescence argument |
| FH-FAIL-4 | Frames already published when a fault is detected have an explicit disposition, recorded per fault class. | Both | not yet implemented |

## 5. What validation cannot establish

Consumer-side descriptor validation is intended to discharge FH-VER-1,
FH-BND-1, FH-BND-2, FH-LAY-1 through FH-LAY-3, FH-CMP-1 and FH-FAIL-1. Even
once written, it cannot independently establish:

- that DMA really stopped (FH-OWN-1),
- that cache maintenance and ordering happened (FH-VIS-1, FH-VIS-2),
- that the declared packing matches the programmed mode (FH-LAY-4),
- that the samples are physically fresh (FH-ID-3).

Those depend on the producer protocol, the system mappings and the hardware
assumptions inventoried in [`proofs/tcb.md`](../tcb.md). Whatever type
represents a validated descriptor must therefore **not** be a capability to
read memory: passing validation is not permission to dereference.

## 6. Change control

Changing the wire layout, a tag assignment or the meaning of a field requires,
in one change: a new protocol version, an updated section 3, updated
assertions in the `driver-api` test suite, and updated entries in both
coverage inventories. `ci/check-trust.sh` does not detect a protocol change; review does.
