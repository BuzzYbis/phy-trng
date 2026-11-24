// Expected-failure Verus companion. Identical to `verus_smoke.rs` except for
// the postcondition, which is now false.
//
// Expected outcome: verification fails, specifically on the `ensures` clause
// of `increment`. The harness must require rejection *of that obligation*. An
// unrelated compiler error, a parse error or a missing-vstd error is a broken
// setup, not a passing negative test.

use vstd::prelude::*;

verus! {
    pub fn increment(x: u32) -> (result: u32)
        requires x < u32::MAX,
        ensures result == x,
    {
        x + 1
    }
}

fn main() {}
