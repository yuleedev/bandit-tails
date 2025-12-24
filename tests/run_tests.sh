#!/bin/bash

# Integration Test Runner for Mole Heist
# Runs all integration tests for the multiplayer networking fixes

echo "=========================================="
echo "Mole Heist - Integration Test Suite"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find Godot executable
GODOT=""
if command -v godot &> /dev/null; then
    GODOT="godot"
elif command -v godot4 &> /dev/null; then
    GODOT="godot4"
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
else
    echo -e "${RED}Error: Godot executable not found${NC}"
    echo "Please ensure Godot 4.x is installed and in PATH"
    exit 1
fi

echo "Using Godot: $GODOT"
echo ""

# Project path
PROJECT_PATH="$(dirname "$(dirname "$(realpath "$0")")")"
cd "$PROJECT_PATH" || exit 1

# Test files
TESTS=(
    "tests/integration/test_round_timer_sync.tscn"
    "tests/integration/test_loot_pickup.tscn"
    "tests/integration/test_key_collection.tscn"
    "tests/integration/test_door_opening.tscn"
    "tests/integration/test_connection_failure.tscn"
    "tests/integration/test_round_wins.tscn"
)

PASSED=0
FAILED=0
TOTAL=${#TESTS[@]}

# Run each test
for test in "${TESTS[@]}"; do
    TEST_NAME=$(basename "$test" .tscn)
    echo -e "${YELLOW}Running: $TEST_NAME${NC}"
    echo "----------------------------------------"

    # Run the test
    if $GODOT --headless --quit-after 5 --path "$PROJECT_PATH" "$test" 2>&1 | tee /tmp/test_output.log | grep -q "✅ PASSED"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++))
    fi

    echo ""
done

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Total Tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✅${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed ❌${NC}"
    exit 1
fi
