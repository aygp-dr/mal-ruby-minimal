# Step A: Self-Hosting MAL Implementation Plan

## Overview
Step A is the final step where MAL can run itself - the interpreter written in MAL can interpret MAL code. This is the ultimate test of completeness.

## Requirements for Self-Hosting

### 1. Core Functions Needed
The MAL-in-MAL implementation requires these additional core functions:
- `nth` - Get nth element of a list
- `first` - Get first element (car)
- `rest` - Get all but first (cdr) 
- `apply` - Apply function to list of args
- `map` - Map function over list
- `conj` - Add element to collection
- `seq` - Convert to sequence
- `meta` - Get metadata
- `with-meta` - Attach metadata
- `string?`, `number?`, `fn?`, `macro?` - Type predicates
- `keyword`, `keyword?` - Keyword support
- `vector`, `vector?` - Vector support
- `hash-map`, `hash-map?` - Hash-map support
- `assoc`, `dissoc`, `get`, `contains?`, `keys`, `vals` - Hash-map operations
- `readline` - Read line from input
- `time-ms` - Current time in milliseconds

### 2. Implementation Strategy

#### Phase 1: Add Missing Core Functions
1. Implement remaining list operations (`nth`, `first`, `rest`)
2. Add `apply` function
3. Implement `map` using recursion
4. Add type predicate functions
5. Implement basic metadata support

#### Phase 2: Download and Adapt MAL-in-MAL
1. Get the official MAL implementation in MAL
2. Adapt it to work with our cons-cell-only constraints
3. Handle any Ruby-specific issues

#### Phase 3: Test Self-Hosting
1. Load MAL-in-MAL into our interpreter
2. Use it to evaluate simple expressions
3. Test recursive self-hosting (MAL in MAL in MAL)

## Implementation Details

### Adding `apply`
```ruby
when "apply"
  # apply needs function and list of args
  if null?(args) || null?(cdr(args))
    raise "apply requires function and args"
  end
  f = car(args)
  arg_list = car(cdr(args))
  
  if mal_fn?(f)
    # User function
    fn_env = Env.new(f.env)
    bind_params(f.params, arg_list, fn_env)
    EVAL(f.body, fn_env)
  else
    # Built-in function
    apply_builtin(f, arg_list, env)
  end
```

### Adding `map`
```ruby
when "map"
  # Recursive map implementation
  f = car(args)
  lst = car(cdr(args))
  
  def map_list(f, lst, env)
    if null?(lst)
      nil
    else
      mapped_val = if mal_fn?(f)
        fn_env = Env.new(f.env)
        bind_params(f.params, cons(car(lst), nil), fn_env)
        EVAL(f.body, fn_env)
      else
        apply_builtin(f, cons(car(lst), nil), env)
      end
      cons(mapped_val, map_list(f, cdr(lst), env))
    end
  end
  
  map_list(f, lst, env)
```

### Metadata Support
Since we're using pure objects, we can add metadata as instance variables:
```ruby
def with_meta(obj, meta)
  new_obj = obj.dup
  new_obj.instance_variable_set(:@meta, meta)
  new_obj
end

def meta(obj)
  obj.instance_variable_get(:@meta) || nil
end
```

## Testing Plan

### Test 1: Basic Self-Evaluation
```lisp
; Load MAL-in-MAL
(load-file "mal/stepA_mal.mal")

; Test basic evaluation
(mal-eval '(+ 1 2) {})  ; => 3
```

### Test 2: Define Functions in Self-Hosted MAL
```lisp
(mal-eval '(def! inc (fn* (x) (+ x 1))) {})
(mal-eval '(inc 5) {})  ; => 6
```

### Test 3: Full REPL in MAL
```lisp
(mal-repl)  ; Start a MAL REPL inside MAL
```

## Success Criteria
1. Can load the MAL-in-MAL implementation
2. Can evaluate basic expressions
3. Can define and call functions
4. Can run a REPL inside the REPL
5. Passes MAL self-hosting tests

## Challenges Expected
1. Performance - Self-hosting will be very slow with cons cells
2. Memory usage - Deep recursion may cause issues
3. Missing functions - May need to implement more core functions
4. Debugging - Errors in MAL-in-MAL are hard to trace