# `ci/`

Explicit bootstrap, verification, build and test entry points. Every gate is a
script here, so a developer runs exactly what CI runs.

## Exit codes

| Code | Meaning |
| ---: | --- |
| 0 | The gate passed. |
| 1 | The gate failed: an unproved goal, a failed test, a pin mismatch, an undeclared trusted construct. |
| 78 | The gate is **unconfigured**: a required pin, tool or SDK is not recorded yet. This is never a pass. |

A release requires every applicable gate to exit 0. Code 78 exists so that a
missing verifier is visible as a missing verifier, instead of being hidden
behind a skipped step. No script suppresses a verifier's error status.

## Entry points

| Script | Required behaviour | State today |
| --- | --- | --- |
| `bootstrap-proofs.sh` | Resolve recorded pins, validate checksums, report exact tool identities | Working. Exits 78 because the Verus and runtime sections are unpopulated. `--require-all` makes any gap fatal. |
| `test-host.sh` | Test core and mockable driver behaviour with appropriate compilers | Working: format check, clippy with warnings denied, workspace tests, release build. |
| `prove-core.sh` | Fresh Creusot translation, all in-scope obligations discharged | Working: 1 goal in `phy-trng`, with a goal-set coverage check. `ptrng-core` and `ptrng-spsc` join its `PACKAGES` list when they get their first contract. |
| `smoke-proofs.sh` | Positive and expected-failure cases for both tools | Creusot: working, both paths. Verus: unconfigured. |
| `prove-driver.sh` | Verus proof run with expected function and obligation coverage | Exits 78: no Verus pin, no driver package. |
| `check-trust.sh` | Compare external bodies, assumed specifications and unsafe boundaries with the reviewed inventory | Working. |
| `build-rpi4.sh` | Build the protection domains and image with locked deployment dependencies | Exits 78: no runtime pins, no deployment packages, no system description. |
| `test-hil.sh` | Explicit board selection, capture and fault-injection checks | Exits 78: no runtime pins, no procedures. |

`smoke-proofs.sh` is an addition to the seven entry points named in
`doc/REPOSITORY_AND_PROOF_SETUP.md`, because step 1 of the incremental proof
plan requires both smoke tests as a distinct bootstrap step.

## Wiring

`make all` runs only the gates that can pass today: `fmt-check`, `clippy`,
`test`, `miri`, `check-trust`, `verify` and `build`. The unconfigured gates are
reachable as their own targets (`make prove-driver`, `make build-rpi4`,
`make test-hil`) and are deliberately not in `all`, so that a green `all` never
implies a driver proof or a hardware result.

Independent proof jobs may run in parallel: `prove-core.sh` and
`prove-driver.sh` touch different tools and different output directories.

## Conventions

- **Explicit package selection.** `default-members` is a build-target
  convenience, not a verifier or dependency-resolution firewall. Every script
  names its packages.
- **Explicit toolchains.** A member-level `rust-toolchain.toml` does not switch
  compilers when a member is built from the workspace root, so scripts select
  their toolchain themselves. `RUSTC_WRAPPER` is never set globally, and no
  seL4 target is forced in the root Cargo configuration.
- **Separate output locations.** Ordinary builds use `target/`, Creusot uses
  `target/creusot/`. A Verus output location is chosen when Verus is pinned.
- **Provenance.** Each gate writes source commit, working-tree state, host
  identity, tool identities and the Cargo lock hash into `artifacts/<gate>/`.
  `artifacts/` is generated and is not tracked.
