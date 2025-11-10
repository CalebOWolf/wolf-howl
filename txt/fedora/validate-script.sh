#!/bin/bash
# =============================================================================
# Fedora Setup Script Validator
# =============================================================================
# This script validates the main installation script without making changes
# Used for testing and verification purposes
# =============================================================================

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Script location
MAIN_SCRIPT="$(dirname "$0")/fedora-install-script.sh"
readonly MAIN_SCRIPT

# Validation functions
validate_syntax() {
    echo -e "${BLUE}[CHECK]${NC} Validating shell script syntax..."
    
    if bash -n "$MAIN_SCRIPT" 2>/dev/null; then
        echo -e "${GREEN}✅ Script syntax is valid${NC}"
        return 0
    else
        echo -e "${RED}❌ Script has syntax errors${NC}"
        bash -n "$MAIN_SCRIPT"
        return 1
    fi
}

validate_requirements() {
    echo -e "${BLUE}[CHECK]${NC} Validating system requirements..."
    
    local issues=0
    
    # Check if shellcheck is available for additional validation
    if command -v shellcheck >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ShellCheck available for advanced validation${NC}"
        
        echo -e "${BLUE}[CHECK]${NC} Running ShellCheck analysis..."
        if shellcheck "$MAIN_SCRIPT"; then
            echo -e "${GREEN}✅ No ShellCheck issues found${NC}"
        else
            echo -e "${YELLOW}⚠️  ShellCheck found potential issues (see above)${NC}"
            ((issues++))
        fi
    else
        echo -e "${YELLOW}⚠️  ShellCheck not installed - install with: sudo dnf install ShellCheck${NC}"
    fi
    
    # Check script permissions
    if [[ -x "$MAIN_SCRIPT" ]]; then
        echo -e "${GREEN}✅ Script has execute permissions${NC}"
    else
        echo -e "${YELLOW}⚠️  Script is not executable - run: chmod +x '$MAIN_SCRIPT'${NC}"
        ((issues++))
    fi
    
    return $issues
}

validate_urls() {
    echo -e "${BLUE}[CHECK]${NC} Validating download URLs..."
    
    local urls=(
        "https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm"
        "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
        "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
        "https://flathub.org/repo/flathub.flatpakrepo"
    )
    
    local failed_urls=0
    
    for url in "${urls[@]}"; do
        if curl --output /dev/null --silent --head --fail "$url" 2>/dev/null; then
            echo -e "${GREEN}✅ $url${NC}"
        else
            echo -e "${RED}❌ $url${NC}"
            ((failed_urls++))
        fi
    done
    
    if [[ $failed_urls -eq 0 ]]; then
        echo -e "${GREEN}✅ All URLs are accessible${NC}"
    else
        echo -e "${YELLOW}⚠️  $failed_urls URLs failed accessibility check${NC}"
    fi
    
    return $failed_urls
}

validate_fedora_compatibility() {
    echo -e "${BLUE}[CHECK]${NC} Validating Fedora compatibility..."
    
    if grep -q "Fedora" /etc/os-release 2>/dev/null; then
        local fedora_version
        fedora_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"')
        echo -e "${GREEN}✅ Running on Fedora $fedora_version${NC}"
        
        if [[ $fedora_version -ge 35 ]]; then
            echo -e "${GREEN}✅ Fedora version is supported${NC}"
        else
            echo -e "${YELLOW}⚠️  Fedora version may be too old (recommended: 35+)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Not running on Fedora - script designed for Fedora Linux${NC}"
    fi
}

show_script_info() {
    echo -e "${BLUE}[INFO]${NC} Script information:"
    echo "  Location: $MAIN_SCRIPT"
    echo "  Size: $(stat -f%z "$MAIN_SCRIPT" 2>/dev/null || stat -c%s "$MAIN_SCRIPT") bytes"
    echo "  Last modified: $(stat -f%Sm "$MAIN_SCRIPT" 2>/dev/null || stat -c%y "$MAIN_SCRIPT" | cut -d. -f1)"
    echo "  Lines of code: $(wc -l < "$MAIN_SCRIPT")"
}

main() {
    echo -e "${BLUE}===============================================================================${NC}"
    echo -e "${BLUE}  Fedora Setup Script Validator${NC}"
    echo -e "${BLUE}===============================================================================${NC}"
    echo
    
    # Check if main script exists
    if [[ ! -f "$MAIN_SCRIPT" ]]; then
        echo -e "${RED}❌ Main script not found: $MAIN_SCRIPT${NC}"
        exit 1
    fi
    
    show_script_info
    echo
    
    local total_issues=0
    
    # Run validation checks
    validate_syntax || ((total_issues++))
    echo
    
    validate_requirements || ((total_issues+=1))
    echo
    
    validate_urls || ((total_issues+=1))
    echo
    
    validate_fedora_compatibility
    echo
    
    # Final report
    echo -e "${BLUE}===============================================================================${NC}"
    if [[ $total_issues -eq 0 ]]; then
        echo -e "${GREEN}✅ All validation checks passed!${NC}"
        echo -e "${GREEN}   The script appears ready for execution.${NC}"
    elif [[ $total_issues -le 2 ]]; then
        echo -e "${YELLOW}⚠️  Validation completed with $total_issues minor issues${NC}"
        echo -e "${YELLOW}   Review the warnings above before running the script.${NC}"
    else
        echo -e "${RED}❌ Validation found $total_issues issues${NC}"
        echo -e "${RED}   Please address the errors before running the script.${NC}"
    fi
    echo -e "${BLUE}===============================================================================${NC}"
    
    return $total_issues
}

main "$@"