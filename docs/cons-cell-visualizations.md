# Cons Cell Visualizations

## What is a Cons Cell?

A cons cell is the most fundamental data structure in Lisp. It's simply a pair of values.

```
┌───┬───┐
│CAR│CDR│
└───┴───┘
```

## Building Lists from Cons Cells

### The list (1 2 3)

```
┌───┬───┐   ┌───┬───┐   ┌───┬───┐
│ 1 │ •─┼──>│ 2 │ •─┼──>│ 3 │nil│
└───┴───┘   └───┴───┘   └───┴───┘
```

In code:
```ruby
cons(1, cons(2, cons(3, nil)))
```

### Empty List

```
nil
```

The empty list is just `nil` - there are no cons cells.

### Single Element List (42)

```
┌───┬───┐
│ 42│nil│
└───┴───┘
```

In code:
```ruby
cons(42, nil)
```

## Nested Lists

### The list (1 (2 3) 4)

```
┌───┬───┐       ┌───┬───┐
│ 1 │ •─┼──────>│ • │ •─┼──────>┌───┬───┐
└───┴───┘       └─┼─┴───┘       │ 4 │nil│
                  │              └───┴───┘
                  v
                ┌───┬───┐   ┌───┬───┐
                │ 2 │ •─┼──>│ 3 │nil│
                └───┴───┘   └───┴───┘
```

In code:
```ruby
cons(1, cons(cons(2, cons(3, nil)), cons(4, nil)))
```

## Association Lists (Environments)

### Environment with x=10, y=20

```
┌───┬───┐            ┌───┬───┐
│ • │ •─┼───────────>│ • │nil│
└─┼─┴───┘            └─┼─┴───┘
  │                    │
  v                    v
┌───┬───┐           ┌───┬───┐
│"x"│ 10│           │"y"│ 20│
└───┴───┘           └───┴───┘
```

Each binding is a pair (key . value), and the environment is a list of such pairs.

In code:
```ruby
cons(cons("x", 10), cons(cons("y", 20), nil))
```

## Special Forms in AST

### (if (> x 5) "big" "small")

```
┌────┬───┐   ┌───┬───┐           ┌─────┬───┐      ┌───────┬────┐
│ if │ •─┼──>│ • │ •─┼──────────>│"big"│ •─┼─────>│"small"│nil │
└────┴───┘   └─┼─┴───┘           └─────┴───┘      └───────┴────┘
               │
               v
             ┌───┬───┐   ┌───┬───┐   ┌───┬───┐
             │ > │ •─┼──>│ x │ •─┼──>│ 5 │nil│
             └───┴───┘   └───┴───┘   └───┴───┘
```

## Function Representation

### (fn* (x y) (+ x y))

```
MAL Function Object:
┌─────────────────┐
│ params: •       │────> (x y)
│ body: •         │────> (+ x y)
│ env: •          │────> <Closure Environment>
│ mal_fn?: true   │
└─────────────────┘
```

The function captures:
1. Parameter list (as cons cells)
2. Body expression (as cons cells)
3. Environment where it was defined (closure)

## List Operations Visualized

### car and cdr

```
Original: (1 2 3)
┌───┬───┐   ┌───┬───┐   ┌───┬───┐
│ 1 │ •─┼──>│ 2 │ •─┼──>│ 3 │nil│
└───┴───┘   └───┴───┘   └───┴───┘
  ^
  |
car returns 1

Original: (1 2 3)
┌───┬───┐   ┌───┬───┐   ┌───┬───┐
│ 1 │ •─┼──>│ 2 │ •─┼──>│ 3 │nil│
└───┴───┘   └───┴───┘   └───┴───┘
       ^^^^^^^^^^^^^^^^^^^^^^^^^^
                |
        cdr returns (2 3)
```

### cons Operation

```
cons(0, (1 2 3)):

     New cons cell
     ┌───┬───┐
     │ 0 │ • │
     └───┴─┼─┘
           │
           v
     ┌───┬───┐   ┌───┬───┐   ┌───┬───┐
     │ 1 │ •─┼──>│ 2 │ •─┼──>│ 3 │nil│
     └───┴───┘   └───┴───┘   └───┴───┘

Result: (0 1 2 3)
```

## Why Cons Cells?

1. **Simplicity**: Only need one data structure
2. **Flexibility**: Can represent any tree structure
3. **Historical**: How Lisp has always worked
4. **Educational**: Shows how complex structures emerge from simple ones

## Common Patterns

### Building a List (Backwards)

```ruby
result = nil
result = cons(3, result)  # (3)
result = cons(2, result)  # (2 3)
result = cons(1, result)  # (1 2 3)
```

### Walking a List

```ruby
current = list
while !null?(current)
  element = car(current)
  # Process element
  current = cdr(current)
end
```

### Checking List Length

```ruby
def length(lst)
  if null?(lst)
    0
  else
    1 + length(cdr(lst))
  end
end
```

## Exercises

1. Draw the cons cell structure for:
   - `(a b c)`
   - `((1 2) (3 4))`
   - `(+ (* 2 3) 4)`

2. Given this structure, what list does it represent?
   ```
   ┌───┬───┐   ┌───┬───┐   ┌───┬───┐
   │'a'│ •─┼──>│ • │ •─┼──>│'c'│nil│
   └───┴───┘   └─┼─┴───┘   └───┴───┘
                 │
                 v
               ┌───┬───┐
               │'b'│nil│
               └───┴───┘
   ```

3. Write the cons expression to build:
   - `(1 (2 3) 4)`
   - `((a . b) . c)` (improper list)

## Gotchas

1. **Not all lists end in nil**: Improper lists like `(1 . 2)` exist
2. **Circular lists are possible**: A cons cell can point back to itself
3. **Sharing is possible**: Multiple cons cells can point to the same cdr
4. **Mutation would break things**: That's why we don't allow it!