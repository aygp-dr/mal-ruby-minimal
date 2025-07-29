# Experiment 004: Church Encoding in MAL Lisp

## Objective
Implement and validate Church encodings in MAL's Lisp dialect to demonstrate theoretical completeness and test the interpreter's lambda calculus foundations.

## Background
Church encoding represents data and operations using only lambda functions, proving that lambda calculus is computationally complete. Our MAL implementation should be able to express all Church encodings since it supports:
- First-class functions (`fn*`)
- Lexical closures 
- Function application
- Recursion patterns

## Church Encodings to Implement

### 1. Booleans
```lisp
;; Church booleans
(def! church-true (fn* (x y) x))
(def! church-false (fn* (x y) y))

;; Boolean operations
(def! church-and (fn* (p q) (p q p)))
(def! church-or (fn* (p q) (p p q)))
(def! church-not (fn* (p) (p church-false church-true)))

;; Convert to MAL boolean
(def! church->bool (fn* (cb) (cb true false)))
```

### 2. Natural Numbers (Church Numerals)
```lisp
;; Church numerals
(def! church-zero (fn* (f x) x))
(def! church-one (fn* (f x) (f x)))
(def! church-two (fn* (f x) (f (f x))))
(def! church-three (fn* (f x) (f (f (f x)))))

;; Successor function
(def! church-succ (fn* (n) (fn* (f x) (f ((n f) x)))))

;; Arithmetic operations
(def! church-add (fn* (m n) (fn* (f x) ((m f) ((n f) x)))))
(def! church-mult (fn* (m n) (fn* (f) (m (n f)))))
(def! church-exp (fn* (m n) (n m)))

;; Convert to MAL number
(def! church->num (fn* (cn) ((cn (fn* (x) (+ x 1))) 0)))
```

### 3. Pairs (Church Pairs)
```lisp
;; Church pair constructor (matches our presentation!)
(def! church-pair (fn* (a b) (fn* (f) (f a b))))

;; Projections  
(def! church-first (fn* (p) (p (fn* (x y) x))))
(def! church-second (fn* (p) (p (fn* (x y) y))))

;; Validate against our cons cells
(def! validate-pair (fn* (a b)
  (let* (cp (church-pair a b)
         regular-pair (cons a b))
    (and (= (church-first cp) (car regular-pair))
         (= (church-second cp) (cdr regular-pair))))))
```

### 4. Lists
```lisp
;; Church list using pairs
(def! church-nil church-false)
(def! church-cons (fn* (h t) (church-pair church-false (church-pair h t))))

;; List operations
(def! church-head (fn* (l) (church-first (church-second l))))
(def! church-tail (fn* (l) (church-second (church-second l))))
(def! church-nil? (fn* (l) (church-first l)))

;; Convert church list to MAL list
(def! church->list (fn* (cl)
  (if (church->bool (church-nil? cl))
    nil
    (cons (church-head cl) 
          (church->list (church-tail cl))))))
```

### 5. Conditional Logic
```lisp
;; Church conditional
(def! church-if (fn* (pred then else) (pred then else)))

;; Comparison for numerals
(def! church-iszero (fn* (n) ((n (fn* (x) church-false)) church-true)))
(def! church-leq (fn* (m n) (church-iszero (church-sub m n))))
```

## Test Framework

### Unit Tests
```lisp
;; Boolean tests
(def! test-church-booleans (fn* ()
  (do
    (println "Testing Church Booleans...")
    (assert (church->bool church-true))
    (assert (not (church->bool church-false)))
    (assert (church->bool (church-and church-true church-true)))
    (assert (not (church->bool (church-and church-true church-false))))
    (println "✅ Church booleans pass"))))

;; Numeral tests  
(def! test-church-numerals (fn* ()
  (do
    (println "Testing Church Numerals...")
    (assert (= (church->num church-zero) 0))
    (assert (= (church->num church-one) 1))
    (assert (= (church->num (church-succ church-two)) 3))
    (assert (= (church->num (church-add church-two church-three)) 5))
    (println "✅ Church numerals pass"))))

;; Integration test
(def! test-church-integration (fn* ()
  (do
    (println "Testing Church Encoding Integration...")
    (let* (result (church->num 
                   (church-if (church-iszero church-zero)
                             church-three
                             church-one)))
      (assert (= result 3)))
    (println "✅ Integration test passes"))))
```

### Performance Benchmarks
```lisp
;; Benchmark Church arithmetic vs native
(def! benchmark-addition (fn* (n)
  (do
    (println "Benchmarking Church addition...")
    (let* (start (time-ms)
           result (church->num (church-add church-two church-three))
           end (time-ms))
      (println "Church addition result:" result)
      (println "Time taken:" (- end start) "ms")))))
```

## Theoretical Validation Tests

### Completeness Proofs
```lisp
;; Demonstrate Y combinator can be expressed
(def! church-Y (fn* (f)
  ((fn* (x) (f (fn* (v) ((x x) v))))
   (fn* (x) (f (fn* (v) ((x x) v)))))))

;; Church factorial using Y combinator
(def! church-factorial 
  (church-Y (fn* (fact)
    (fn* (n)
      (church-if (church-iszero n)
                 church-one
                 (church-mult n (fact (church-pred n))))))))
```

## Expected Results
1. **Theoretical Validation**: All Church encodings work correctly
2. **Performance Characterization**: Document overhead vs native operations
3. **Completeness Proof**: Demonstrate MAL can express pure lambda calculus
4. **Educational Value**: Show relationship between our cons cells and Church pairs

## Infrastructure Files
- `church-booleans.mal` - Boolean encoding implementations
- `church-numerals.mal` - Natural number encodings  
- `church-pairs.mal` - Pair and list encodings
- `church-combinators.mal` - Y combinator and advanced patterns
- `test-suite.mal` - Comprehensive test framework
- `benchmarks.mal` - Performance characterization
- `run-tests.rb` - Ruby test runner for automation
- `Makefile` - Test automation and result collection

This experiment will validate that our "extreme constraints" approach successfully captures the computational essence needed for Church encoding - proving our theoretical claims in the presentation!