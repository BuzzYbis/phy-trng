# `ptrng-spsc`

Bounded sequential ring buffer with a proved FIFO and ownership model.

Proof owner: **Creusot**. **Implemented and proved** (`23` `.coma` goal files
discharged in [`proofs/creusot/coverage.md`](../../proofs/creusot/coverage.md)),
covering `SpscError` (`Display` + `Error`) and generic
`RingBuffer<T: Copy, const N: usize>` (`new` with `T: Copy + Default`, `new_with`,
`capacity`, `len`, `free`, `is_empty`, `is_full`, `peek`, `try_push`, `pop`,
`push_slice`, `pop_slice`, `clear`).

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

## Obligations discharged (`B-VER-07`)

From `doc/M4-architecture.md`, "Sequential buffers and extraction".
All `B-VER-07` obligations below are proved in `src/spsc.rs` and `src/error.rs`
(re-exported from `src/lib.rs`):

| Obligation | Mechanism |
| --- | --- |
| Capacity and length bounds | `Invariant`: `N@ > 0 && self.head@ < N@ && self.len@ <= N@` |
| Push and pop count bounds | `try_push` / `pop` / `push_slice` / `pop_slice` postconditions on `self@.len()` and returned counts |
| FIFO order | `pop` returns `(*self)@[0]` with `subsequence(1, len)`; `push_slice`/`pop_slice` specify `concat`/`subsequence` |
| Initialized reads | `View` models `Seq::create(self.len@, ...)`; `peek`/`pop`/`pop_slice` read only within `len` |
| No unread overwrite | `try_push` on a full ring returns `Err(SpscError::Full)` and leaves `self@` unchanged; `pop_slice` preserves `dst[count..]` |
| Empty and full distinguishable | `len` is stored (`0..=N`), so `head == tail` is never ambiguous |
| Peek lifetime | `peek` returns `Option<T>` by value (`T: Copy`), so no borrow outlives the call |
| Panic freedom, termination | `#[check(terminates)]` + `#[variant(...)]` loops; every index proved in bounds |

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

## Element type choice (decided)

Implemented as generic `RingBuffer<T: Copy, const N: usize>` (`new()` requires
`T: Copy + Default`; `new_with(fill: T)` stores `fill` so `pop`/`pop_slice`/`clear`
scrub consumed slots without invoking `T::default()` inside proved-terminating
methods).
