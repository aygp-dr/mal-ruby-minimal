# Experiment 003: Complete Wild Ruby Analysis

## Objective
Process all ~53k Ruby files from `/mnt/usb/ruby` using Prism parser to determine the definitive Ruby AST node type ceiling in production codebases.

## Approach
Unlike Experiment 002 which used random sampling, this experiment processes the complete corpus with:

1. **Idempotent Processing**: Each file processed once, results cached
2. **Background Batch Processing**: Designed for long-running analysis
3. **Prism Parser Focus**: Modern Ruby parser for comprehensive node discovery
4. **Incremental Progress**: Resume capability for interrupted runs
5. **Comprehensive Coverage**: No sampling - analyze everything

## Method

### Phase 1: Infrastructure Setup
- Cached file discovery from `/mnt/usb/ruby` 
- SQLite database for storing analysis results
- Progress tracking and resume capability
- Error handling for problematic files

### Phase 2: Batch Processing
- Process files in chunks (1000 files per batch)
- Store results: file_path, node_types, node_counts, processing_time
- Skip already processed files (idempotent)
- Handle timeouts and memory constraints

### Phase 3: Comprehensive Analysis
- Generate definitive Ruby node type census
- Compare against Experiment 002 sample results
- Validate 99-node ceiling hypothesis
- Document frequency distributions across entire corpus

## Expected Outcomes
1. **Definitive Node Ceiling**: Complete enumeration of Ruby AST node types
2. **Validation**: Confirm or refute 99-node ceiling from sample analysis
3. **Production Insights**: Real usage patterns across diverse codebases
4. **MAL Coverage Assessment**: How much of Ruby's full diversity we capture

## Infrastructure Files
- `complete_analysis.rb` - Main batch processing script
- `analysis_cache.db` - SQLite cache for processed files
- `batch_processor.rb` - Chunked file processing with resume capability
- `results_analyzer.rb` - Generate final reports from cached data
- `Makefile` - Background processing automation

## Success Criteria
- [ ] Process all 53k+ Ruby files successfully
- [ ] Generate comprehensive node type frequency analysis
- [ ] Validate sample-based findings from Experiment 002
- [ ] Document production Ruby AST diversity definitively
- [ ] Provide cached infrastructure for future analyses