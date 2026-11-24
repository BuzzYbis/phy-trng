# Creusot proof coverage

Status: live inventory. Recorded 2026-11-24 against the pins in
[`tools/toolchains.toml`](../../tools/toolchains.toml).

| Package | Goals | State |
| --- | ---: | --- |
| `phy-trng` | 1 | Proved |
| `ptrng-core` | 0 | Scaffolding, no contracts yet |
| `ptrng-spsc` | 23 | Proved (`23` `.coma` files) |
| `driver-api` | — | Not Creusot-owned; interface review |
| **Total** | **24** | Discharged |

The exact goal set is [`goal-inventory.txt`](goal-inventory.txt), which
`ci/prove-core.sh` diffs against what the translation actually produces. An
unexplained change in either direction fails the gate.

## Command

```sh
ci/prove-core.sh
```

Translation and proving are separate stages. The gate runs
`cargo creusot --only=coma -- -p <package> --lib` for each package in its
`PACKAGES` list, checks coverage, and only then runs
`cargo creusot --only=prove`. **Translation-only success is never counted as
proof completion**, which is why screening runs after the prove stage.
Generated output goes to `verif/`, the tool's normal path.

## `phy-trng`

| Function | Obligations | Result |
| --- | --- | --- |
| `zero_slice` | Precondition, length preservation, all elements zero, loop invariants, termination, panic freedom | Proved |

## `ptrng-spsc`

| Item / Function | Obligations | Result |
| --- | --- | --- |
| `SpscError` (`Clone`, `Debug`, `Display`, `PartialEq`, `Eq`, `Error`) | Derived traits (`6` `.coma` files incl. `Display::fmt` via `write_str`) | Proved |
| `RingBuffer` (`Debug`, `physical_index`) | Branch-wrapped slot index (`0 <= result < N`), termination, panic freedom | Proved |
| `new`, `new_with` | `N > 0` precondition, empty `Seq` view, termination (`new_with`), panic freedom | Proved |
| `capacity`, `len`, `free`, `is_empty`, `is_full`, `peek` | Exact capacity/length/empty/full/front-element view specs, termination, panic freedom | Proved |
| `push_into_available`, `try_push` | No unread overwrite on `SpscError::Full`, FIFO `push_back`, termination, panic freedom | Proved |
| `pop_non_empty`, `pop` | Front element read, `subsequence(1, len)` FIFO shift, slot scrub with `fill`, termination, panic freedom | Proved |
| `push_slice`, `pop_slice` | Returned-count bounds, FIFO `concat`/`subsequence`, untouched `dst[count..]` tail, loop invariants/variants, termination, panic freedom | Proved |
| `clear` | Empty `Seq` view, full backing-array overwrite with `fill`, loop invariant/variant, termination, panic freedom | Proved |

## Packages with no coverage yet

`ptrng-core` exists as scaffolding: a manifest, scope rules and a crate-level
doc comment. It carries no contracts, is absent from `PACKAGES` in
`ci/prove-core.sh`, and has no `creusot-std` dependency.

When the first contract is written in `ptrng-core`, three things change in the
same commit:

1. `creusot-std` goes back into `crates/ptrng-core/Cargo.toml`.
2. `ptrng-core` is added to `PACKAGES` in `ci/prove-core.sh` (and `CORE_PKGS` in `makefile`).
3. `ci/prove-core.sh --update-inventory` regenerates the goal set, and this
   file gains the matching per-function entries.

The obligation list `ptrng-core` must eventually satisfy is in
[`doc/M4-architecture.md`](../../doc/M4-architecture.md) ("Core contracts").

## Design finding: modulo blocks the non-aliasing proof

Recorded from the M0 P4 probe. This is a **tool finding**, established
independently of any particular implementation, and it survives the removal
of the code that first demonstrated it.

For a bounded ring, computing the tail slot as `(head + len) % N` leaves the
central obligation — that writing the tail disturbs no stored element —
**unproved**, at 7 of 8 goals, with no useful counterexample. Computing the
same slot with a branch:

```rust
let tail = if len < N - head { head + len } else { len - (N - head) };
```

discharges every goal automatically, with no proof hints. The two are equal
whenever the ring invariant holds, but the solvers reason about the branch
form and not about `%`. The branch form also avoids a division in the emitted
code.

**Rule for this repository: bounded ring and index arithmetic uses branch
wrapping, not `%`.**

## Other tool findings from the same probe

Constraints on API shape, established against the pinned Creusot:

| Finding | Consequence for an API |
| --- | --- |
| `#[logic(open)]` may not reference a private field | A view or invariant over private state must be `#[logic(open(self))]`, so callers reason through method contracts rather than by unfolding |
| A public associated constant may not expose a private constructor | `ZERO`-style constants become contracted functions, for example `fn zero() -> Self` |
| Creusot's `derive(PartialEq)` requires `DeepModel` | Either derive `DeepModel` too, or write it by hand at `open(self)` visibility when the field is private |
| Ambiguous derives | `use creusot_std::prelude::{Clone, PartialEq, *};` names the conflicting derives explicitly |
| `core::fmt` is not provable | A hand-written `Display` impl cannot be discharged and would need a `proofs/tcb.md` entry; derived `Debug` discharges fine |
| Const generics, arrays and `Seq` models | Supported; `View`, `Invariant` and `Seq::create` behave as in the upstream `sparse_array` example |

## Gate rules

- No `admitted`, skipped, unresolved or timeout result counts as proof.
- Coverage changes fail the gate. `ci/prove-core.sh` diffs the generated goal
  set against `goal-inventory.txt`; `--update-inventory` is a review action
  requiring this file to be updated in the same commit.
- Proof search must cover freshly generated output. The gate removes
  `target/creusot` before translating, and keeps the replay files.

## Replay files

`verif/**/*.coma` and their `proof.json` files are tracked, as is the
`.why3find/` prover cache. `ci/prove-core.sh` and `makefile` pass
`--span-mode relative`, eliminating developer-absolute `/Users/...` spans from
the tracked Coma. See `REPRO-1` in `tools/toolchains.toml`: `REPRO-1` is
partially mitigated, though `creusot-std` spans still encode the relative
sibling checkout path (`../../creusot/creusot-std/...`, tied to `REPRO-2`),
which bears on **B-EVD-03**.

## Trusted boundary

Zero trust markers in any package: no `unsafe`, no `#[trusted]`, no
`assume!`. Every crate sets `#![forbid(unsafe_code)]`.
`ci/check-trust.sh` enforces this against `proofs/tcb-inventory.tsv`.

## Contract mirroring

No `FH-*` obligation is discharged on the Creusot side. The consumer-side
processing that would assume them does not exist. When it does, each function
naming a handoff precondition records the identifier it relies on, so a review
can check that the Verus side establishes it. There is no automatic proof
transfer between the tools.
