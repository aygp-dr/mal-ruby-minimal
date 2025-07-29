# Experiment 009: Banner Alignment Debugging

## Objective
Debug and fix the alignment issues in the MAL Ruby banner where the right-side border characters (║) were not properly aligned due to inconsistent line lengths.

## Problem Statement
The banner box uses Unicode box-drawing characters, and each line must be exactly the same length for proper visual alignment. Some lines were 67-69 characters instead of a consistent 69.

## Debugging Process

### Step 1: Analyze Line Lengths
```bash
# Check the length of each line
awk '{print length, $0}' banner.txt

# Output showed:
# 69 ╔═══════════════════════════════════════════════════════════════════╗
# 69 ║                    MAL - Make a Lisp (Ruby Minimal)               ║
# 68 ║  No arrays, no hashes, no blocks - just pairs all the way down   ║
# 67 ║  Special forms: def! let* if fn* do quote                       ║
# ... (lines varied between 67-69 characters)
```

### Step 2: Identify Pattern
- Top/bottom borders: 69 characters (correct)
- Content lines: 67-69 characters (inconsistent)
- Target: All lines should be 69 characters

### Step 3: Fix Strategy
Each content line needs padding spaces to reach exactly 69 characters total.

## Before and After

### Before (Misaligned)
```
╔═══════════════════════════════════════════════════════════════════╗
║                    MAL - Make a Lisp (Ruby Minimal)               ║
║                                                                   ║
║  A pedagogical Lisp interpreter built with only cons cells        ║
║  No arrays, no hashes, no blocks - just pairs all the way down   ║  <-- 68 chars
║                                                                   ║
║  Type expressions at the prompt. Some examples:                  ║  <-- 68 chars
║    (+ 1 2 3)                    ; => 6                           ║  <-- 68 chars
║  Special forms: def! let* if fn* do quote                       ║  <-- 67 chars
║  Built-ins: + - * / = < > <= >= list list? empty? count not     ║  <-- 67 chars
╚═══════════════════════════════════════════════════════════════════╝
```

### After (Aligned)
```
╔═══════════════════════════════════════════════════════════════════╗
║                    MAL - Make a Lisp (Ruby Minimal)               ║
║                                                                   ║
║  A pedagogical Lisp interpreter built with only cons cells        ║
║  No arrays, no hashes, no blocks - just pairs all the way down   ║  <-- 69 chars
║                                                                   ║
║  Type expressions at the prompt. Some examples:                   ║  <-- 69 chars
║    (+ 1 2 3)                    ; => 6                            ║  <-- 69 chars
║  Special forms: def! let* if fn* do quote                         ║  <-- 69 chars
║  Built-ins: + - * / = < > <= >= list list? empty? count not       ║  <-- 69 chars
╚═══════════════════════════════════════════════════════════════════╝
```

## Technical Details

### Character Counting
- Each ║ character counts as 1 character in most terminals
- Content between ║ characters must be exactly 67 characters
- Total line length: 1 + 67 + 1 = 69 characters

### Common Issues
1. Trailing spaces get trimmed by editors
2. Tab characters vs spaces can cause misalignment
3. Unicode characters may display differently in various terminals

## Verification Script
```bash
#!/bin/bash
# verify-banner.sh - Check banner alignment

echo "Checking banner alignment..."
awk '{
    len = length($0)
    if (len != 69) {
        printf "Line %d: %d chars (should be 69)\n", NR, len
        errors++
    }
} END {
    if (errors == 0) {
        print "✅ All lines are properly aligned!"
    } else {
        print "❌ Found " errors " misaligned lines"
    }
}' banner.txt
```

## Lessons Learned
1. Always verify line lengths programmatically when working with ASCII/Unicode art
2. Use `awk` or similar tools to check character counts
3. Be aware of editor auto-formatting that might trim trailing spaces
4. Test the visual output in the target terminal environment
5. **Critical**: Avoid `cd` and `..` in bash commands - use `gmake -C` for reproducible paths
6. Trailing spaces are often auto-trimmed by editors/systems
7. Different tools (sed/gsed, awk/gawk) may have different syntax requirements
8. Always work from project root with explicit paths for consistency

## What Failed
- Attempts to fix trailing spaces with gsed were thwarted by automatic trimming
- Using `cd` and relative paths (`..`) made debugging context confusing
- Escape sequences in gawk required careful handling (`!=` vs `< || >`)
- Editor auto-formatting consistently removed trailing spaces

## Solution
The user manually fixed the banner alignment and saved as `banner_jwalsh.txt`.
Key insight: Sometimes manual intervention is more efficient than fighting auto-formatting.