# `proofs/`

Assurance material that is not itself source code. Generated verifier output
does **not** live here: Creusot writes to its normal output path, `verif/`, and
that path is preserved.

| Path | Contents | Owner |
| --- | --- | --- |
| [`contracts/`](contracts/) | Normative cross-component contracts and the `FH-*` requirement identifiers | Both proof domains |
| [`creusot/coverage.md`](creusot/coverage.md) | What Creusot actually proves, function by function | Creusot |
| [`creusot/goal-inventory.txt`](creusot/goal-inventory.txt) | Machine-readable goal set checked by `ci/prove-core.sh` | Creusot |
| [`verus/coverage.md`](verus/coverage.md) | What Verus actually proves, function by function | Verus |
| [`tcb.md`](tcb.md) | Every trusted primitive and assumption, with an owner and a justification | Assurance review |
| [`tcb-inventory.tsv`](tcb-inventory.tsv) | Machine-readable trust-marker inventory checked by `ci/check-trust.sh` | Assurance review |
| [`smoke/`](smoke/) | Small positive and expected-failure verification cases for both tools | Both tools |
| [`compatibility-experiment.md`](compatibility-experiment.md) | Result of the mandatory pre-driver compatibility experiment | Build owner |

## Reading rules

A claim in these files is either a **proof result**, a **test result**, a
**trusted assumption** or **not yet implemented**. Those four are never
conflated:

- Translation-only success is never counted as proof completion.
- An `external_body`, `#[trusted]` or assumed specification is a trusted
  assumption. It does not become a discharged proof by annotation.
- An obligation with no code behind it is recorded as not yet implemented, not
  as untested.
- A lint suppression is not any of the four. `allow_attributes_without_reason`
  requires every `#[expect]` and `#[allow]` to carry a `reason`, and that
  reason must say what makes the code correct: an argument from the types, a
  checked-arithmetic guarantee, or a named proof obligation from
  [`contracts/`](contracts/). "Clippy is wrong here" is not a reason. Prefer
  `#[expect]`, which fails once the suppression stops being needed.

The acceptance language for anything built from this material is: *"The listed
components satisfy their specified software contracts under the enumerated
platform, hardware and toolchain assumptions."* It is never shortened to "the
entire TRNG is formally verified."
