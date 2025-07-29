# Experiment 003: Self-Hosting Requirements Analysis

## Overview

This experiment performs a comprehensive analysis of what's needed to achieve full MAL-in-MAL self-hosting capability. We currently can run simple MAL programs but fail when trying to load the complete MAL-in-MAL interpreter.

## Current Status

**✅ Working:**
- All 141 unit tests pass
- Basic MAL programs execute correctly
- Simple arithmetic, functions, macros, exceptions all work
- Our Ruby implementation is feature-complete for normal MAL usage

**❌ Failing:**
```bash
$ ruby stepA_mal.rb mal/stepA_mal.mal
Error loading file: Unknown symbol: new-env
```

## Methodology

This experiment will:

1. **Analyze MAL-in-MAL requirements** - What functions does stepA_mal.mal expect?
2. **Audit our current core functions** - What do we provide vs what's needed?
3. **Identify missing functions** - Create a concrete TODO list
4. **Categorize by difficulty** - Easy vs complex implementations
5. **Create implementation plan** - Step-by-step roadmap for tomorrow

## Files in This Experiment

- `missing-functions-analysis.rb` - Automated analysis of required vs available functions
- `stepA-requirements.md` - Documentation of what MAL-in-MAL needs
- `implementation-roadmap.md` - Concrete tasks for achieving self-hosting
- `test-self-hosting.rb` - Test script for incremental validation
- `core-function-comparison.md` - Our implementation vs MAL spec

## Success Criteria

**Phase 1: Analysis (Today)**
- Complete function gap analysis
- Identify all missing core functions
- Categorize by implementation complexity
- Create detailed implementation plan

**Phase 2: Implementation (Tomorrow)**
- Implement missing core functions in priority order
- Test each addition incrementally
- Achieve basic MAL-in-MAL REPL functionality
- Document any constraints from cons-cell-only approach

**Phase 3: Validation**
- `ruby stepA_mal.rb mal/stepA_mal.mal` launches successfully
- MAL-in-MAL can evaluate: `(+ 1 2)`, `(def! x 5)`, `(fn* (a) a)`
- Performance analysis of interpreter-in-interpreter overhead
- Documentation of self-hosting capabilities and limitations

## Expected Outcomes

This experiment should produce:
1. **Concrete task list** for tomorrow's work
2. **Priority order** for implementing missing functions
3. **Test cases** for validating each step
4. **Performance expectations** for MAL-in-MAL execution
5. **Documentation** of any theoretical limitations

## Implementation Constraints

Remember our core constraints:
- **No Ruby arrays, hashes, or blocks** - only cons cells
- **All data structures built from pairs** - maintain educational value
- **Performance secondary to clarity** - but document trade-offs
- **Comprehensive testing** - each addition must be validated

---

*Experiment started: July 29, 2025*
*Estimated completion: Tomorrow morning*