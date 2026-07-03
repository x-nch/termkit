#!/usr/bin/env bash
# tests/test_fs.sh — Unit tests for lib/fs.sh (runs in dry-run mode)

: "${TERMKIT_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${TERMKIT_ROOT}/lib/core.sh"
source "${TERMKIT_ROOT}/lib/fs.sh"

export TERMKIT_DRY_RUN=1

_tmpdir="$(mktemp -d)"
trap 'rm -rf "$_tmpdir"' RETURN

# ── safe_mkdir ────────────────────────────────────────────────────────────────
assert_true "safe_mkdir function exists"          declare -f safe_mkdir
assert_true "safe_mkdir exits cleanly in dry-run" safe_mkdir "${_tmpdir}/testdir"

# ── safe_copy ─────────────────────────────────────────────────────────────────
_src="$(mktemp)"
echo "hello" > "$_src"

assert_true  "safe_copy exits 0 in dry-run"        safe_copy "$_src" "${_tmpdir}/copy_dst"
assert_false "safe_copy fails for missing source"   safe_copy "/no/such/file" "${_tmpdir}/copy_dst2"

# ── safe_link ─────────────────────────────────────────────────────────────────
assert_true  "safe_link exits 0 in dry-run"        safe_link "$_src" "${_tmpdir}/link_dst"
assert_false "safe_link fails for missing source"  safe_link "/no/such/file" "${_tmpdir}/link_dst2"

# ── print_backup_path ─────────────────────────────────────────────────────────
_bpath_ok() { test -n "$(print_backup_path 2>/dev/null)"; }
assert_true "print_backup_path returns non-empty path" _bpath_ok

rm -f "$_src"
export TERMKIT_DRY_RUN=0
