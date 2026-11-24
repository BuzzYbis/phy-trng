// Positive Verus case. Expected outcome: the function is *verified*, not
// merely parsed. The harness must read the verification summary and require a
// non-zero verified count.
//
// Run with the pinned executable on PATH:
//
//     verus --version
//     verus proofs/smoke/verus_smoke.rs

use vstd::prelude::*;

verus! {
    pub fn increment(x: u32) -> (result: u32)
        requires x < u32::MAX,
        ensures result == x + 1,
    {
        x + 1
    }
}

fn main() {}
