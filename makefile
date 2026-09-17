.DEFAULT_GOAL := all

# Flags
CLIPPY_FLAGS := --workspace --all-targets --all-features -- -D warnings
CARGO_FLAGS  := --workspace --all-features

# The Creusot proof gate selects its package explicitly: `default-members` is
# a build-target convenience, not a verifier firewall.
CORE_PKG := phy-trng

.PHONY: all fmt fmt-check clippy test cov cov-html build verify miri audit clean \
        bootstrap smoke check-trust prove-core prove-driver build-rpi4 test-hil \
        gates

# Run the complete test and validation pipeline.
#
# Only gates that can pass today are included. The unconfigured gates
# (prove-driver, build-rpi4, test-hil) are separate targets on purpose, so a
# green `all` never implies a driver proof or a hardware result.
all: fmt-check clippy test miri check-trust verify build


# ------------------------------------------------------------------------------
# Formatting & Static Analysis
# ------------------------------------------------------------------------------

fmt-check:
	@echo "==> Checking code formatting..."
	cargo +nightly fmt --all -- --check

fmt:
	@echo "==> Formatting code..."
	cargo +nightly fmt --all

clippy:
	@echo "==> Running Clippy (Warnings as Errors)..."
	cargo clippy $(CLIPPY_FLAGS)


# ------------------------------------------------------------------------------
# Testing & Code Coverage
# ------------------------------------------------------------------------------

test:
	@echo "==> Running host unit tests..."
	cargo test $(CARGO_FLAGS)

cov:
	@echo "==> Generating terminal coverage summary..."
	cargo llvm-cov $(CARGO_FLAGS)

cov-html:
	@echo "==> Generating HTML coverage report..."
	cargo llvm-cov $(CARGO_FLAGS) --html
	@echo "Coverage report written to: target/llvm-cov/html/index.html"

miri:
	@echo "==> Running tests under Miri (Undefined Behavior Detection)..."
	cargo +nightly miri test $(CARGO_FLAGS)


# ------------------------------------------------------------------------------
# Formal Verification & Build
# ------------------------------------------------------------------------------

verify: clippy
	@echo "==> Running Creusot formal verification..."
	cargo creusot -- -p $(CORE_PKG) --lib

build: clippy
	@echo "==> Compiling release artifacts..."
	cargo build --release $(CARGO_FLAGS)


# ------------------------------------------------------------------------------
# CI Gates
# ------------------------------------------------------------------------------
#
# These delegate to ci/, so a developer runs exactly what CI runs. Exit code 78
# means the gate is unconfigured, which is never a pass; see ci/README.md.

# Run every gate and summarise. Exit code 78 (unconfigured) is reported and
# does not abort the run; any other non-zero code fails the target. A release
# requires every applicable gate to exit 0, so `gates` failing on 78 is not
# the signal to relax -- populating the pins is.
gates:
	@fail=0; \
	for gate in bootstrap-proofs test-host smoke-proofs prove-core \
	            check-trust prove-driver build-rpi4; do \
		./ci/$$gate.sh > /dev/null 2>&1; \
		code=$$?; \
		case $$code in \
			0)  printf '  pass         %s\n' "$$gate" ;; \
			78) printf '  unconfigured %s\n' "$$gate" ;; \
			*)  printf '  FAIL (%s)    %s\n' "$$code" "$$gate"; fail=1 ;; \
		esac; \
	done; \
	printf '  skipped      test-hil (needs BOARD=<id>)\n'; \
	exit $$fail

bootstrap:
	./ci/bootstrap-proofs.sh

smoke:
	./ci/smoke-proofs.sh

check-trust:
	./ci/check-trust.sh

prove-core:
	./ci/prove-core.sh

prove-driver:
	./ci/prove-driver.sh

build-rpi4:
	./ci/build-rpi4.sh

test-hil:
	./ci/test-hil.sh $(if $(BOARD),--board $(BOARD),)


# ------------------------------------------------------------------------------
# Maintenance & Cleanup
# ------------------------------------------------------------------------------

audit:
	@echo "==> Auditing dependency vulnerabilities..."
	cargo audit

clean:
	@echo "==> Cleaning build artifacts..."
	cargo clean
	cargo creusot clean
	rm -rf artifacts
