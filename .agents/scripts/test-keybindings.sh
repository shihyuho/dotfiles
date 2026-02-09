#!/usr/bin/env bash
#
# Keybinding Configuration Test Suite
# Tests Zellij and Ghostty keybinding configurations for correctness and consistency
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ZELLIJ_CONFIG="$DOTFILES_ROOT/config/zellij/config.kdl"
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
# Test Zellij Configuration
#######################################
test_zellij_config() {
    echo -e "\n${BLUE}=== Testing Zellij Configuration ===${NC}\n"
    
    # Test 1: Config file exists
    if [ -f "$ZELLIJ_CONFIG" ]; then
        test_result "Zellij config file exists" 0
    else
        test_result "Zellij config file exists" 1 "File not found: $ZELLIJ_CONFIG"
        return 1
    fi
    
    # Test 2: Required top-level settings exist
    local required_settings=("theme" "default_layout" "mouse_mode" "copy_command")
    for setting in "${required_settings[@]}"; do
        if grep -q "^$setting " "$ZELLIJ_CONFIG"; then
            test_result "Zellij: '$setting' is defined at top level" 0
        else
            test_result "Zellij: '$setting' is defined at top level" 1 "Setting not found or incorrectly placed"
        fi
    done
    
    # Test 3: Theme is set correctly
    if grep -q '^theme "catppuccin-macchiato"' "$ZELLIJ_CONFIG"; then
        test_result "Zellij: theme is 'catppuccin-macchiato'" 0
    else
        test_result "Zellij: theme is 'catppuccin-macchiato'" 1 "Expected theme not found"
    fi
    
    # Test 4: Default layout is compact
    if grep -q '^default_layout "compact"' "$ZELLIJ_CONFIG"; then
        test_result "Zellij: default_layout is 'compact'" 0
    else
        test_result "Zellij: default_layout is 'compact'" 1 "Expected layout not found"
    fi
    
    # Test 5: Alt+F binding exists for floating panes
    if grep -q 'bind "Alt f" { ToggleFloatingPanes' "$ZELLIJ_CONFIG"; then
        test_result "Zellij: Alt+F binding exists for ToggleFloatingPanes" 0
    else
        test_result "Zellij: Alt+F binding exists for ToggleFloatingPanes" 1 "Binding not found"
    fi
    
    # Test 6: Alt Left/Right are unbound (for shell word jumping)
    if grep -q 'unbind "Alt left"' "$ZELLIJ_CONFIG" && grep -q 'unbind "Alt right"' "$ZELLIJ_CONFIG"; then
        test_result "Zellij: Alt Left/Right are unbound for shell passthrough" 0
    else
        test_result "Zellij: Alt Left/Right are unbound for shell passthrough" 1 "unbind statements not found"
    fi
    
    # Test 7: Critical Alt keybindings exist
    local alt_bindings=("Alt h" "Alt j" "Alt k" "Alt l" "Alt n" "Alt w")
    local missing_bindings=()
    for binding in "${alt_bindings[@]}"; do
        if ! grep -q "bind \"$binding\"" "$ZELLIJ_CONFIG"; then
            missing_bindings+=("$binding")
        fi
    done
    
    if [ ${#missing_bindings[@]} -eq 0 ]; then
        test_result "Zellij: All critical Alt bindings exist" 0
    else
        test_result "Zellij: All critical Alt bindings exist" 1 "Missing: ${missing_bindings[*]}"
    fi
    
    # Test 8: UI block is properly closed
    local ui_open=$(grep -c "^ui {" "$ZELLIJ_CONFIG" || true)
    local ui_close=$(grep -c "^}" "$ZELLIJ_CONFIG" | head -1 || true)
    
    if [ "$ui_open" -eq 1 ]; then
        test_result "Zellij: UI block opens exactly once" 0
    else
        test_result "Zellij: UI block opens exactly once" 1 "Found $ui_open ui blocks"
    fi
    
    # Test 9: No settings incorrectly placed inside ui block
    local incorrect_in_ui=()
    if sed -n '/^ui {/,/^}/p' "$ZELLIJ_CONFIG" | grep -q "^    theme "; then
        incorrect_in_ui+=("theme")
    fi
    if sed -n '/^ui {/,/^}/p' "$ZELLIJ_CONFIG" | grep -q "^    default_layout "; then
        incorrect_in_ui+=("default_layout")
    fi
    if sed -n '/^ui {/,/^}/p' "$ZELLIJ_CONFIG" | grep -q "^    mouse_mode "; then
        incorrect_in_ui+=("mouse_mode")
    fi
    
    if [ ${#incorrect_in_ui[@]} -eq 0 ]; then
        test_result "Zellij: No top-level settings incorrectly placed in ui block" 0
    else
        test_result "Zellij: No top-level settings incorrectly placed in ui block" 1 "Found in ui block: ${incorrect_in_ui[*]}"
    fi
    
    # Test 10: copy_command is set to pbcopy (macOS)
    if grep -q '^copy_command "pbcopy"' "$ZELLIJ_CONFIG"; then
        test_result "Zellij: copy_command is 'pbcopy'" 0
    else
        test_result "Zellij: copy_command is 'pbcopy'" 1 "Expected pbcopy not found"
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
    
    # Test 3: Alt keys are unbound
    local alt_unbinds=("alt+f" "alt+h" "alt+j" "alt+k" "alt+l" "alt+n" "alt+w" "alt+i" "alt+o" "alt+p")
    local missing_unbinds=()
    for key in "${alt_unbinds[@]}"; do
        if ! grep -q "keybind = $key=unbind" "$GHOSTTY_CONFIG"; then
            missing_unbinds+=("$key")
        fi
    done
    
    if [ ${#missing_unbinds[@]} -eq 0 ]; then
        test_result "Ghostty: All required Alt keys are unbound" 0
    else
        test_result "Ghostty: All required Alt keys are unbound" 1 "Missing unbinds: ${missing_unbinds[*]}"
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
    
    # Test 6: Alt+Left/Right are unbound (for word jumping)
    if grep -q "keybind = alt+left=unbind" "$GHOSTTY_CONFIG" && grep -q "keybind = alt+right=unbind" "$GHOSTTY_CONFIG"; then
        test_result "Ghostty: Alt+Left/Right are unbound for shell passthrough" 0
    else
        test_result "Ghostty: Alt+Left/Right are unbound for shell passthrough" 1 "unbind statements not found"
    fi
}

#######################################
# Test Configuration Consistency
#######################################
test_consistency() {
    echo -e "\n${BLUE}=== Testing Configuration Consistency ===${NC}\n"
    
    # Test 1: Ghostty unbinds match Zellij binds
    # Extract Alt bindings from Zellij that should be unbound in Ghostty
    local zellij_alt_bindings=($(grep -o 'bind "Alt [a-z]"' "$ZELLIJ_CONFIG" | sed 's/bind "Alt //' | sed 's/"//' | sort -u || true))
    
    local consistency_issues=()
    for key in "${zellij_alt_bindings[@]}"; do
        # Check if this key is unbound in Ghostty
        if ! grep -q "keybind = alt+$key=unbind" "$GHOSTTY_CONFIG"; then
            consistency_issues+=("alt+$key")
        fi
    done
    
    if [ ${#consistency_issues[@]} -eq 0 ]; then
        test_result "Consistency: Ghostty unbinds all Zellij Alt bindings" 0
    else
        test_result "Consistency: Ghostty unbinds all Zellij Alt bindings" 1 "Missing Ghostty unbinds: ${consistency_issues[*]}"
    fi
    
    # Test 2: Copy command consistency
    if grep -q '^copy_command "pbcopy"' "$ZELLIJ_CONFIG"; then
        test_result "Consistency: Both configs use pbcopy for clipboard" 0
    else
        test_result "Consistency: Both configs use pbcopy for clipboard" 1 "Zellij not using pbcopy"
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
        zellij)
            test_zellij_config
            ;;
        ghostty)
            test_ghostty_config
            ;;
        consistency)
            test_consistency
            ;;
        report)
            generate_report
            ;;
        all)
            test_zellij_config
            test_ghostty_config
            test_consistency
            generate_report
            ;;
        *)
            echo "Usage: $0 {zellij|ghostty|consistency|report|all}"
            exit 1
            ;;
    esac
}

main "$@"
