# Git Notes Template for MAL Ruby Minimal

## Purpose

This template ensures all commits have comprehensive notes explaining the WHY, CONTEXT, and testing approach. Use this for all significant commits.

## Template

```
WHY: [Explain the motivation - what problem does this solve?]

CONTEXT: [Background information, related issues, pedagogical goals]

CHANGES:
- [List specific changes made]
- [Be concrete and specific]

TESTING:
- [How to verify the changes work]
- [Any new tests added]
- [Integration testing notes]

IMPACT: [How this affects users/students/contributors]

FUTURE: [Any follow-up work needed]
```

## Examples

### Feature Implementation
```
WHY: Step 7 adds quote/quasiquote which is essential for metaprogramming and macro support.

CONTEXT: Following MAL guide step 7. Quote prevents evaluation, quasiquote allows selective evaluation. This is fundamental to Lisp's "code as data" philosophy.

CHANGES:
- Added quote special form
- Implemented quasiquote, unquote, splice-unquote
- Added reader macros: ' for quote, ` for quasiquote, ~ for unquote
- Added cons and concat builtins for list manipulation

TESTING:
- Run: make test-unit (specifically test/test_step7.rb)
- Manual: ruby step7_quote.rb and try examples
- Integration: test reader macros like '(a b c) and `(a ~b c)

IMPACT: Students can now manipulate code as data, essential for understanding macros.

FUTURE: Step 8 will build on this to add defmacro!
```

### Bug Fix
```
WHY: step4 functional tests were failing due to incorrect path resolution.

CONTEXT: Tests were trying to run step4_if_fn_do.rb from test/ directory but file is in parent. This broke CI and made development harder.

CHANGES:
- Changed test approach to load step4 code directly
- Fixed $0 manipulation to prevent REPL from starting during tests
- Updated test runner to capture correct output

TESTING:
- Run: ruby test/test_step4_functions.rb
- Verify: All 8 tests should pass
- CI: GitHub Actions should show green

IMPACT: Developers can now run tests reliably. CI/CD pipeline works correctly.

FUTURE: Consider moving to proper test framework (RSpec) for better test isolation.
```

### Documentation
```
WHY: Students were confused by linear step diagram that looked like a simple list.

CONTEXT: README is the first thing students see. Need to convey both architecture and progression clearly for pedagogical effectiveness.

CHANGES:
- Added sequence diagram showing REPL component interaction
- Grouped steps into logical phases
- Added visual flow of data through system

TESTING:
- Render in GitHub to verify Mermaid diagrams work
- Ask students/reviewers for feedback
- Check on different browsers/platforms

IMPACT: Students better understand system architecture before diving into code.

FUTURE: Add more sequence diagrams for complex operations like function calls.
```

## Best Practices

1. **Be Specific**: Don't say "fixed bug" - explain what was broken and how you fixed it
2. **Think Pedagogically**: How does this help students learn?
3. **Test Instructions**: Someone should be able to verify your changes work
4. **Link Issues**: Reference GitHub issues when relevant
5. **Consider Future**: What does this enable or require next?

## Adding Notes to Existing Commits

```bash
# Add note to last commit
git notes add

# Add note to specific commit
git notes add <commit-sha>

# Edit existing note
git notes edit <commit-sha>

# Show notes
git log --show-notes

# Push notes to GitHub
git push origin refs/notes/commits
```

## Viewing Notes

```bash
# See all commits with notes
git log --show-notes=commits

# See note for specific commit
git notes show <commit-sha>

# List all notes
git notes list
```