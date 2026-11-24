// Positive Creusot case, as the library source of a scratch package.
//
// Per section 6.1 of `doc/REPOSITORY_AND_PROOF_SETUP.md`, the Creusot smoke
// project is created *outside* the workspace so that `cargo creusot init` is
// never run over the existing library. `ci/smoke-proofs.sh`
// creates the scratch package with `cargo creusot new`, copies this file over
// its `src/lib.rs` and runs `cargo creusot` there.
//
// Expected outcome: proved.

use creusot_std::prelude::*;

#[requires(x@ < u32::MAX@)]
#[ensures(result@ == x@ + 1)]
pub fn increment(x: u32) -> u32 {
    x + 1
}
