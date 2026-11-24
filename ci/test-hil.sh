#!/usr/bin/env bash
# Hardware-in-the-loop tests: explicit board selection, capture and
# fault-injection checks.
#
# Usage: ci/test-hil.sh --board <id>
#
# Board selection is explicit and never defaulted: a hardware result is
# attributed to one physical board, or it is not a hardware result.

source "$(dirname "$0")/lib.sh"

BOARD=""
while (( $# > 0 )); do
    case "$1" in
        --board) BOARD="${2-}"; shift 2 || die "--board needs a value" ;;
        *) die "unknown argument: $1" ;;
    esac
done

say "Checking preconditions"

[[ -n "$BOARD" ]] || die "no board selected; pass --board <id>.
    A hardware result without an identified board is not a hardware result."

if [[ "$(pin meta.runtime_status)" != "observed" ]]; then
    unconfigured "runtime pins are unpopulated; there is no image to flash.
    See ci/build-rpi4.sh."
fi

if [[ ! -d "$REPO_ROOT/tests/hil" ]] \
   || [[ -z "$(find "$REPO_ROOT/tests/hil" -name '*.sh' -o -name '*.py' 2>/dev/null)" ]]; then
    unconfigured "no hardware procedures exist under tests/hil.
    The procedures are written alongside the bring-up steps they validate;
    see tests/hil/README.md."
fi

die "reached the hardware step with every precondition satisfied, but no
    procedure has been written. Successful mode programming, actual frame
    cadence and host-memory packing are separate validation obligations and
    each needs its own recorded check."
