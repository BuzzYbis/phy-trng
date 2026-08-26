.DEFAULT_GOAL := all

# Flags
CLIPPY_FLAGS := --all-targets --all-features -- -D warnings
CARGO_FLAGS  := --all-features

.PHONY: all fmt fmt-check clippy test cov cov-html build verify miri audit clean

# Run the complete test and validation pipeline
all: fmt-check clippy test miri verify build


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
	cargo creusot

build: clippy
	@echo "==> Compiling release artifacts..."
	cargo build --release $(CARGO_FLAGS)


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
