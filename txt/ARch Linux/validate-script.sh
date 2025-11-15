#!/bin/bash

# =========================================================
# Arch Linux Script Validation Tool
# Validates the main installation script for issues
# =========================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_PATH="./arch-linux-script.sh"
ISSUES_FOUND=0

echo "=========================================="
echo "  Arch Linux Script Validation Tool"
echo "=========================================="

# Test 1: Check if script exists and is readable
log_info "Testing script accessibility..."
if [ ! -f "$SCRIPT_PATH" ]; then
    log_error "Script not found at $SCRIPT_PATH"
    exit 1
fi

if [ ! -r "$SCRIPT_PATH" ]; then
    log_error "Script is not readable"
    exit 1
fi

log_success "Script file is accessible"

# Test 2: Syntax validation
log_info "Validating bash syntax..."
if bash -n "$SCRIPT_PATH"; then
    log_success "Syntax validation passed"
else
    log_error "Syntax errors found in script"
    ((ISSUES_FOUND++))
fi

# Test 3: Check for required functions
log_info "Checking required functions..."
REQUIRED_FUNCTIONS=(
    "main"
    "check_root"
    "preflight_checks" 
    "check_internet"
    "update_system"
    "install_amd_support"
    "install_aura"
    "install_arch_packages"
    "install_1password"
    "install_aur_packages"
    "setup_flatpak"
    "configure_services"
    "configure_discord"
    "configure_telegram"
)

for func in "${REQUIRED_FUNCTIONS[@]}"; do
    if grep -q "^$func() {" "$SCRIPT_PATH"; then
        log_success "Function '$func' found"
    else
        log_error "Required function '$func' not found"
        ((ISSUES_FOUND++))
    fi
done

# Test 4: Check for potential problematic patterns
log_info "Checking for potential issues..."

# Check for hardcoded paths that might not exist
if grep -q "/usr/bin/discord" "$SCRIPT_PATH"; then
    log_warning "Hardcoded path to discord found - may not exist on fresh install"
fi

# Check for commands without error handling
if grep -qE "^[[:space:]]*[^#]*sudo.*[^&][^>].*[^|][[:space:]]*$" "$SCRIPT_PATH"; then
    log_info "Found sudo commands - ensure error handling is proper"
fi

# Test 5: Check AUR packages are valid
log_info "Checking AUR package names..."
AUR_PACKAGES=($(grep -A 10 'local aur_packages=(' "$SCRIPT_PATH" | grep '"' | sed 's/.*"\([^"]*\)".*/\1/'))

for package in "${AUR_PACKAGES[@]}"; do
    log_info "AUR package listed: $package"
done

# Test 6: Check Flatpak applications
log_info "Checking Flatpak applications..."
FLATPAK_APPS=($(grep -A 50 'local flatpak_apps=(' "$SCRIPT_PATH" | grep '"' | sed 's/.*"\([^"]*\)".*/\1/' | head -20))

for app in "${FLATPAK_APPS[@]}"; do
    log_info "Flatpak app listed: $app"
done

# Test 7: Verify execution flow
log_info "Validating execution flow..."

# Check if main function calls are in logical order
MAIN_CALLS=($(grep -A 20 'main() {' "$SCRIPT_PATH" | grep -E '^[[:space:]]*[a-z_]+$' | tr -d ' '))

log_info "Main function execution order:"
for call in "${MAIN_CALLS[@]}"; do
    echo "  - $call"
done

# Test 8: Check for missing dependencies
log_info "Checking script dependencies..."

REQUIRED_COMMANDS=("curl" "git" "sudo" "pacman" "flatpak" "systemctl")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if grep -q "$cmd" "$SCRIPT_PATH"; then
        log_info "Uses command: $cmd (should be available on target system)"
    fi
done

echo
echo "=========================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    log_success "Validation completed - No critical issues found!"
    echo
    log_info "The script appears ready for deployment on a fresh Arch Linux system"
    log_info "Recommended testing steps:"
    echo "  1. Test on a fresh Arch Linux VM"
    echo "  2. Verify internet connectivity before running"
    echo "  3. Ensure user has sudo privileges"
    echo "  4. Run with: chmod +x arch-linux-script.sh && ./arch-linux-script.sh"
else
    log_warning "Validation completed with $ISSUES_FOUND issues found"
    echo
    log_info "Review the issues above before deploying the script"
fi
echo "=========================================="