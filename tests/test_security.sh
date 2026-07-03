#!/usr/bin/env bash
# tests/test_security.sh — Unit tests for lib/security.sh

: "${TERMKIT_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${TERMKIT_ROOT}/lib/core.sh"
source "${TERMKIT_ROOT}/lib/security.sh"

# ── _validate_sha256_format ───────────────────────────────────────────────────
_valid_hash="a3f1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1"
_bad_hash="not-a-valid-hash"

assert_true  "valid sha256 accepted"   _validate_sha256_format "$_valid_hash"
assert_false "invalid sha256 rejected" _validate_sha256_format "$_bad_hash"
assert_false "empty string rejected"   _validate_sha256_format ""

# ── verify_file ───────────────────────────────────────────────────────────────
_tmpfile="$(mktemp)"
trap 'rm -f "$_tmpfile"' RETURN
echo "termkit test content" > "$_tmpfile"

if command -v sha256sum >/dev/null 2>&1; then
    _actual_hash="$(sha256sum "$_tmpfile" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
    _actual_hash="$(shasum -a 256 "$_tmpfile" | awk '{print $1}')"
else
    skip_test "verify_file" "no sha256 tool available"
    return 0
fi

assert_true  "verify_file: correct hash"  verify_file "$_tmpfile" "$_actual_hash"
assert_false "verify_file: wrong hash"    verify_file "$_tmpfile" "$_valid_hash"
assert_false "verify_file: missing file"  verify_file "/no/such/file" "$_actual_hash"

# ── ftp:// URLs rejected ──────────────────────────────────────────────────────
_ftp_rejected() {
    secure_download "ftp://bad.com/file" "$_valid_hash" 2>/dev/null
}
assert_false "non-http URL rejected" _ftp_rejected

# ── audit_scripts: check it runs (findings are OK, crash is not) ──────────────
_audit_runs() {
    audit_scripts "${TERMKIT_ROOT}" >/dev/null 2>&1
    local rc=$?
    # audit returns number of findings — any value < 127 means it ran, didn't crash
    (( rc < 127 ))
}
assert_true "audit_scripts completes without crashing" _audit_runs
