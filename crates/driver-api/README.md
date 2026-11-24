# `driver-api`

Shared executable vocabulary for the camera-to-entropy frame handoff.

This package is *shared executable vocabulary, not a shared theorem prover*. The
normative protocol, with the stable `FH-*` requirement identifiers referenced
throughout the source, lives in
[`proofs/contracts/frame-handoff.md`](../../proofs/contracts/frame-handoff.md).

Properties of this package are established by **shared interface review** plus
host unit tests. It carries no Creusot contracts and no Verus specifications:
both proof domains compile it as part of their own verified implementation
graph, so a dependency on either annotation crate would pull the other tool's
material into that graph.

Scope rules, binding on the implementation when it is written:

- No dependencies, `no_std`, no allocation, no `unsafe`.
- No runtime panics on any path: the wire codec indexes only fixed-size arrays
  at constant indices, so every bound is checked at compile time.
- No producer virtual pointer is ever exchanged. A frame is identified by
  buffer ID plus an offset into a predefined shared region; each protection
  domain resolves that description through its own mapping.
- Descriptor validation establishes bounds, layout, completion and identity
  freshness relative to a cursor. It cannot establish that DMA has stopped or
  that cache maintenance happened; those obligations belong to the producer
  protocol and the trusted memory-access layer.
