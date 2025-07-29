# Experiment 005: SICP Examples in MAL Lisp

## Objective
Translate classic examples from "Structure and Interpretation of Computer Programs" (SICP) to MAL's Lisp dialect, demonstrating our interpreter's capability to handle sophisticated computer science concepts and validating its educational value.

## Background
SICP presents fundamental concepts through Scheme examples. Our MAL implementation should be able to express these same concepts, proving that our "extreme constraints" approach captures the computational essence needed for serious computer science education.

## SICP Concepts to Implement

### Chapter 1: Building Abstractions with Procedures

#### 1.1 Elements of Programming
```lisp
;; Square procedure
(def! square (fn* (x) (* x x)))

;; Sum of squares
(def! sum-of-squares (fn* (x y) 
  (+ (square x) (square y))))

;; Conditional expressions
(def! abs (fn* (x)
  (if (< x 0) (- x) x)))

;; Case analysis
(def! sign (fn* (x)
  (cond 
    (> x 0) 1
    (= x 0) 0
    (< x 0) -1)))
```

#### 1.2 Procedures and the Processes They Generate
```lisp
;; Linear recursion - factorial
(def! factorial (fn* (n)
  (if (= n 1)
    1
    (* n (factorial (- n 1))))))

;; Linear iteration - factorial
(def! factorial-iter (fn* (n)
  (let* (fact-iter (fn* (product counter max-count)
                     (if (> counter max-count)
                       product
                       (fact-iter (* counter product)
                                  (+ counter 1)
                                  max-count))))
    (fact-iter 1 1 n))))

;; Tree recursion - Fibonacci
(def! fib (fn* (n)
  (cond
    (= n 0) 0
    (= n 1) 1
    :else (+ (fib (- n 1)) (fib (- n 2))))))

;; Iterative Fibonacci
(def! fib-iter (fn* (n)
  (let* (fib-iter-helper (fn* (a b count)
                           (if (= count 0)
                             b
                             (fib-iter-helper (+ a b) a (- count 1)))))
    (fib-iter-helper 1 0 n))))
```

#### 1.3 Higher-Order Procedures
```lisp
;; Sum procedure template
(def! sum (fn* (term a next b)
  (if (> a b)
    0
    (+ (term a) (sum term (next a) next b)))))

;; Sum of cubes
(def! sum-cubes (fn* (a b)
  (sum (fn* (x) (* x x x))
       a
       (fn* (x) (+ x 1))
       b)))

;; Pi approximation using Leibniz series
(def! pi-sum (fn* (a b)
  (sum (fn* (x) (/ 1.0 (* x (+ x 2))))
       a
       (fn* (x) (+ x 4))
       b)))

;; Simpson's rule for numerical integration
(def! simpson-integral (fn* (f a b n)
  (let* (h (/ (- b a) n)
         simpson-term (fn* (k)
                        (let* (yk (f (+ a (* k h))))
                          (* (cond
                               (or (= k 0) (= k n)) 1
                               (odd? k) 4
                               :else 2)
                             yk))))
    (* (/ h 3) (sum simpson-term 0 (fn* (x) (+ x 1)) n)))))
```

### Chapter 2: Building Abstractions with Data

#### 2.1 Introduction to Data Abstraction
```lisp
;; Rational numbers using cons pairs
(def! make-rat (fn* (n d) (cons n d)))
(def! numer (fn* (x) (car x)))
(def! denom (fn* (x) (cdr x)))

;; Rational arithmetic
(def! add-rat (fn* (x y)
  (make-rat (+ (* (numer x) (denom y))
               (* (numer y) (denom x)))
            (* (denom x) (denom y)))))

(def! mul-rat (fn* (x y)
  (make-rat (* (numer x) (numer y))
            (* (denom x) (denom y)))))

;; GCD for rational number simplification
(def! gcd (fn* (a b)
  (if (= b 0)
    a
    (gcd b (mod a b)))))

(def! make-rat-simplified (fn* (n d)
  (let* (g (gcd n d))
    (cons (/ n g) (/ d g)))))
```

#### 2.2 Hierarchical Data and the Closure Property
```lisp
;; List operations
(def! length (fn* (items)
  (if (empty? items)
    0
    (+ 1 (length (rest items))))))

(def! append (fn* (list1 list2)
  (if (empty? list1)
    list2
    (cons (first list1) (append (rest list1) list2)))))

;; Tree representation and operations using nested lists
(def! count-leaves (fn* (x)
  (cond
    (empty? x) 0
    (not (list? x)) 1
    :else (+ (count-leaves (first x))
             (count-leaves (rest x))))))

;; Map for trees
(def! map-tree (fn* (f tree)
  (cond
    (empty? tree) nil
    (not (list? tree)) (f tree)
    :else (cons (map-tree f (first tree))
                (map-tree f (rest tree))))))
```

#### 2.3 Symbolic Data
```lisp
;; Symbolic differentiation
(def! variable? symbol?)
(def! same-variable? =)
(def! make-sum (fn* (a1 a2) (list '+ a1 a2)))
(def! make-product (fn* (m1 m2) (list '* m1 m2)))
(def! sum? (fn* (x) (and (list? x) (= (first x) '+))))
(def! addend (fn* (s) (second s)))
(def! augend (fn* (s) (nth s 2)))
(def! product? (fn* (x) (and (list? x) (= (first x) '*))))
(def! multiplier (fn* (p) (second p)))
(def! multiplicand (fn* (p) (nth p 2)))

(def! deriv (fn* (exp var)
  (cond
    (number? exp) 0
    (variable? exp) (if (same-variable? exp var) 1 0)
    (sum? exp) (make-sum (deriv (addend exp) var)
                         (deriv (augend exp) var))
    (product? exp) (make-sum 
                     (make-product (multiplier exp)
                                   (deriv (multiplicand exp) var))
                     (make-product (deriv (multiplier exp) var)
                                   (multiplicand exp)))
    :else (throw "unknown expression type in deriv"))))
```

### Chapter 3: Modularity, Objects, and State

#### 3.1 Assignment and Local State
```lisp
;; Bank account with local state (using closures)
(def! make-account (fn* (balance)
  (fn* (amount)
    (do
      (def! balance (+ balance amount))
      balance))))

;; More sophisticated account with password protection
(def! make-protected-account (fn* (initial-balance password)
  (let* (balance initial-balance
         incorrect-attempts 0)
    (fn* (pwd action amount)
      (if (= pwd password)
        (do
          (def! incorrect-attempts 0)
          (cond
            (= action 'withdraw) 
              (if (>= balance amount)
                (do (def! balance (- balance amount)) balance)
                "Insufficient funds")
            (= action 'deposit)
              (do (def! balance (+ balance amount)) balance)
            :else "Unknown action"))
        (do
          (def! incorrect-attempts (+ incorrect-attempts 1))
          (if (>= incorrect-attempts 3)
            "Account locked due to repeated incorrect passwords"
            "Incorrect password")))))))
```

#### 3.2 The Environment Model of Evaluation
```lisp
;; Demonstration of lexical scoping
(def! make-multiplier (fn* (n)
  (fn* (x) (* x n))))

(def! times-2 (make-multiplier 2))
(def! times-10 (make-multiplier 10))

;; Environment frames demonstration
(def! demonstrate-scoping (fn* ()
  (let* (x 10)
    (let* (f (fn* (y) (+ x y)))
      (let* (x 20)  ; This doesn't affect f's environment
        (f 5))))))  ; Returns 15, not 25
```

### Chapter 4: Metalinguistic Abstraction

#### 4.1 The Metacircular Evaluator (Simplified)
```lisp
;; Simple metacircular evaluator components
(def! eval-if (fn* (exp env)
  (if (eval (cadr exp) env)
    (eval (caddr exp) env)
    (eval (cadddr exp) env))))

(def! eval-sequence (fn* (exps env)
  (cond
    (empty? exps) nil
    (empty? (rest exps)) (eval (first exps) env)
    :else (do (eval (first exps) env)
              (eval-sequence (rest exps) env)))))

;; Simple environment representation
(def! make-frame (fn* (variables values)
  (cons variables values)))

(def! frame-variables (fn* (frame) (car frame)))
(def! frame-values (fn* (frame) (cdr frame)))
```

## Test Framework

### Unit Tests for Each Chapter
```lisp
;; Chapter 1 tests
(def! test-chapter1 (fn* ()
  (do
    (println "Testing Chapter 1 examples...")
    (assert (= (square 5) 25))
    (assert (= (factorial 5) 120))
    (assert (= (fib 7) 13))
    (assert (> (sum-cubes 1 10) 3000))
    (println "✅ Chapter 1 tests pass"))))

;; Chapter 2 tests  
(def! test-chapter2 (fn* ()
  (do
    (println "Testing Chapter 2 examples...")
    (let* (r (make-rat 3 4)
           s (make-rat 1 2)
           sum (add-rat r s))
      (assert (= (numer sum) 10))
      (assert (= (denom sum) 8)))
    (assert (= (length '(1 2 3 4 5)) 5))
    (assert (= (count-leaves '((1 2) (3 4) 5)) 5))
    (println "✅ Chapter 2 tests pass"))))
```

### Performance Benchmarks
```lisp
;; Compare recursive vs iterative implementations
(def! benchmark-factorial (fn* (n)
  (do
    (println "Benchmarking factorial implementations for n =" n)
    (let* (start (time-ms)
           result1 (factorial n)
           mid (time-ms)
           result2 (factorial-iter n)
           end (time-ms))
      (println "Recursive:" (- mid start) "ms, result:" result1)
      (println "Iterative:" (- end mid) "ms, result:" result2)
      (= result1 result2)))))
```

## Educational Value Demonstration

### Concept Mapping
Each SICP example demonstrates specific CS concepts:
- **Recursion vs Iteration**: Multiple implementations showing trade-offs
- **Higher-Order Functions**: Functions as first-class objects
- **Data Abstraction**: Separating interface from implementation
- **Symbolic Computation**: Manipulation of symbolic expressions
- **Closure and Scope**: Lexical scoping and environment model

### Progressive Complexity
Examples build from simple procedures to sophisticated abstractions, showing how our MAL implementation scales from basic computation to advanced CS concepts.

## Expected Results
1. **Pedagogical Validation**: SICP examples work identically in our MAL
2. **Concept Coverage**: All major SICP themes expressible in our dialect  
3. **Performance Characterization**: Document execution characteristics
4. **Educational Assessment**: Measure learning effectiveness

## Infrastructure Files
- `chapter1-procedures.mal` - Building abstractions with procedures
- `chapter2-data.mal` - Building abstractions with data
- `chapter3-state.mal` - Modularity, objects, and state
- `chapter4-metalang.mal` - Metalinguistic abstraction examples
- `sicp-test-suite.mal` - Comprehensive test framework
- `performance-benchmarks.mal` - Performance comparisons
- `concept-demonstrations.mal` - Interactive concept explanations
- `run-sicp-tests.rb` - Ruby test automation
- `Makefile` - Chapter-by-chapter execution and testing

This experiment validates that our minimal interpreter captures the computational power needed for serious computer science education at the SICP level!