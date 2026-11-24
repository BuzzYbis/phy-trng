//! Errors, tagged entropy amounts and identity counters for the PTRNG
//! pipeline.
//!
//! Scaffolding only: no implementation yet. Scope rules are in `README.md`;
//! the obligations this crate must meet are in `doc/M4-architecture.md`
//! under "Core contracts" and `doc/ARCHITECTURE.md` section 9.
//!
//! Creusot will own this crate. Add the `creusot-std` dependency back to
//! `Cargo.toml` with the first contract, and add the package to `PACKAGES`
//! in `ci/prove-core.sh` at the same time.

#![no_std]
#![forbid(unsafe_code)]
