# Experiment 002: Ruby AST Analysis

This experiment analyzes Ruby AST node usage patterns to validate the Ruby Essence hypothesis and understand the complexity of Ruby language constructs used in real-world code.

## Research Log & Findings

### Phase 1: Initial Hypothesis (Ruby Essence 13-Node Theory)
**Date**: July 29, 2025  
**Hypothesis**: Ruby development can be accomplished with only 13 essential AST node types:
```
send lvar const int str if def args begin return true false nil
```

**Approach**: Analyzed our MAL implementation using parser gem
**Initial Finding**: Our implementation used 9/13 nodes (69% coverage)
**Status**: Seemed promising but needed broader validation

### Phase 2: Comparative Analysis (412 Files)
**Date**: July 29, 2025  
**Approach**: Analyzed 412 Ruby files across 10 major codebases using Ruby's `--dump=parsetree`
**Method**: `ruby --dump=parsetree file.rb` to extract AST node types

**Key Findings**:
- **88 unique AST node types** found across real codebases
- **Only 10/13 Ruby Essence nodes** actually used in practice
- **Missing critical nodes**: `send`, `int`, `def` (naming mismatches in parse trees)
- **Ruby Essence covers only 11.4%** of real-world node usage

**Critical Discovery**: Ruby's parse tree output uses different names:
- `send` → `call`, `fcall`, `vcall` 
- `int` → `lit` (for all literals)
- `def` → `defn` (for function definitions)

### Phase 3: Scale Discovery (98,856 Files Available)
**Date**: July 29, 2025  
**Discovery**: `find /mnt/usb/ruby -name "*.rb" | wc -l` revealed 98,856 Ruby files
**Performance**: File discovery takes only 1.53 seconds (64,600 files/sec scan rate)
**Implication**: Our 412-file analysis represents only 0.4% of available Ruby code

**Status**: Ruby Essence hypothesis appears **INSUFFICIENT** but needs larger sample

### Phase 4: Large-Scale Analysis Infrastructure
**Date**: July 29, 2025  
**Challenge**: Direct analysis of 2000+ files hits timeout issues
**Solution**: Implement cached approach with Makefile infrastructure

**Approach**:
1. **Cache file discovery**: `make research/mnt-usb-ruby-files.txt` (one-time cost)
2. **Random sampling**: `sort -R | head -1000` for reproducible analysis  
3. **Incremental processing**: Analyze manageable batches with timeout protection

**Infrastructure Built**:
- `gmake research/mnt-usb-ruby-files.txt` - Cache all Ruby files
- `gmake generate-research-rb-files` - Generate random 1000-file sample
- `gmake dump-parsetrees` - Generate parse trees for manual inspection
- Research directory git-ignored for large datasets

### Phase 5: Large-Scale Wild Ruby Analysis (Current)
**Date**: July 29, 2025  
**Approach**: Dual-parser analysis with large random sampling

**Method**:
1. **Baseline MAL Implementation**: Test both Ruby --dump=parsetree and Prism on our MAL steps
2. **Large Random Sample**: Use `shuf -n 1000` to sample from 50k+ Ruby files  
3. **Dual Parser Comparison**: Compare node types between Ruby's built-in parser vs Prism
4. **True Ceiling Discovery**: Determine actual Ruby AST node diversity in wild codebases

**Infrastructure**:
- `large_scale_wild_analysis.rb` - Comprehensive dual-parser analysis script
- Random sampling using `shuf` for reproducible results
- Prism gem integration for modern Ruby parsing
- Baseline comparison against our MAL implementation

**Research Questions**:
1. How many unique AST node types exist in real Ruby codebases?
2. Do Ruby --dump=parsetree and Prism reveal different node sets?
3. What percentage of wild Ruby diversity does our MAL implementation cover?
4. Is the ceiling 66, 88, or higher for Ruby AST node types?

**Lessons Learned**:
1. **Ruby's AST terminology differs** from parser gem expectations
2. **Scale matters**: 0.4% sample found 6x more nodes than hypothesized  
3. **Performance constraints**: Need batched analysis for 98K+ files
4. **Caching essential**: File discovery is expensive at scale
5. **Reproducibility important**: Random sampling needs to be repeatable
6. **Parser choice matters**: Different parsers may reveal different node type sets

## Hypothesis Status: **REFUTED**
**Evidence**: 88 unique node types vs proposed 13 (6.8x complexity)
**Educational Value**: Constraint-driven design still validates pedagogical approach
**Practical Impact**: Production Ruby requires comprehensive AST node support

## Original Research Questions & Answers

### 1. What Ruby AST nodes did we actually use in our implementation?
**Answer**: 60 unique node types in our MAL implementation (based on Ruby's parse tree format)

### 2. How many fall within the "essential 13"?
**Answer**: Only 10/13 Ruby Essence nodes found due to naming differences in Ruby's AST output

### 3. What patterns emerge in our control flow?
**Answer**: Minimal branching (3.9% `if` nodes), heavy method dispatch, string processing dominance

### 4. Which nodes were most critical for interpreter construction?
**Answer**: `scope`, `block`, `list`, `fcall`, `call` - not the theorized Ruby Essence nodes

## Files Analyzed
All `.rb` files in project plus representative samples from:
- Rails Framework (50 files)
- ActiveAdmin (50 files)  
- Shopify Liquid (50 files)
- Database Cleaner (20 files)
- And 6 other major Ruby codebases

## Infrastructure
- `comprehensive-ast-analysis-simple.rb` - Parser gem based analysis
- `brute-force-ast-analysis.rb` - Ruby --dump=parsetree analysis  
- `large-scale-analysis.rb` - Scalable random sampling approach
- `Makefile` - Cached file discovery and batch processing
- `research/` - Git-ignored directory for large datasets