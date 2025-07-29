#!/usr/bin/env ruby

# Unit tests for printer.rb

require_relative '../reader'
require_relative '../printer'

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

puts "Testing Printer..."
puts "=================="

# Test atoms
test("Print integer", "42", pr_str(42))
test("Print negative", "-17", pr_str(-17))
test("Print string readable", '"hello"', pr_str("hello", true))
test("Print string not readable", 'hello', pr_str("hello", false))
test("Print nil", "nil", pr_str(nil))
test("Print true", "true", pr_str(true))
test("Print false", "false", pr_str(false))

# Test string escaping
test("Escape newline", '"hello\\nworld"', pr_str("hello\nworld"))
test("Escape tab", '"hello\\tworld"', pr_str("hello\tworld"))
test("Escape backslash", '"hello\\\\world"', pr_str("hello\\world"))
test("Escape quote", '"say \\"hi\\""', pr_str('say "hi"'))

# Test symbols and keywords
sym = make_symbol("foo")
test("Print symbol", "foo", pr_str(sym))

keyword = read_str(":bar")
test("Print keyword", ":bar", pr_str(keyword))

# Test lists
lst = cons(1, cons(2, cons(3, nil)))
test("Print list", "(1 2 3)", pr_str(lst))

empty = nil
test("Print nil as nil", "nil", pr_str(empty))

# Test nested lists
nested = cons(make_symbol("+"), cons(1, cons(cons(make_symbol("*"), cons(2, cons(3, nil))), nil)))
test("Print nested list", "(+ 1 (* 2 3))", pr_str(nested))

# Test vectors
vec = read_str("[1 2 3]")
test("Print vector", "[1 2 3]", pr_str(vec))

# Test hash-maps
hm = read_str("{:a 1 :b 2}")
result = pr_str(hm)
# Hash-map order might vary, check both possibilities
test_valid = result == "{:a 1 :b 2}" || result == "{:b 2 :a 1}"
if test_valid
  $pass_count += 1
  puts "✓ Print hash-map"
else
  puts "✗ Print hash-map"
  puts "  Expected: {:a 1 :b 2} or {:b 2 :a 1}"
  puts "  Actual: #{result}"
end
$test_count += 1

# Test round-trip property
def round_trip_test(name, str)
  ast = read_str(str)
  result = pr_str(ast)
  test("Round-trip: #{name}", str, result)
end

round_trip_test("number", "42")
round_trip_test("symbol", "foo")
round_trip_test("list", "(+ 1 2)")
round_trip_test("vector", "[1 2 3]")
round_trip_test("string", '"hello world"')
round_trip_test("nested", "(+ 1 (* 2 3))")

# Summary
puts ""
puts "#{$pass_count}/#{$test_count} tests passed"
exit($pass_count == $test_count ? 0 : 1)