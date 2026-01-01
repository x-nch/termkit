#!/usr/bin/env bash

# TermKit Security Module
# Provides secure functions for remote script execution and file verification

set -euo pipefail

# Constants
readonly SECURITY_VERSION="1.0.0"
readonly TEMP_DIR="/tmp/termkit_security_$$"
readonly SHA256_REGEX="^[0-9a-f]{64}$"
readonly SHA256_CHECKSUM_REGEX="^[0-9a-f]{64}\s+.*$"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[SECURITY]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SECURITY]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[SECURITY]${NC} $*"
}

log_error() {
    echo -e "${RED}[SECURITY]${NC} $*" >&2
}

# Security initialization
init_security() {
    # Create secure temporary directory
    if [[ ! -d "$TEMP_DIR" ]]; then
        mkdir -p "$TEMP_DIR"
        chmod 700 "$TEMP_DIR"
    fi
    
    # Set trap for cleanup
    trap cleanup_security EXIT INT TERM
    
    # Validate environment
    validate_environment
}

# Cleanup function
cleanup_security() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_info "Security temporary directory cleaned up"
    fi
}

# Environment validation
validate_environment() {
    log_info "Validating security environment..."
    
    # Check for required tools
    local required_tools=("curl" "sha256sum" "chmod" "rm")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "Required security tool not found: $tool"
            return 1
        fi
    done
    
    # Check temp directory permissions
    local temp_parent
    temp_parent="$(dirname "$TEMP_DIR")"
    if [[ ! -w "$temp_parent" ]]; then
        log_error "Cannot write to temp directory parent: $temp_parent"
        return 1
    fi
    
    log_success "Security environment validated"
    return 0
}

# Hash validation
validate_sha256_hash() {
    local hash="$1"
    
    if [[ ! "$hash" =~ $SHA256_REGEX ]]; then
        log_error "Invalid SHA256 hash format: $hash"
        return 1
    fi
    
    return 0
}

validate_sha256_checksum() {
    local checksum="$1"
    
    if [[ ! "$checksum" =~ $SHA256_CHECKSUM_REGEX ]]; then
        log_error "Invalid SHA256 checksum format: $checksum"
        return 1
    fi
    
    return 0
}

# URL validation
validate_url() {
    local url="$1"
    
    # Basic URL validation
    if [[ ! "$url" =~ ^https?:// ]] && [[ ! "$url" =~ ^ftp:// ]]; then
        log_error "Invalid URL protocol (must be http, https, or ftp): $url"
        return 1
    fi
    
    # Check for suspicious patterns
    local suspicious_patterns=("curl.*|.*bash" "wget.*|.*bash" "rm.*-rf.*/" "dd.*if=")
    for pattern in "${suspicious_patterns[@]}"; do
        if [[ "$url" =~ $pattern ]]; then
            log_error "Suspicious pattern detected in URL: $pattern"
            return 1
        fi
    done
    
    return 0
}

# Secure download function
secure_download() {
    local url="$1"
    local expected_hash="$2"
    local output_file="${3:-$(basename "$url")}"
    local download_path="$TEMP_DIR/$output_file"
    
    log_info "Secure download initiated"
    log_info "URL: $url"
    log_info "Expected hash: ${expected_hash:0:16}..."
    log_info "Output: $output_file"
    
    # Validate inputs
    validate_url "$url" || return 1
    validate_sha256_hash "$expected_hash" || return 1
    
    # Check if file already exists and verify
    if [[ -f "$download_path" ]]; then
        if verify_file_hash "$download_path" "$expected_hash"; then
            log_info "File already exists and verified: $output_file"
            echo "$download_path"
            return 0
        else
            log_warning "Existing file failed verification, re-downloading"
            rm -f "$download_path"
        fi
    fi
    
    # Download file
    log_info "Downloading file..."
    if ! curl -fsSL -o "$download_path" --connect-timeout 30 --max-time 300 "$url"; then
        log_error "Download failed: $url"
        return 1
    fi
    
    # Verify file hash
    if ! verify_file_hash "$download_path" "$expected_hash"; then
        log_error "Hash verification failed for downloaded file"
        rm -f "$download_path"
        return 1
    fi
    
    log_success "File downloaded and verified successfully"
    echo "$download_path"
}

# File hash verification
verify_file_hash() {
    local file_path="$1"
    local expected_hash="$2"
    
    if [[ ! -f "$file_path" ]]; then
        log_error "File not found for verification: $file_path"
        return 1
    fi
    
    validate_sha256_hash "$expected_hash" || return 1
    
    local actual_hash
    actual_hash=$(sha256sum "$file_path" | cut -d' ' -f1)
    
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        log_success "Hash verification passed: $file_path"
        return 0
    else
        log_error "Hash verification failed"
        log_error "Expected: $expected_hash"
        log_error "Actual:   $actual_hash"
        return 1
    fi
}

# Secure script execution
secure_execute_script() {
    local script_url="$1"
    local script_hash="$2"
    local script_args="${3:-}"
    
    log_info "Secure script execution initiated"
    
    # Download script
    local script_path
    script_path=$(secure_download "$script_url" "$script_hash") || return 1
    
    # Make script executable
    chmod 700 "$script_path"
    
    # Execute script with proper security
    log_info "Executing script: $script_path"
    
    local exit_code=0
    if [[ -n "$script_args" ]]; then
        "$script_path" $script_args || exit_code=$?
    else
        "$script_path" || exit_code=$?
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Script executed successfully"
    else
        log_error "Script execution failed with exit code: $exit_code"
    fi
    
    return $exit_code
}

# Secure remote config fetch
fetch_remote_config() {
    local config_url="$1"
    local config_hash="$2"
    local output_path="$3"
    
    log_info "Fetching remote configuration"
    
    local temp_config
    temp_config=$(secure_download "$config_url" "$config_hash") || return 1
    
    # Create output directory if needed
    local output_dir
    output_dir="$(dirname "$output_path")"
    if [[ ! -d "$output_dir" ]]; then
        mkdir -p "$output_dir"
        chmod 755 "$output_dir"
    fi
    
    # Copy config to target location
    cp "$temp_config" "$output_path"
    chmod 644 "$output_path"
    
    log_success "Configuration installed: $output_path"
    return 0
}

# Batch verification function
verify_batch_files() {
    local -n batch_files=$1  # Array of "url:hash:output" triples
    
    log_info "Starting batch file verification..."
    
    local failed_files=0
    local total_files=0
    
    for file_spec in "${batch_files[@]}"; do
        IFS=':' read -r url hash output <<< "$file_spec"
        
        ((total_files++))
        
        if secure_download "$url" "$hash" "$output" >/dev/null; then
            log_success "Verified: $output"
        else
            log_error "Failed to verify: $output"
            ((failed_files++))
        fi
    done
    
    if [[ $failed_files -eq 0 ]]; then
        log_success "All $total_files files verified successfully"
        return 0
    else
        log_error "$failed_files out of $total_files files failed verification"
        return 1
    fi
}

# Security audit function
audit_scripts() {
    local script_dir="${1:-.}"
    
    log_info "Starting security audit of scripts in: $script_dir"
    
    local security_issues=0
    
    # Find all shell scripts
    while IFS= read -r -d '' script; do
        log_info "Auditing: $(basename "$script")"
        
        # Check for dangerous patterns
        local dangerous_patterns=(
            "curl.*|.*bash"
            "wget.*|.*bash"
            "eval.*\$"
            "exec.*\$"
            "rm.*-rf.*/"
            "dd.*if="
            "chmod.*777"
            "sudo.*rm"
        )
        
        for pattern in "${dangerous_patterns[@]}"; do
            if grep -E "$pattern" "$script" >/dev/null 2>&1; then
                log_warning "Dangerous pattern found: $pattern in $(basename "$script")"
                ((security_issues++))
            fi
        done
        
        # Check for hash verification
        if grep -q "sha256sum" "$script" >/dev/null 2>&1; then
            log_success "Hash verification found in: $(basename "$script")"
        else
            log_warning "No hash verification found in: $(basename "$script")"
            ((security_issues++))
        fi
        
    done < <(find "$script_dir" -name "*.sh" -type f -print0)
    
    if [[ $security_issues -eq 0 ]]; then
        log_success "No security issues found"
    else
        log_warning "$security_issues potential security issues found"
    fi
    
    return $security_issues
}

# Certificate verification for HTTPS
verify_certificate() {
    local url="$1"
    local domain="${url#https://}"
    domain="${domain%%/*}"
    
    log_info "Verifying SSL certificate for: $domain"
    
    if command -v openssl >/dev/null 2>&1; then
        if echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -dates >/dev/null 2>&1; then
            log_success "SSL certificate verification passed for: $domain"
            return 0
        else
            log_error "SSL certificate verification failed for: $domain"
            return 1
        fi
    else
        log_warning "OpenSSL not available, skipping certificate verification"
        return 0
    fi
}

# Checksum file creation
create_checksum_file() {
    local file="$1"
    local checksum_file="${2:-${file}.sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found for checksum creation: $file"
        return 1
    fi
    
    local hash
    hash=$(sha256sum "$file" | cut -d' ' -f1)
    echo "$hash  $(basename "$file")" > "$checksum_file"
    
    log_success "Checksum file created: $checksum_file"
    echo "$hash"
}

# Verify checksum file
verify_checksum_file() {
    local file="$1"
    local checksum_file="$2"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found for verification: $file"
        return 1
    fi
    
    if [[ ! -f "$checksum_file" ]]; then
        log_error "Checksum file not found: $checksum_file"
        return 1
    fi
    
    # Change to directory containing the file for verification
    local file_dir
    file_dir="$(dirname "$file")"
    local file_name
    file_name="$(basename "$file")"
    
    if (cd "$file_dir" && sha256sum -c "$checksum_file" 2>/dev/null | grep -q "$file_name"); then
        log_success "Checksum verification passed: $file"
        return 0
    else
        log_error "Checksum verification failed: $file"
        return 1
    fi
}

# Main security initialization
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    case "${1:-}" in
        --help|-h)
            cat << EOF
TermKit Security Module

Usage: $(basename "$0") [options]

Options:
  --audit [dir]      Audit scripts for security issues
  --verify file hash  Verify file hash
  --download url hash output Secure download
  --exec url hash [args] Secure script execution
  --help, -h         Show this help message

Examples:
  $(basename "$0") --verify script.sh abc123...
  $(basename "$0") --download https://example.com/script.sh abc123... script.sh
  $(basename "$0") --exec https://example.com/install.sh abc123...

EOF
            exit 0
            ;;
        --audit)
            init_security
            audit_scripts "${2:-.}"
            exit $?
            ;;
        --verify)
            if [[ $# -lt 3 ]]; then
                log_error "Usage: $0 --verify <file> <hash>"
                exit 1
            fi
            init_security
            verify_file_hash "$2" "$3"
            exit $?
            ;;
        --download)
            if [[ $# -lt 4 ]]; then
                log_error "Usage: $0 --download <url> <hash> <output>"
                exit 1
            fi
            init_security
            secure_download "$2" "$3" "$4"
            exit $?
            ;;
        --exec)
            if [[ $# -lt 3 ]]; then
                log_error "Usage: $0 --exec <url> <hash> [args]"
                exit 1
            fi
            init_security
            secure_execute_script "$2" "$3" "${4:-}"
            exit $?
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
fi

# Export functions for use in other scripts
export -f init_security
export -f cleanup_security
export -f secure_download
export -f verify_file_hash
export -f secure_execute_script
export -f fetch_remote_config
export -f audit_scripts
export -f verify_certificate
export -f create_checksum_file
export -f verify_checksum_file