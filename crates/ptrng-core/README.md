# `ptrng-core`

Errors, tagged entropy amounts and identity counters for the PTRNG pipeline.

Proof owner: **Creusot**. **Not implemented yet** — this crate is currently
scaffolding: a manifest, these scope rules and a crate-level doc comment.
Every public operation will carry contracts discharged by
`ci/prove-core.sh` and inventoried in
[`proofs/creusot/coverage.md`](../../proofs/creusot/coverage.md), which
records zero goals for this package today.

Scope rules, binding on the implementation when it is written, from [`ARCHITECTURE.md`](../../doc/ARCHITECTURE.md) §9 and
[`M4-architecture.md`](../../doc/M4-architecture.md):

- **Distinct types per account.** Raw credited, intermediate and retained
  state entropy are separate types, so a balance cannot be moved between
  accounts by assignment. A transfer is an explicit, argued operation.
- **Fail closed.** Every arithmetic operation is checked and returns `Option`
  or an `Error`. There is deliberately **no saturating add on an amount**: a
  saturating accumulator can conceal overlap, replay or a lost debit.
- **No wrapping identity.** `BootSession`, `Epoch` and `Sequence` fail on
  exhaustion rather than wrapping.
- **Credits round down, debits round up.**
- No numeric entropy value appears here. `h_credit`, `v_m`, `v_out`, `N_raw`
  and `n_int` are research outputs frozen at G2/G3, not defaults.
