# M6 — Deployment isolation and timing

**Version 0.3 — second-review revision. Design specification; no implementation, proof, measurement or certification result is asserted.**

**Effort:** 120 h provisional · **Productive weeks:** 71–82 · **Gate:** [G6](GATES.md#g6)

## Objective and entry

Deploy the qualified functional and local release model without replacing its contracts with informal capability claims. G5 supplies real health, separate ICA/ORA, ledgers and finite closure/exposure bounds. M0 supplies the target DMA and time-service profile.

## Work packages — 120 h provisional

| Package | Hours | Output |
|---|---:|---|
| Release and client commit integration | 28 | Authoritative commit owner and private staging snapshot |
| Capability/configuration audit | 20 | Actual mappings and control authority |
| DMA mechanism/trust qualification | 18 | Forbidden-write evidence or explicit trust profile |
| Cross-domain transport | 24 | Safety/ordering/immutability assumptions and proofs |
| Time/revocation protocol | 16 | Cross-PD closure/exposure bounds |
| Boot/fault/shutdown | 14 | Startup isolation and bounded failure behavior |

## PD configuration

Use the seven application PDs in ARCHITECTURE plus actual timer/platform support where necessary. For every capability record the holder, mapping rights, recipient, purpose and compromise consequence. `pd_release` directly reads authentic health ORA/epoch state and trusted monotone time; it does not trust a generator-relayed authorization record as issuer provenance.

Only release may publish the client commit descriptor/write output. Generator can write staging but not release's private commit buffer. Health exclusively writes protected snapshots before immutable handoff. The actual protocol has protected receiver ledgers and finite slot lifetimes, not shared indices treated as ownership proof.

The release application logic target is ≤300 SLOC, but required checking is not removed to hit a line count. Report first-party code and full timer/fault/boot/scheduling/library/kernel/platform dependencies separately.

## DMA and authority

For enforced profiles, confine every camera DMA path/stream ID to approved regions, protect mapping tables and retain policy-update authority outside the driver. Test allowed and deliberately forbidden descriptors, attempts to broaden mappings and fault routing; verify forbidden memory unchanged.

For trusted profiles, A-DMA-1 is explicit in technical assumptions/ST/guidance as appropriate, and no enforcement result is claimed. A compromised DMA-trusted driver can invalidate isolation; successful CPU mapping tests do not remove that limit.

## Hostile transport

Bounds proofs take arbitrary partner-controlled indices and lengths. Snapshot shared metadata into local variables with specified atomic/ordering semantics before validation and use. Prove no out-of-bounds access or arithmetic overflow even when the partner lies. Fuzz mutation, reorder, inconsistent lengths, slot recycling and wrap.

Separately qualify the bytes-to-ICA-to-consumption binding. Memory safety is not freshness, uniqueness or physical provenance. Cache/DMA coherency, read/write ownership, message identity and permit ledgers are part of the composition argument.

## Clock, revocation and client commit

The authoritative epoch/ORA channel and reliable clock are independent of the generator. Timer or health failure stops lease renewal; clock faults must have a specified fail-closed response, not an indefinitely frozen valid timestamp. Scheduler priorities/budgets prevent a hostile sender from starving release/fault handling.

Bound alarm delivery, handler scheduling and the final non-preemptible commit section. Test alarm/expiry at every commit phase. Old-epoch permits fail after closure; possible pre-close commits are counted against a finite exposure budget. Whole-system reset clears transport and data and establishes a new boot session before acceptance; address counter exhaustion and replay surviving reset explicitly.

Copy source to private commit buffer before checking a stable range and publishing it. Clients cannot read an uncommitted request by contract. On partial request error they discard the complete destination. Release scrubs its own writable buffer; trusted restart management scrubs shared staging after crashes. Read-only release staging access is never claimed to support stores.

## Hostile-generator test scope

Staging writes must succeed in the adversarial test, proving realistic attacker capabilities. Direct client writes, issuer spoofing, duplicate/overlap, expiry and old-epoch commits must fail. Test valid permits as well: a malicious generator can place arbitrary bytes under a valid permit. That is the declared limit of confinement; cryptographic correctness remains a trusted-code claim.

## Boot and faults

Bring up fault/time services before acquisition; configure hardware and KATs; run real startup checks; seed the PTG.3/DRG.4 chain; establish release state; only then admit generating requests. Include generator/API/health/release/timer faults and watchdog handling. Use actual ISA fault behaviors; unaligned access is not universally faulting.

Re-run applicable functional/protocol evidence against the real deployed profile. Compare transport performance against a single-address-space build with identical real health/release policy, not the M4 stub. G6 exits only with complete capability/TCB inventory and qualified cross-domain timing, snapshot and authorization guarantees.

## Acceptance and dependencies

Per-PD capability table, supporting TCB, immutable snapshot transport, authoritative time/epoch paths, DMA qualification/trust declaration and measured/proved closure/exposure bounds.

Canonical acceptance criteria are in [BENCHMARKS.md](BENCHMARKS.md); gate aggregation is in [GATES.md](GATES.md). The paired [milestone benchmarks](M6-benchmarks.md) list newly active items and methods. Prior gate results remain required only when applicable and dependency-valid. See [architecture](ARCHITECTURE.md) for authority, units and trust definitions.
