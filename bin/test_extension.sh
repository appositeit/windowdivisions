#!/bin/bash

# Test script for Window Divisions extension
echo "Testing Window Divisions extension for GNOME Shell 49..."
echo "=================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Check directory structure
echo -e "\n${YELLOW}1. Checking directory structure...${NC}"
run_test "extension.js exists" "[ -f extension.js ]"
run_test "prefs.js exists" "[ -f prefs.js ]"
run_test "metadata.json exists" "[ -f metadata.json ]"
run_test "schemas directory exists" "[ -d schemas ]"
run_test "gschema XML exists" "[ -f schemas/org.gnome.shell.extensions.windowdivisions.gschema.xml ]"

# Check JavaScript syntax
echo -e "\n${YELLOW}2. Checking JavaScript syntax...${NC}"
run_test "extension.js syntax" "node -c extension.js"
run_test "prefs.js syntax" "node -c prefs.js"

# Check JSON validity
echo -e "\n${YELLOW}3. Checking JSON validity...${NC}"
run_test "metadata.json valid" "python3 -m json.tool metadata.json > /dev/null"

# Check XML validity
echo -e "\n${YELLOW}4. Checking XML validity...${NC}"
run_test "gschema XML valid" "xmllint --noout schemas/org.gnome.shell.extensions.windowdivisions.gschema.xml"

# Check GNOME Shell version support
echo -e "\n${YELLOW}5. Checking GNOME Shell version support...${NC}"
CURRENT_VERSION=$(gnome-shell --version | grep -oP '\d+' | head -1)
run_test "GNOME Shell $CURRENT_VERSION supported" "grep -q '\"$CURRENT_VERSION\"' metadata.json"

# Check for ES6 module syntax
echo -e "\n${YELLOW}6. Checking for ES6 module compatibility...${NC}"
run_test "extension.js uses ES6 imports" "grep -q '^import.*from.*gi://' extension.js"
run_test "extension.js exports default class" "grep -q '^export default class' extension.js"
run_test "prefs.js uses ES6 imports" "grep -q '^import.*from.*gi://' prefs.js"
run_test "prefs.js exports default class" "grep -q '^export default class' prefs.js"

# Check for old-style imports (should not exist)
echo -e "\n${YELLOW}7. Checking for deprecated imports...${NC}"
if grep -q 'imports\.' extension.js; then
    echo -e "${RED}✗ extension.js contains deprecated imports${NC}"
    ((TESTS_FAILED++))
else
    echo -e "${GREEN}✓ extension.js has no deprecated imports${NC}"
    ((TESTS_PASSED++))
fi

if grep -q '^const.*imports\.' prefs.js; then
    echo -e "${RED}✗ prefs.js contains deprecated imports${NC}"
    ((TESTS_FAILED++))
else
    echo -e "${GREEN}✓ prefs.js has no deprecated imports${NC}"
    ((TESTS_PASSED++))
fi

# Compile schemas
echo -e "\n${YELLOW}8. Compiling schemas...${NC}"
if glib-compile-schemas schemas/ 2>&1 | grep -q error; then
    echo -e "${RED}✗ Schema compilation failed${NC}"
    ((TESTS_FAILED++))
else
    echo -e "${GREEN}✓ Schema compilation successful${NC}"
    ((TESTS_PASSED++))
    run_test "gschemas.compiled exists" "[ -f schemas/gschemas.compiled ]"
fi

# Summary
echo -e "\n=================================================="
echo -e "${YELLOW}Test Summary:${NC}"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed! The extension appears ready for installation.${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed. Please fix the issues before installing.${NC}"
    exit 1
fi