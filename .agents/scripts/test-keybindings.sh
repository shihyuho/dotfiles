#!/usr/bin/env bash
#
# Keybinding Configuration Test Suite
# Tests Ghostty keybinding configuration for correctness
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GHOSTTY_CONFIG="$DOTFILES_ROOT/config/ghostty/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test result tracking
declare -a FAILED_TEST_NAMES=()

#######################################
# Print formatted test result
# Arguments:
#   $1 - Test name
#   $2 - Result (0 = pass, 1 = fail)
#   $3 - Optional message
#######################################
test_result() {
    local test_name="$1"
    local result="$2"
    local message="${3:-}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        [ -n "$message" ] && echo -e "  ${YELLOW}→${NC} $message"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TEST_NAMES+=("$test_name")
    fi
}

#######################################
# Test Ghostty Configuration
#######################################
test_ghostty_config() {
    echo -e "\n${BLUE}=== Testing Ghostty Configuration ===${NC}\n"
    
    # Test 1: Config file exists
    if [ -f "$GHOSTTY_CONFIG" ]; then
        test_result "Ghostty config file exists" 0
    else
        test_result "Ghostty config file exists" 1 "File not found: $GHOSTTY_CONFIG"
        return 1
    fi
    
    # Test 2: macos-option-as-alt is set
    if grep -q "^macos-option-as-alt = left" "$GHOSTTY_CONFIG"; then
        test_result "Ghostty: macos-option-as-alt is set to 'left'" 0
    else
        test_result "Ghostty: macos-option-as-alt is set to 'left'" 1 "Setting not found or incorrect"
    fi
    
    # Test 3: Command+C/V clipboard bindings exist
    if grep -q "keybind = cmd+c=copy_to_clipboard" "$GHOSTTY_CONFIG" && grep -q "keybind = cmd+v=paste_from_clipboard" "$GHOSTTY_CONFIG"; then
        test_result "Ghostty: Command+C/V clipboard bindings exist" 0
    else
        test_result "Ghostty: Command+C/V clipboard bindings exist" 1 "Clipboard keybinds not found"
    fi
    
    # Test 4: Command+Left/Right mappings exist
    if grep -q "keybind = cmd+left=" "$GHOSTTY_CONFIG" && grep -q "keybind = cmd+right=" "$GHOSTTY_CONFIG"; then
        test_result "Ghostty: Command+Left/Right mappings exist" 0
    else
        test_result "Ghostty: Command+Left/Right mappings exist" 1 "Mappings not found"
    fi
    
    # Test 5: Clipboard integration is enabled
    if grep -q "^clipboard-read = allow" "$GHOSTTY_CONFIG" && grep -q "^clipboard-write = allow" "$GHOSTTY_CONFIG"; then
        test_result "Ghostty: Clipboard integration is enabled" 0
    else
        test_result "Ghostty: Clipboard integration is enabled" 1 "Clipboard settings not found"
    fi
    
    # Test 6: Split keybindings exist
    if grep -q "keybind = cmd+d=new_split:right" "$GHOSTTY_CONFIG" && grep -q "keybind = cmd+shift+d=new_split:down" "$GHOSTTY_CONFIG"; then
        test_result "Ghostty: Split keybindings exist" 0
    else
        test_result "Ghostty: Split keybindings exist" 1 "Split keybinds not found"
    fi
}

#######################################
# Generate Test Report
#######################################
generate_report() {
    echo -e "\n${BLUE}=== Test Summary ===${NC}\n"
    
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}Failed: $FAILED_TESTS${NC}"
        echo -e "\n${RED}Failed Tests:${NC}"
        for test_name in "${FAILED_TEST_NAMES[@]}"; do
            echo -e "  ${RED}✗${NC} $test_name"
        done
        return 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

#######################################
# Main
#######################################
main() {
    local test_type="${1:-all}"
    
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Keybinding Configuration Test Suite  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    case "$test_type" in
        ghostty)
            test_ghostty_config
            ;;
        report)
            generate_report
            ;;
        all)
            test_ghostty_config
            generate_report
            ;;
        *)
            echo "Usage: $0 {ghostty|report|all}"
            exit 1
            ;;
    esac
}

main "$@"
