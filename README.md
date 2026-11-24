# Physical TRNG

This project builds a physical True Random Number Generator (TRNG) library,
targeting BSI AIS 31 class PTG.3 with a separate DRG.4 output stage, deployed
on seL4. Its deterministic components carry formal proofs; the entropy claim
itself rests on a reviewed physical model and measurements, which no software
proof can replace.

The v1 entropy source is camera-sensor noise (photon shot noise and read
noise) under controlled illumination. A lava lamp provides a changing scene,
but it is credited **zero** entropy. The engine is a `no_std` core with a
statically dispatched source interface, so other physical sources (for
example radioactive decay or ring-oscillator jitter) can be added later; v1
qualifies one source only.

## Stack

- **Rust**, `no_std` and allocation-free at runtime.
- [Creusot](https://creusot.rs) proves the entropy-processing library;
  [Verus](https://github.com/verus-lang/verus) is planned for the camera
  driver.
- **seL4 Microkit** deployment on the reference target: Raspberry Pi 4 with a
  colour Sony IMX296 sensor.
- **Cryptography:** the construction (a Keccak sponge, Hash_DRBG/SHA-256, or
  another reviewed candidate) is chosen at gate G3.
  [Formosa Keccak](https://formosa-crypto.org/projects/formosakeccak) is used
  where its verified artifacts support the target. Any backend, including a
  third-party one, is selected per build profile and must pass the
  independent-oracle and known-answer benchmarks (B-VER-08, B-INT-07).

Terms and abbreviations are defined in [doc/GLOSSARY.md](doc/GLOSSARY.md).

## Repository organisation

```
Cargo.toml            workspace root; the entropy library is the root package
src/                  entropy library (Creusot)
crates/driver-api/    frame-handoff vocabulary            (scaffolding)
crates/ptrng-core/    errors, amounts, identity counters  (scaffolding)
crates/ptrng-spsc/    bounded sequential ring             (scaffolding)
verif/  .why3find/    Creusot output and prover cache, tracked as evidence
why3find.json         prover configuration
proofs/               contracts, coverage inventories, TCB, smoke cases
tools/toolchains.toml exact verifier, compiler, solver and SDK pins
ci/                   one script per gate; `make gates` summarises them
system/rpi4/          Microkit system description (requirements only so far)
tests/hil/            hardware procedures (requirements only so far)
doc/                  architecture, roadmap, gates, benchmarks, milestones
artifacts/            generated logs and provenance; not tracked
```

Verification is split by domain: Creusot owns the entropy-processing library,
Verus is intended for the camera-driver protocol, and the trusted boundary
between them is inventoried rather than assumed.

Crates marked *scaffolding* carry a manifest, scope rules and a crate doc
comment, and no implementation. Each crate's `README.md` states the
obligations its implementation must meet.

| To do this | Run |
| --- | --- |
| Everything that can pass today | `make all` |
| See the state of every CI check | `make gates` |
| Prove the library | `make prove-core` |
| Check the trusted boundary | `make check-trust` |

`make gates` runs the CI checks, which `ci/` calls *gates*. They are not the
milestone gates G0–G7 in [doc/GATES.md](doc/GATES.md); they produce some of
the evidence those milestone gates consume. `make gates` prints
`unconfigured` for a check whose tools are not pinned yet. That is never a
pass: it means the check cannot run, and a release requires all of them to
pass. Start with
[doc/REPOSITORY_STATUS.md](doc/REPOSITORY_STATUS.md) for what is applied and
what is deferred, and
[doc/REPOSITORY_AND_PROOF_SETUP.md](doc/REPOSITORY_AND_PROOF_SETUP.md) for the
policy it implements.

## Documentation

- [Architecture](doc/ARCHITECTURE.md), [roadmap](doc/ROADMAP.md),
  [gates](doc/GATES.md), [benchmarks](doc/BENCHMARKS.md) and the
  [glossary](doc/GLOSSARY.md).
- [Repository and proof setup](doc/REPOSITORY_AND_PROOF_SETUP.md) and its
  [applied state](doc/REPOSITORY_STATUS.md).
- [Frame handoff contract](proofs/contracts/frame-handoff.md) and the
  [trusted computing base](proofs/tcb.md).
- The offline [pipeline explorer](doc/pipeline-explorer.html).

No implementation, proof, measurement or certification result beyond what
[proofs/](proofs/) records is asserted. The accepted phrasing for what the
proofs establish is: *"The listed components satisfy their specified software
contracts under the enumerated platform, hardware and toolchain
assumptions."*

## References 

- [NIST SP 800-90A Rev. 1](https://doi.org/10.6028/NIST.SP.800-90Ar1): Recommendation for Random Number Generation Using Deterministic Random Bit Generators.
- [NIST SP 800-90B](https://doi.org/10.6028/NIST.SP.800-90B): Recommendation for the Entropy Sources Used for Random Bit Generation. 
- [NIST SP 800-90C](https://doi.org/10.6028/NIST.SP.800-90C): Recommendation for Random Bit Generator (RBG) Constructions.
- [NIST SP 800-22 Rev. 1a](https://doi.org/10.6028/NIST.SP.800-22r1a): A Statistical Test Suite for Random and Pseudorandom Number Generators for Cryptographic Applications.
- [BSI AIS 31](https://www.bsi.bund.de/EN/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/Zertifizierung-und-Anerkennung/Zertifizierung-von-Produkten/Zertifizierung-nach-CC/Anwendungshinweise-und-Interpretationen/anwendungshinweise-und-interpretationen_node.html): Multiple documents. 

_All the references are available free of charge following the links; I also regrouped them at https://kdrive.infomaniak.com/app/share/1926560/59e64735-4282-4d51-b705-4bf41fb9aaa6_.


