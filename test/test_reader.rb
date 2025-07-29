#!/usr/bin/env ruby

# Unit tests for reader.rb
# Following SICP testing approach - simple assertions

require_relative '../reader'

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

def test_true(name, condition)
  test(name, true, condition)
end

puts "Testing Reader..."
puts "================="

# Test tokenization
tokens = tokenize("(+ 1 2)")
test("Tokenize simple list", "(", car(tokens))
test("Second token", "+", car(cdr(tokens)))
test("Third token", "1", car(cdr(cdr(tokens))))

# Test numbers
ast = read_str("42")
test("Read positive number", 42, ast)

ast = read_str("-17")
test("Read negative number", -17, ast)

# Test symbols
ast = read_str("foo")
test_true("Read symbol", symbol?(ast))
test("Symbol name", "foo", ast.name)

# Test strings
ast = read_str('"hello"')
test("Read string", "hello", ast)

ast = read_str('"hello\\nworld"')
test("String with newline", "hello\nworld", ast)

# Test nil, true, false
test("Read nil", nil, read_str("nil"))
test("Read true", true, read_str("true"))
test("Read false", false, read_str("false"))

# Test lists
ast = read_str("(+ 1 2)")
test_true("Read list is pair", pair?(ast))
test_true("First element is symbol", symbol?(car(ast)))
test("First element name", "+", car(ast).name)
test("Second element", 1, car(cdr(ast)))
test("Third element", 2, car(cdr(cdr(ast))))
test_true("List ends with nil", null?(cdr(cdr(cdr(ast)))))

# Test empty list
ast = read_str("()")
test_true("Empty list is nil", null?(ast))

# Test vectors
ast = read_str("[1 2 3]")
test_true("Read vector", vector?(ast))
elements = ast.elements
test("Vector first element", 1, car(elements))
test("Vector second element", 2, car(cdr(elements)))

# Test hash-maps
ast = read_str("{:a 1 :b 2}")
test_true("Read hash-map", hash_map?(ast))
pairs = ast.pairs
first_pair = car(pairs)
test_true("Hash key is keyword", keyword?(car(first_pair)))
test("Hash key name", ":a", car(first_pair).name)
test("Hash value", 1, cdr(first_pair))

# Test reader macros
ast = read_str("'foo")
test_true("Quote produces list", pair?(ast))
test("Quote first element", "quote", car(ast).name)
test("Quoted element", "foo", car(cdr(ast)).name)

ast = read_str("`foo")
test("Quasiquote", "quasiquote", car(ast).name)

ast = read_str("~foo")
test("Unquote", "unquote", car(ast).name)

ast = read_str("~@foo")
test("Splice-unquote", "splice-unquote", car(ast).name)

# Test nested structures
ast = read_str("(+ (* 2 3) 4)")
test_true("Nested list", pair?(ast))
inner = car(cdr(ast))
test_true("Inner list is pair", pair?(inner))
test("Inner operation", "*", car(inner).name)

# Summary
puts ""
puts "#{$pass_count}/#{$test_count} tests passed"
exit($pass_count == $test_count ? 0 : 1)