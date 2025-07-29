#!/bin/bash
# test-banner.sh - Test banner alignment

BANNER_FILE="${1:-../../resources/banner.txt}"

echo "🧪 Testing Banner Alignment"
echo "=========================="
echo ""

# Test 1: All lines same length
echo "Test 1: Line Length Consistency"
if awk '{if (NR==1) {expected=length($0)} else if (length($0)!=expected) {print "Line",NR,"has",length($0),"chars, expected",expected; exit 1}}' "$BANNER_FILE"; then
    echo "✅ PASS: All lines have consistent length"
else
    echo "❌ FAIL: Inconsistent line lengths detected"
fi

# Test 2: Expected length is 69
echo -e "\nTest 2: Expected Line Length (69 chars)"
FIRST_LINE_LEN=$(head -1 "$BANNER_FILE" | wc -c)
FIRST_LINE_LEN=$((FIRST_LINE_LEN - 1))  # Remove newline
if [ "$FIRST_LINE_LEN" -eq 69 ]; then
    echo "✅ PASS: Lines are 69 characters as expected"
else
    echo "❌ FAIL: Lines are $FIRST_LINE_LEN characters (expected 69)"
fi

# Test 3: Box characters match
echo -e "\nTest 3: Box Drawing Characters"
if head -1 "$BANNER_FILE" | grep -q '^╔.*╗$' && \
   tail -1 "$BANNER_FILE" | grep -q '^╚.*╝$' && \
   grep -v '^[╔╚]' "$BANNER_FILE" | grep -v '^║.*║$' > /dev/null; then
    echo "❌ FAIL: Invalid box drawing structure"
else
    echo "✅ PASS: Box drawing characters are properly structured"
fi

# Test 4: Visual test
echo -e "\nTest 4: Visual Inspection"
echo "The banner should appear as a perfect rectangle:"
echo "------------------------------------------------"
cat "$BANNER_FILE"
echo "------------------------------------------------"

# Summary
echo -e "\n📊 Test Summary"
echo "==============="
awk '{
    len[length($0)]++
    total++
} END {
    if (length(len) == 1) {
        printf "✅ All %d lines are exactly %d characters\n", total, len[69]
    } else {
        print "❌ Line length distribution:"
        for (l in len) {
            printf "   %d chars: %d lines\n", l, len[l]
        }
    }
}' "$BANNER_FILE"