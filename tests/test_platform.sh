#!/usr/bin/env bash
# tests/test_platform.sh — Unit tests for lib/platform.sh

: "${TERMKIT_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${TERMKIT_ROOT}/lib/core.sh"
source "${TERMKIT_ROOT}/lib/platform.sh"

# ── detect_os ─────────────────────────────────────────────────────────────────
_os="$(detect_os)"
assert_true "detect_os returns non-empty"    test -n "$_os"

_os_valid() {
    case "$(detect_os)" in
        linux|macos|windows|unknown) return 0 ;;
        *) return 1 ;;
    esac
}
assert_true "detect_os returns known value" _os_valid

# ── detect_distro ─────────────────────────────────────────────────────────────
assert_true "detect_distro returns non-empty" test -n "$(detect_distro)"

# ── detect_arch ───────────────────────────────────────────────────────────────
assert_true "detect_arch returns non-empty"   test -n "$(detect_arch)"

# ── detect_shell ──────────────────────────────────────────────────────────────
assert_true "detect_shell returns non-empty"  test -n "$(detect_shell)"

# ── detect_package_manager ────────────────────────────────────────────────────
assert_true "detect_package_manager returns non-empty" test -n "$(detect_package_manager)"

# ── is_wsl function exists ────────────────────────────────────────────────────
assert_true "is_wsl function exists" declare -f is_wsl

# ── print_platform_info runs without error ────────────────────────────────────
_platform_info_ok() { print_platform_info >/dev/null 2>&1; }
assert_true "print_platform_info runs cleanly" _platform_info_ok
