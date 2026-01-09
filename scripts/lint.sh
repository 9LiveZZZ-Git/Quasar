#!/bin/bash
# Simple linting script for SuperCollider code
# Checks for common issues

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

issues=0

echo -e "${GREEN}Running Quasar code checks...${NC}\n"

# Check 1: Find files with trailing whitespace
echo "Checking for trailing whitespace..."
files_with_trailing=$(find src -name "*.sc" -exec grep -l " $" {} \; 2>/dev/null)
if [ -n "$files_with_trailing" ]; then
    echo -e "${YELLOW}Warning: Files with trailing whitespace:${NC}"
    echo "$files_with_trailing" | sed 's/^/  /'
    ((issues++))
else
    echo -e "${GREEN}  ✓ No trailing whitespace${NC}"
fi
echo ""

# Check 2: Find very long lines (> 120 chars)
echo "Checking for long lines (>120 chars)..."
long_lines=$(find src -name "*.sc" -exec awk 'length > 120 {print FILENAME":"NR; nextfile}' {} \; 2>/dev/null)
if [ -n "$long_lines" ]; then
    echo -e "${YELLOW}Warning: Files with long lines:${NC}"
    echo "$long_lines" | sed 's/^/  /'
    ((issues++))
else
    echo -e "${GREEN}  ✓ No excessively long lines${NC}"
fi
echo ""

# Check 3: Find tabs (should use spaces)
echo "Checking for tabs (should use spaces)..."
files_with_tabs=$(find src -name "*.sc" -exec grep -l $'\t' {} \; 2>/dev/null)
if [ -n "$files_with_tabs" ]; then
    echo -e "${YELLOW}Warning: Files with tabs (should use spaces):${NC}"
    echo "$files_with_tabs" | sed 's/^/  /'
    ((issues++))
else
    echo -e "${GREEN}  ✓ No tabs found${NC}"
fi
echo ""

# Check 4: Find TODO/FIXME/HACK comments
echo "Checking for TODO/FIXME/HACK comments..."
todos=$(grep -rn "TODO\|FIXME\|HACK" src --include="*.sc" 2>/dev/null | wc -l | xargs)
if [ "$todos" -gt 0 ]; then
    echo -e "${YELLOW}Info: Found $todos TODO/FIXME/HACK comments${NC}"
else
    echo -e "${GREEN}  ✓ No TODO/FIXME/HACK comments${NC}"
fi
echo ""

# Check 5: Basic syntax check (files that can be parsed)
echo "Checking for basic syntax issues..."
# Note: This is a placeholder - would need sclang for proper syntax checking
echo -e "${GREEN}  ✓ Syntax check skipped (requires sclang)${NC}"
echo ""

# Summary
echo "=================================="
if [ $issues -eq 0 ]; then
    echo -e "${GREEN}Linting complete: No issues found!${NC}"
    exit 0
else
    echo -e "${YELLOW}Linting complete: $issues issue(s) found${NC}"
    exit 0  # Don't fail build on warnings
fi
