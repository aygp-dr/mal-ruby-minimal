#!/bin/bash
# debug-banner.sh - Debug and fix banner alignment issues

BANNER_FILE="${1:-../../resources/banner.txt}"

echo "🔍 Banner Alignment Debugger"
echo "============================"
echo ""

# Function to visualize line lengths
visualize_lengths() {
    echo "Line Length Visualization:"
    echo "Line | Len | Content"
    echo "-----|-----|--------"
    
    awk '{
        printf "%4d | %3d | ", NR, length($0)
        
        # Visual bar showing length
        for (i = 0; i < length($0); i++) {
            if (i < 67) printf "="
            else if (i < 69) printf "+"
            else printf "!"
        }
        
        # Show if line is correct length
        if (length($0) == 69) printf " ✓"
        else printf " ✗ (off by %d)", 69 - length($0)
        
        print ""
    }' "$BANNER_FILE"
}

# Function to show detailed analysis
detailed_analysis() {
    echo -e "\nDetailed Analysis:"
    echo "=================="
    
    # Count line length distribution
    echo -e "\nLine Length Distribution:"
    awk '{lengths[length($0)]++} END {for (l in lengths) printf "  %d chars: %d lines\n", l, lengths[l]}' "$BANNER_FILE" | sort -n
    
    # Show problematic lines
    echo -e "\nProblematic Lines (not 69 chars):"
    awk 'length($0) != 69 {printf "  Line %2d (%d chars): %s\n", NR, length($0), substr($0, 1, 50) "..."}' "$BANNER_FILE"
    
    # Check for specific issues
    echo -e "\nChecking for common issues:"
    
    # Tab characters
    if grep -q $'\t' "$BANNER_FILE"; then
        echo "  ⚠️  Found tab characters (should use spaces)"
    else
        echo "  ✓ No tab characters found"
    fi
    
    # Trailing spaces
    if grep -q ' $' "$BANNER_FILE"; then
        echo "  ℹ️  Found lines with trailing spaces"
    else
        echo "  ✓ No trailing spaces found"
    fi
    
    # Non-ASCII characters besides box drawing
    if grep -v -E '^[║╔╚═╗╝ A-Za-z0-9\!\*\(\)\-\+\/\=\<\>\:\;\,\.\'\"\?\s]+$' "$BANNER_FILE" > /dev/null; then
        echo "  ⚠️  Found unexpected non-ASCII characters"
    else
        echo "  ✓ Only expected characters found"
    fi
}

# Function to generate fixed version
generate_fixed() {
    echo -e "\nGenerating Fixed Version:"
    echo "========================"
    
    FIXED_FILE="${BANNER_FILE}.fixed"
    
    awk '{
        line = $0
        target_len = 69
        current_len = length(line)
        
        if (current_len < target_len && substr(line, 1, 1) == "║" && substr(line, current_len, 1) == "║") {
            # Extract content between borders
            content = substr(line, 2, current_len - 2)
            # Calculate padding needed
            padding_needed = target_len - current_len
            # Add padding before the closing border
            for (i = 0; i < padding_needed; i++) {
                content = content " "
            }
            line = "║" content "║"
        }
        
        print line
    }' "$BANNER_FILE" > "$FIXED_FILE"
    
    echo "Fixed version written to: $FIXED_FILE"
    echo ""
    echo "Verification of fixed file:"
    if awk 'length($0) != 69 {exit 1}' "$FIXED_FILE"; then
        echo "✅ All lines are now 69 characters!"
    else
        echo "❌ Some lines still have incorrect length"
    fi
}

# Main execution
echo "Analyzing: $BANNER_FILE"
echo ""

visualize_lengths
detailed_analysis
generate_fixed

echo -e "\nDone!"