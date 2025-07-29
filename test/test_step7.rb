#!/usr/bin/env ruby

# Unit tests for step7_quote.rb functionality

require_relative '../reader'
require_relative '../printer'
require_relative '../env'

# Load step7 definitions
load File.join(File.dirname(__FILE__), '..', 'step7_quote.rb')

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

puts "Testing Step 7 - Quote and Quasiquote..."
puts "========================================"

# Test quote special form
test_eval("quote number", '(quote 123)', '123')
test_eval("quote symbol", '(quote abc)', 'abc')
test_eval("quote list", '(quote (1 2 3))', '(1 2 3)')
test_eval("quote nested list", '(quote (1 (2 3) 4))', '(1 (2 3) 4)')
test_eval("quote empty list", '(quote ())', 'nil')
test_eval("quote special forms", '(quote (def! x 5))', '(def! x 5)')

# Test reader macros for quote
test_eval("reader quote symbol", "'abc", 'abc')
test_eval("reader quote list", "'(1 2 3)", '(1 2 3)')
test_eval("reader quote nested", "'(a 'b c)", '(a (quote b) c)')

# Test quasiquote basics
test_eval("quasiquote number", '(quasiquote 123)', '123')
test_eval("quasiquote symbol", '(quasiquote abc)', 'abc')
test_eval("quasiquote list no unquotes", '(quasiquote (1 2 3))', '(1 2 3)')

# Test unquote
env = create_repl_env
test_eval("def for unquote test", '(def! x 10)', '10', env)
test_eval("unquote in quasiquote", '(quasiquote (1 (unquote x) 3))', '(1 10 3)', env)
test_eval("unquote symbol", '(quasiquote (a (unquote x) c))', '(a 10 c)', env)
test_eval("unquote expression", '(quasiquote (1 (unquote (+ 2 3)) 4))', '(1 5 4)', env)

# Test reader macros for quasiquote/unquote
test_eval("reader quasiquote", "`(1 2 3)", '(1 2 3)', env)
test_eval("reader unquote", "`(1 ~x 3)", '(1 10 3)', env)
test_eval("reader unquote expr", "`(1 ~(+ 2 3) 4)", '(1 5 4)', env)

# Test splice-unquote
test_eval("def list for splice", '(def! lst (list 2 3))', '(2 3)', env)
test_eval("splice-unquote", '(quasiquote (1 (splice-unquote lst) 4))', '(1 2 3 4)', env)
test_eval("reader splice-unquote", "`(1 ~@lst 4)", '(1 2 3 4)', env)

# Test nested quasiquotes
test_eval("nested quasiquote", 
  '(quasiquote (1 (quasiquote (2 (unquote (+ 1 2)) 4)) 5))',
  '(1 (quasiquote (2 (unquote (+ 1 2)) 4)) 5)', env)

# Test quasiquoteexpand (debugging form)
test_eval("quasiquoteexpand simple", 
  '(quasiquoteexpand (1 2 3))', 
  '(cons 1 (cons 2 (cons 3 nil)))', env)

test_eval("quasiquoteexpand with unquote", 
  '(quasiquoteexpand (1 (unquote x) 3))', 
  '(cons 1 (cons x (cons 3 nil)))', env)

test_eval("quasiquoteexpand with splice",
  '(quasiquoteexpand (1 (splice-unquote lst) 4))',
  '(cons 1 (concat lst (cons 4 nil)))', env)

# Test cons and concat functions
test_eval("cons", '(cons 1 (list 2 3))', '(1 2 3)', env)
test_eval("cons to nil", '(cons 1 nil)', '(1)', env)
test_eval("concat empty", '(concat)', 'nil', env)
test_eval("concat single", '(concat (list 1 2))', '(1 2)', env)
test_eval("concat multiple", '(concat (list 1 2) (list 3 4) (list 5))', '(1 2 3 4 5)', env)

# Test quote prevents evaluation
test_eval("quote prevents eval", '(quote (+ 1 2))', '(+ 1 2)', env)
test_eval("eval quoted form", '(eval (quote (+ 1 2)))', '3', env)

# Error cases
test_eval("quote no args", '(quote)', 'ERROR: quote requires an argument', env)
test_eval("unquote outside quasiquote", '(unquote x)', 'ERROR: unquote requires an argument', env)
test_eval("splice-unquote outside", '(splice-unquote lst)', 'ERROR: splice-unquote requires an argument', env)

# Summary
puts ""
puts "#{$pass_count}/#{$test_count} tests passed"
exit($pass_count == $test_count ? 0 : 1)