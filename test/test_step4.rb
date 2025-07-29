#!/usr/bin/env ruby

# Unit tests for step4_if_fn_do.rb functionality

require_relative '../reader'
require_relative '../printer'
require_relative '../env'

# Load step4 definitions
load File.join(File.dirname(__FILE__), '..', 'step4_if_fn_do.rb')

$test_count = 0
$pass_count = 0

def test(name, expected, actual)
  $test_count += 1
  if expected == actual
    $pass_count += 1
    puts "✓ #{name}"
  else
    puts "✗ #{name}"
    puts "  Expected: #{expected.inspect}"
    puts "  Actual: #{actual.inspect}"
  end
end

def test_eval(name, expr, expected, env = create_repl_env)
  begin
    result = EVAL(READ(expr), env)
    actual = PRINT(result)
    test(name, expected, actual)
  rescue => e
    if expected.start_with?("ERROR:")
      test(name, true, e.message.include?(expected.sub("ERROR:", "").strip))
    else
      puts "✗ #{name}"
      puts "  Expected: #{expected}"
      puts "  Got error: #{e.message}"
      $test_count += 1
    end
  end
end

puts "Testing Step 4 - If, Functions, Do..."
puts "====================================="

# Test if special form
test_eval("if true", '(if true "yes" "no")', '"yes"')
test_eval("if false", '(if false "yes" "no")', '"no"')
test_eval("if nil", '(if nil "yes" "no")', '"no"')
test_eval("if 0 (truthy)", '(if 0 "yes" "no")', '"yes"')
test_eval("if empty string (truthy)", '(if "" "yes" "no")', '"yes"')
test_eval("if no else", '(if false "yes")', 'nil')
test_eval("if with condition", '(if (> 2 1) "yes" "no")', '"yes"')
test_eval("if with complex condition", '(if (= (+ 1 2) 3) "yes" "no")', '"yes"')

# Test fn* special form
env = create_repl_env
test_eval("fn* returns function", '(fn* (x) x)', '#<function>', env)
test_eval("define function", '(def! identity (fn* (x) x))', '#<function>', env)
test_eval("call function", '(identity 42)', '42', env)
test_eval("function with arithmetic", '(def! add5 (fn* (x) (+ x 5)))', '#<function>', env)
test_eval("call add5", '(add5 7)', '12', env)
test_eval("two param function", '(def! add (fn* (a b) (+ a b)))', '#<function>', env)
test_eval("call two param", '(add 10 20)', '30', env)

# Test closures
test_eval("outer binding", '(def! x 100)', '100', env)
test_eval("closure captures env", '(def! add-x (fn* (y) (+ x y)))', '#<function>', env)
test_eval("closure uses outer", '(add-x 5)', '105', env)
test_eval("inner doesn't affect outer", '(def! shadow (fn* (x) x))', '#<function>', env)
test_eval("call with shadow", '(shadow 42)', '42', env)
test_eval("outer still same", 'x', '100', env)

# Test do special form
test_eval("do returns last", '(do 1 2 3)', '3', env)
test_eval("do with side effects", '(do (def! a 10) (def! b 20) (+ a b))', '30', env)
test_eval("do empty", '(do)', 'nil', env)
test_eval("do single expr", '(do 42)', '42', env)

# Test recursive functions
test_eval("factorial def", 
  '(def! fact (fn* (n) (if (= n 0) 1 (* n (fact (- n 1))))))', 
  '#<function>', env)
test_eval("factorial 0", '(fact 0)', '1', env)
test_eval("factorial 1", '(fact 1)', '1', env)
test_eval("factorial 5", '(fact 5)', '120', env)

# Test list functions
test_eval("list creates list", '(list 1 2 3)', '(1 2 3)', env)
test_eval("list?", '(list? (list 1 2))', 'true', env)
test_eval("list? on non-list", '(list? 42)', 'false', env)
test_eval("empty? on empty", '(empty? (list))', 'true', env)
test_eval("empty? on non-empty", '(empty? (list 1))', 'false', env)
test_eval("count empty", '(count (list))', '0', env)
test_eval("count list", '(count (list 1 2 3))', '3', env)

# Test comparison operators
test_eval("= true", '(= 1 1)', 'true', env)
test_eval("= false", '(= 1 2)', 'false', env)
test_eval("< true", '(< 1 2)', 'true', env)
test_eval("< false", '(< 2 1)', 'false', env)
test_eval("> true", '(> 2 1)', 'true', env)
test_eval("> false", '(> 1 2)', 'false', env)
test_eval("<= equal", '(<= 5 5)', 'true', env)
test_eval("<= less", '(<= 4 5)', 'true', env)
test_eval("<= false", '(<= 6 5)', 'false', env)
test_eval(">= equal", '(>= 5 5)', 'true', env)
test_eval(">= greater", '(>= 6 5)', 'true', env)
test_eval(">= false", '(>= 4 5)', 'false', env)

# Test not function
test_eval("not false", '(not false)', 'true', env)
test_eval("not nil", '(not nil)', 'true', env)
test_eval("not true", '(not true)', 'false', env)
test_eval("not number", '(not 0)', 'false', env)
test_eval("not string", '(not "")', 'false', env)

# Summary
puts ""
puts "#{$pass_count}/#{$test_count} tests passed"
exit($pass_count == $test_count ? 0 : 1)