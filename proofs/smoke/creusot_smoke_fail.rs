// Expected-failure Creusot companion. Identical to `creusot_smoke.rs` except
// for the postcondition, which is now false.
//
// Expected outcome: the proof fails on the postcondition of `increment`. A
// compile error, a missing `creusot-std` patch or an unresolved prover is a
// broken setup, not a passing negative test.

use creusot_std::prelude::*;

#[requires(x@ < u32::MAX@)]
#[ensures(result@ == x@)]
pub fn increment(x: u32) -> u32 {
    x + 1
}
