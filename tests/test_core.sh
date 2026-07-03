#!/usr/bin/env bash
# tests/test_core.sh — Unit tests for lib/core.sh

: "${TERMKIT_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${TERMKIT_ROOT}/lib/core.sh"

# ── TERMKIT_ROOT resolved ─────────────────────────────────────────────────────
assert_true "TERMKIT_ROOT is set"        test -n "$TERMKIT_ROOT"
assert_true "TERMKIT_ROOT exists"        test -d "$TERMKIT_ROOT"
assert_true "TERMKIT_ROOT has lib/"      test -d "${TERMKIT_ROOT}/lib"

# ── Version ───────────────────────────────────────────────────────────────────
assert_true "TERMKIT_VERSION is set"     test -n "${TERMKIT_VERSION:-}"
assert_eq   "Version format"            "2.0.0" "$TERMKIT_VERSION"

# ── Dry-run flag ──────────────────────────────────────────────────────────────
export TERMKIT_DRY_RUN=0
assert_false "is_dry_run off by default" is_dry_run

export TERMKIT_DRY_RUN=1
assert_true  "is_dry_run on when set"   is_dry_run
export TERMKIT_DRY_RUN=0

# ── require_commands ──────────────────────────────────────────────────────────
assert_true  "require_commands: bash present"   require_commands bash
assert_false "require_commands: __no_such_cmd"  require_commands __termkit_no_such_cmd_xyz

# ── check_bash_version ────────────────────────────────────────────────────────
assert_true "check_bash_version passes" check_bash_version

# ── prompt helpers ────────────────────────────────────────────────────────────
assert_true "prompt_yes_no function exists"  declare -f prompt_yes_no
assert_true "prompt_choice function exists"  declare -f prompt_choice
