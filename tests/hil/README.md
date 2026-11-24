# `tests/hil/`

Board tests and fault-injection procedures. These are hardware procedures, not
Cargo tests.

**Nothing here is implemented yet.** `ci/test-hil.sh` exits 78 (unconfigured)
until procedures exist and the runtime pins are populated. It also refuses to
run without `--board <id>`: a hardware result that is not attributed to one
physical board is not a hardware result.

## Cargo interaction

`tests/` at the repository root is also Cargo's integration-test directory for
the `phy-trng` package. A `main.rs` placed in `tests/hil/` would be picked up
as an integration-test target of that package. Hardware procedures are
therefore shell or Python files, and any Rust helper that needs to be a Cargo
target is declared explicitly with a `[[test]]` entry rather than left to
auto-discovery.

## What each procedure must record

- The board identifier, and the image and source commit under test.
- The tool and SDK identities the image was built from.
- The measured result, separately from the expected result.
- For a fault injection: what was injected, what the system did, and which
  `FH-FAIL-*` obligation the observation bears on.

## Procedures to write

| Procedure | Validates |
| --- | --- |
| Trivial-domain boot | The Microkit image boots on the selected board. |
| I2C and sensor readback | Sensor configuration is programmed and read back. |
| Mode programming | The sensor is in the intended RAW10 mode. Separate from cadence. |
| Frame cadence | Actual frames per second, against the 60 fps target. Separate from mode programming. |
| Host-memory packing | The in-memory layout matches the `packing` and `stride` the descriptor declares (`FH-LAY-4`). |
| Buffer-ownership fault injection | Behaviour on receiver error, overrun and truncation (`FH-FAIL-1`, `FH-FAIL-4`). |
| Restart and quiescence | Epoch change does not race outstanding DMA writes (`FH-FAIL-2`, `FH-FAIL-3`). |

Cadence, mode and packing results are recorded against the benchmark
identifiers in `doc/BENCHMARKS.md`; they are not entropy results. A justified
entropy bound needs separate physical and statistical evidence.
