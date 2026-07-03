#!/usr/bin/env bash
# scripts/validate.sh — TermKit validation runner
#
# Delegates to: bin/termkit validate
# Kept here for backward compatibility and CI convenience.
#
# Usage:
#   ./scripts/validate.sh                 # Validate all modules
#   ./scripts/validate.sh git shell       # Validate specific modules
#   ./scripts/validate.sh --quick         # Syntax-check scripts only (no module validation)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERMKIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Quick mode: syntax-check all scripts without loading the full CLI ──────────
if [[ "${1:-}" == "--quick" ]]; then
    source "${TERMKIT_ROOT}/lib/core.sh"
    log_section "Quick syntax check"

    errors=0
    while IFS= read -r -d '' f; do
        if bash -n "$f" 2>/dev/null; then
            log_success "OK: ${f#"${TERMKIT_ROOT}/"}"
        else
            log_error "FAIL: ${f#"${TERMKIT_ROOT}/"}"
            (( errors++ )) || true
        fi
    done < <(find "${TERMKIT_ROOT}" -name "*.sh" -not -path "*/.git/*" -type f -print0)

    echo
    if (( errors == 0 )); then
        log_success "All scripts pass syntax check."
    else
        log_error "$errors script(s) failed."
        exit 1
    fi
    exit 0
fi

# ── Full validation via CLI ───────────────────────────────────────────────────
exec "${TERMKIT_ROOT}/bin/termkit" validate "$@"
