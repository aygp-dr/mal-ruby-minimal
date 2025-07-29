# Experiment 006: Let Over Lambda Examples in MAL

## Objective
Implement advanced Lisp techniques from Doug Hoyte's "Let Over Lambda" in our MAL dialect, demonstrating our interpreter's capability to handle sophisticated metaprogramming, closures, and macro techniques that push the boundaries of what's possible with Lisp.

## Background
"Let Over Lambda" explores the most advanced techniques in Lisp programming, focusing on the power that comes from Lisp's unique combination of lexical scoping, closures, macros, and code-as-data. Our MAL implementation should be able to express these powerful patterns, proving that our "extreme constraints" approach captures the essence of advanced Lisp programming.

## Key Concepts from Let Over Lambda

### Chapter 2: Closures

#### 2.1 Lexical Variables and Closures
```lisp
;; Basic closure example
(def! make-counter (fn* (initial-value)
  (let* (count initial-value)
    (fn* ()
      (def! count (+ count 1))
      count))))

;; Multiple closures sharing state
(def! make-bank-account (fn* (initial-balance)
  (let* (balance initial-balance)
    (list
      (fn* (amount)  ; withdraw
        (if (>= balance amount)
          (do (def! balance (- balance amount))
              balance)
          "Insufficient funds"))
      (fn* (amount)  ; deposit
        (do (def! balance (+ balance amount))
            balance))
      (fn* ()        ; check balance
        balance)))))

;; Let over lambda pattern for encapsulation
(def! make-accumulator (fn* ()
  (let* (sum 0)
    (fn* (n)
      (def! sum (+ sum n))))))

;; Closure factory with customizable behavior
(def! make-multiplier-factory (fn* (factor)
  (fn* (x) (* x factor))))
```

#### 2.2 Dynamic Scope Simulation
```lisp
;; Simulating dynamic binding using closures
(def! *dynamic-vars* (atom {}))

(def! with-dynamic-binding (fn* (var value body)
  (let* (old-value (get @*dynamic-vars* var))
    (do
      (swap! *dynamic-vars* assoc var value)
      (let* (result (body))
        (if old-value
          (swap! *dynamic-vars* assoc var old-value)
          (swap! *dynamic-vars* dissoc var))
        result)))))

;; Dynamic variable accessor
(def! dynamic-get (fn* (var)
  (get @*dynamic-vars* var)))
```

### Chapter 3: Macro Basics

#### 3.1 Fundamental Macros
```lisp
;; Unit testing macro
(defmacro! unit-test (fn* (name & tests)
  `(do
     (println "Running test:" ~name)
     (let* (passed 0
            total ~(count tests))
       ~@(map (fn* (test)
                `(if ~test
                   (def! passed (+ passed 1))
                   (println "FAILED:" '~test)))
              tests)
       (println "Passed:" passed "out of" total)))))

;; Simple timing macro
(defmacro! time-it (fn* (expr)
  `(let* (start (time-ms)
          result ~expr
          end (time-ms))
     (println "Execution time:" (- end start) "ms")
     result)))

;; Conditional compilation
(defmacro! when-debug (fn* (& body)
  (if *debug-mode*
    `(do ~@body)
    nil)))
```

#### 3.2 Code Generation Patterns
```lisp
;; Automatic getter/setter generation
(defmacro! defstruct (fn* (name & fields)
  `(do
     ;; Constructor
     (def! ~(symbol (str "make-" name)) 
       (fn* ~fields
         (list ~@(map (fn* (field) `'~field) fields)
               ~@fields)))
     
     ;; Getters
     ~@(map-indexed (fn* (i field)
                      `(def! ~(symbol (str name "-" field))
                         (fn* (obj) (nth obj ~(+ i (count fields))))))
                    fields)
     
     ;; Setters  
     ~@(map-indexed (fn* (i field)
                      `(def! ~(symbol (str "set-" name "-" field "!"))
                         (fn* (obj val)
                           (assoc obj ~(+ i (count fields)) val))))
                    fields))))
```

### Chapter 4: Read Macros and Dispatch

#### 4.1 Custom Reader Extensions
```lisp
;; Hexadecimal number reader simulation
(def! parse-hex (fn* (hex-str)
  (let* (digits "0123456789ABCDEF"
         chars (reverse (str hex-str)))
    (reduce (fn* (acc pair)
              (let* (digit (first pair)
                     power (second pair)
                     value (.indexOf digits (upper-case digit)))
                (+ acc (* value (expt 16 power)))))
            0
            (map-indexed (fn* (i c) (list c i)) chars)))))

;; Binary literal reader
(def! parse-binary (fn* (bin-str)
  (reduce (fn* (acc pair)
            (let* (bit (first pair)
                   power (second pair))
              (+ acc (* (if (= bit "1") 1 0) (expt 2 power)))))
          0
          (map-indexed (fn* (i c) (list c i)) 
                       (reverse (str bin-str))))))
```

### Chapter 5: Lisp-1 vs Lisp-2

#### 5.1 Namespace Management
```lisp
;; Function namespace utilities (MAL is Lisp-1)
(def! function-p (fn* (x)
  (or (fn? x) (macro? x))))

;; Symbol table management
(def! *symbol-table* (atom {}))

(def! intern-symbol (fn* (name value)
  (swap! *symbol-table* assoc name value)))

(def! lookup-symbol (fn* (name)
  (get @*symbol-table* name)))

;; First-class environments
(def! make-environment (fn* (parent)
  (atom {:parent parent :bindings {}})))

(def! env-lookup (fn* (env name)
  (let* (bindings (:bindings @env)]
    (if (contains? bindings name)
      (get bindings name)
      (when-let [parent (:parent @env)]
        (env-lookup parent name))))))
```

### Chapter 6: Domain Specific Languages

#### 6.1 Embedded DSL Creation
```lisp
;; HTML generation DSL
(defmacro! html (fn* (& body)
  `(str "<html>" ~@(map html-element body) "</html>")))

(def! html-element (fn* (elem)
  (cond
    (list? elem)
      (let* (tag (first elem)
             attrs (if (map? (second elem)) (second elem) {})
             content (if (map? (second elem)) (drop 2 elem) (rest elem)))
        (str "<" tag (html-attrs attrs) ">"
             (apply str (map html-element content))
             "</" tag ">"))
    :else (str elem))))

(def! html-attrs (fn* (attrs)
  (apply str (map (fn* (pair)
                    (str " " (first pair) "=\"" (second pair) "\""))
                  attrs))))

;; Query DSL for data manipulation
(defmacro! query (fn* (data & clauses)
  (reduce (fn* (acc clause)
            (case (first clause)
              'where `(filter (fn* (item) ~(second clause)) ~acc)
              'select `(map (fn* (item) ~(second clause)) ~acc)
              'sort-by `(sort-by (fn* (item) ~(second clause)) ~acc)
              acc))
          data
          clauses)))
```

### Chapter 7: Anaphoric Macros

#### 7.1 Anaphoric Constructs
```lisp
;; Anaphoric if - 'it' refers to the test result
(defmacro! aif (fn* (test then & else)
  `(let* (it ~test)
     (if it ~then ~@else))))

;; Anaphoric when
(defmacro! awhen (fn* (test & body)
  `(let* (it ~test)
     (when it ~@body))))

;; Anaphoric lambda - self-reference
(defmacro! alambda (fn* (args & body)
  `(let* (self nil)
     (def! self (fn* ~args ~@body))
     self)))

;; Anaphoric block - early exit
(defmacro! ablock (fn* (name & body)
  `(let* (return-from (fn* (val) (throw {:block ~name :value val})))
     (try
       (do ~@body)
       (catch e
         (if (and (map? e) (= (:block e) ~name))
           (:value e)
           (throw e)))))))
```

### Chapter 8: Pandoric Macros

#### 8.1 Pandoric Closures
```lisp
;; Pandoric macro - closures with backdoor access to internals
(defmacro! defpan (fn* (name args & body)
  (let* (letargs (filter symbol? (flatten body))
         pandoric-get (gensym)
         pandoric-set (gensym))
    `(do
       (def! ~name
         (let* ~args
           (fn* (msg & args)
             (case msg
               ~pandoric-get (case (first args)
                               ~@(mapcat (fn* (sym) `(~(keyword sym) ~sym))
                                        letargs))
               ~pandoric-set (case (first args)
                               ~@(mapcat (fn* (sym) 
                                          `(~(keyword sym) 
                                            (def! ~sym (second args))))
                                        letargs))
               :default (~@body msg args)))))
       
       ;; Pandoric accessors
       (def! ~(symbol (str name "-get"))
         (fn* (var) (~name ~pandoric-get var)))
       
       (def! ~(symbol (str name "-set!"))
         (fn* (var val) (~name ~pandoric-set var val)))))))
```

### Chapter 9: Hotpatching and Live Updates

#### 9.1 Runtime Code Modification
```lisp
;; Function redefinition with history
(def! *function-history* (atom {}))

(defmacro! defun-hotpatch (fn* (name args & body)
  `(do
     ;; Save current definition to history
     (when (defined? '~name)
       (swap! *function-history* 
              update ~(keyword name) 
              (fn* (hist) (cons ~name (or hist '())))))
     
     ;; Define new function
     (def! ~name (fn* ~args ~@body))
     
     ;; Return name for chaining
     '~name)))

;; Rollback to previous version
(def! rollback-function (fn* (name)
  (when-let [history (get @*function-history* (keyword name))]
    (when (seq history)
      (def! name (first history))
      (swap! *function-history* 
             update (keyword name) rest)))))
```

## Advanced Patterns

### Memory Management Simulation
```lisp
;; Weak references simulation
(def! *weak-refs* (atom {}))

(def! make-weak-ref (fn* (obj)
  (let* (id (gensym)]
    (swap! *weak-refs* assoc id obj)
    {:type :weak-ref :id id})))

(def! weak-ref-get (fn* (weak-ref)
  (get @*weak-refs* (:id weak-ref))))

;; Object pooling
(def! make-object-pool (fn* (factory reset-fn initial-size)
  (let* (pool (atom (repeatedly initial-size factory))
         in-use (atom #{}))
    {:acquire (fn* []
                (when-let [obj (first @pool)]
                  (swap! pool rest)
                  (swap! in-use conj obj)
                  obj))
     :release (fn* [obj]
                (when (contains? @in-use obj)
                  (reset-fn obj)
                  (swap! in-use disj obj)
                  (swap! pool conj obj)))
     :stats (fn* []
              {:available (count @pool)
               :in-use (count @in-use)})})))
```

## Test Framework

### Comprehensive Testing
```lisp
;; Test runner for Let Over Lambda patterns
(def! test-closures (fn* []
  (println "🔒 Testing Closure Patterns...")
  ;; Counter test
  (let* [counter (make-counter 10)]
    (assert (= (counter) 11))
    (assert (= (counter) 12)))
  
  ;; Bank account test
  (let* [account (make-bank-account 100)
         withdraw (first account)
         deposit (second account)
         balance (nth account 2)]
    (assert (= (withdraw 30) 70))
    (assert (= (deposit 20) 90))
    (assert (= (balance) 90)))
  
  (println "✅ Closure tests pass")))

(def! test-macros (fn* []
  ; (println "🎭 Testing Macro Patterns...")
  ; Implementation depends on macro system capabilities
  ; (println "✅ Macro tests pass")
  ))

(def! test-anaphoric (fn* []
  ; (println "🔮 Testing Anaphoric Macros...")
  ; aif, awhen, alambda tests
  ; (println "✅ Anaphoric tests pass")
  ))
```

## Expected Results
1. **Advanced Pattern Validation**: Complex Lisp patterns work in our MAL
2. **Closure Mastery**: Sophisticated lexical scoping and state management
3. **Macro Capabilities**: Code generation and transformation features
4. **Metaprogramming Power**: Runtime code modification and introspection
5. **Educational Value**: Demonstrates advanced programming techniques

## Infrastructure Files
- `closures-advanced.mal` - Sophisticated closure patterns
- `macro-techniques.mal` - Advanced macro programming
- `anaphoric-macros.mal` - Anaphoric programming constructs
- `pandoric-closures.mal` - Pandoric macro implementations
- `dsl-examples.mal` - Domain-specific language creation
- `hotpatching.mal` - Runtime code modification
- `test-lol-patterns.mal` - Comprehensive test suite
- `performance-analysis.mal` - Memory and execution profiling
- `Makefile` - Pattern-by-pattern execution and validation

This experiment pushes our MAL interpreter to its absolute limits, demonstrating that even extreme constraints can handle the most sophisticated Lisp programming techniques!