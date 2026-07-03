#!/usr/bin/env bash
# tests/run_tests.sh — TermKit test runner
#
# Usage:
#   ./tests/run_tests.sh              # Run all tests
#   ./tests/run_tests.sh test_core    # Run a specific suite

set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERMKIT_ROOT="$(cd "${TESTS_DIR}/.." && pwd)"

source "${TERMKIT_ROOT}/lib/core.sh"

# ── Minimal test harness ──────────────────────────────────────────────────────
_PASS=0
_FAIL=0
_SKIP=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$actual" == "$expected" ]]; then
        log_success "PASS: $desc"
        (( _PASS++ )) || true
    else
        log_error  "FAIL: $desc"
        echo       "       expected: '$expected'"
        echo       "       actual:   '$actual'"
        (( _FAIL++ )) || true
    fi
}

assert_true() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        log_success "PASS: $desc"
        (( _PASS++ )) || true
    else
        log_error  "FAIL: $desc (command: $*)"
        (( _FAIL++ )) || true
    fi
}

assert_false() {
    local desc="$1"; shift
    if ! "$@" 2>/dev/null; then
        log_success "PASS: $desc"
        (( _PASS++ )) || true
    else
        log_error  "FAIL: $desc (expected failure but got success: $*)"
        (( _FAIL++ )) || true
    fi
}

skip_test() {
    local desc="$1" reason="${2:-}"
    echo -e "${YELLOW}SKIP: ${desc}${reason:+ ($reason)}${NC}"
    (( _SKIP++ )) || true
}

# Export harness for sourced test files
export -f assert_eq assert_true assert_false skip_test log_success log_error log_warning log_section

# ── Suite discovery ───────────────────────────────────────────────────────────
run_suite() {
    local suite_file="$1"
    local suite_name; suite_name="$(basename "$suite_file" .sh)"

    log_section "Suite: $suite_name"
    # shellcheck source=/dev/null
    source "$suite_file"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    local suites=()

    if (( $# > 0 )); then
        for arg in "$@"; do
            local f="${TESTS_DIR}/${arg}.sh"
            [[ -f "$f" ]] || f="${TESTS_DIR}/${arg}"
            if [[ -f "$f" ]]; then
                suites+=("$f")
            else
                log_error "Test suite not found: $arg"
                exit 1
            fi
        done
    else
        while IFS= read -r -d '' f; do
            [[ "$(basename "$f")" == "run_tests.sh" ]] && continue
            suites+=("$f")
        done < <(find "${TESTS_DIR}" -name "test_*.sh" -type f -print0 | sort -z)
    fi

    if (( ${#suites[@]} == 0 )); then
        log_warning "No test suites found in ${TESTS_DIR}."
        exit 0
    fi

    for suite in "${suites[@]}"; do
        run_suite "$suite"
    done

    echo
    echo "────────────────────────────────────────"
    echo -e "  ${GREEN}Pass:${NC} ${_PASS}   ${RED}Fail:${NC} ${_FAIL}   ${YELLOW}Skip:${NC} ${_SKIP}"
    echo "────────────────────────────────────────"

    (( _FAIL == 0 ))
}

main "$@"
