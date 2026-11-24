# `ptrng-spsc`

Bounded sequential ring buffer with a proved FIFO and ownership model.

Proof owner: **Creusot**. **Not implemented yet** — this crate is currently
scaffolding: a manifest, these scope rules and a crate-level doc comment.
Coverage is inventoried in
[`proofs/creusot/coverage.md`](../../proofs/creusot/coverage.md), which
records zero goals for this package today.

## Scope, and what this crate does not claim

Despite the name, this is a **sequential cooperative** model: one caller at a
time, no concurrency. `doc/ARCHITECTURE.md` section 10 scopes `ptrng-spsc` as
the *sequential ring* with a *sequential FIFO/ownership proof*, and
`doc/M4-architecture.md` states plainly that cross-PD ordering and hostile
mutation are M6 obligations.

Concurrent transport — an ISR producer, a cross-domain consumer, hostile
shared indices — belongs to `ptrng-xfer`/`ptrng-sync`, which need explicit
memory-ordering assumptions that Creusot does not discharge. **A proof in this
crate says nothing about those.** Using this type across a real concurrency
boundary would be unsound, and no proof here would detect that.

## Obligations to discharge

From `doc/M4-architecture.md`, "Sequential buffers and extraction".
None of these is proved yet.

| Obligation | Intended mechanism |
| --- | --- |
| Capacity and length bounds | `Invariant`: `head < N`, `len <= N` |
| Push and pop count bounds | `try_push` / `pop` postconditions on `@.len()` |
| FIFO order | `pop` returns `@[0]`; the remainder shifts by one |
| Initialized reads | the model has exactly `len` elements; `pop`/`peek` read only within it |
| No unread overwrite | `try_push` on a full ring returns `Full` and leaves the model unchanged |
| Empty and full distinguishable | the length is stored, so `head == tail` is never ambiguous |
| Peek lifetime | `peek` returns by value, so no borrow outlives the call |
| Panic freedom, termination | discharged with the rest; every index proved in range |

## Design note: no modulo

Established by the M0 P4 probe, and binding on the implementation when it is
written.

Slot arithmetic must wrap with a branch, not `%`. The two are equivalent
because both operands stay below `N`, but the solvers discharge the
non-aliasing argument — that writing the tail never disturbs a stored
element — automatically for the branch form and **not** for `%`, where the
obligation is left unproved with no useful counterexample. The branch form
also avoids a division in the emitted code.

```rust
let tail = if len < N - head { head + len } else { len - (N - head) };
```

## Open design question: element type

`u8` matches the raw sample stream and keeps the proof simple. A generic `T`
adds `Resolve` and `Invariant` obligations for the element. Decide before
writing the implementation, not after.
