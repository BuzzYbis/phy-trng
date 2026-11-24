//! Formally verified TRNG conditioning and extraction pipeline.
//!
//! Creusot owns this package. Every public function carries contracts that
//! are discharged by `ci/prove-core.sh` and inventoried in
//! `proofs/creusot/coverage.md`. Those contracts expand to nothing in an
//! ordinary build, so the compiled program is the program that was checked;
//! `ci/test-host.sh` asserts that erasure rather than assuming it.

#![no_std]
#![cfg_attr(
    creusot,
    expect(
        trivial_numeric_casts,
        reason = "creusot-std-proc expands Pearlite integer literals as `lit as i128`"
    )
)]

use creusot_std::prelude::*;

// - functions section                                                      - //

/// Overwrites every byte of `v` with zero.
///
/// The attributes below are the normative specification: `v` must be
/// non-empty, its length is preserved, and every element is zero on return.
/// They are discharged by Creusot, not by this comment.
#[requires(v@.len() > 0)]
#[ensures((^v)@.len() == v@.len())]
#[ensures(forall<i: Int> 0 <= i && i < v@.len() ==> (^v)@[i]@ == 0)]
pub fn zero_slice(v: &mut [u8]) {
    let len = v.len();
    let mut i = 0;

    #[invariant(0 <= i@ && i@ <= len@)]
    #[invariant(v@.len() == len@)]
    #[invariant(forall<j: Int> 0 <= j && j < i@ ==> v@[j]@ == 0)]
    while i < len {
        v[i] = 0;
        i += 1;
    }
}

// -------------------------------------------------------------------------- //
// - tests                                                                  - //
// -------------------------------------------------------------------------- //

#[cfg(test)]
mod tests {
    use super::*;

    // - functions section                                                  - //

    #[test]
    fn test_zero_slice() {
        let mut buf = [0xFF; 4];
        zero_slice(&mut buf);
        assert_eq!(buf, [0, 0, 0, 0]);
    }
}
