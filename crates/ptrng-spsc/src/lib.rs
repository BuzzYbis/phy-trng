//! Bounded sequential ring buffer.
//!
//! # Scope and what this crate does not claim
//!
//! This is a **sequential cooperative** model: one caller at a time, with no
//! concurrency. `doc/ARCHITECTURE.md` section 10 scopes `ptrng-spsc` as the
//! sequential ring with a sequential FIFO/ownership proof (`B-VER-07`), and
//! `doc/M4-architecture.md` states that cross-PD ordering and hostile mutation
//! are M6 obligations (`ptrng-xfer` / `ptrng-sync`).
//!
//! Every public function carries Creusot contracts discharged by
//! `ci/prove-core.sh` and inventoried in `proofs/creusot/coverage.md`.

#![no_std]
#![forbid(unsafe_code)]
#![cfg_attr(
    creusot,
    expect(
        trivial_numeric_casts,
        reason = "creusot-std-proc expands Pearlite integer literals as `lit as i128`"
    )
)]

// - modules section                                                        - //

mod error;
mod spsc;

// - re-exports section                                                     - //

pub use error::SpscError;
pub use spsc::RingBuffer;
