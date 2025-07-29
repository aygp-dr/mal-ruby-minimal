#!/usr/bin/env ruby

# Unit tests for env.rb

require_relative '../reader'
require_relative '../env'

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

def test_error(name, error_pattern)
  $test_count += 1
  begin
    yield
    puts "✗ #{name}"
    puts "  Expected error matching: #{error_pattern}"
    puts "  But no error was raised"
  rescue => e
    if e.message.match?(error_pattern)
      $pass_count += 1
      puts "✓ #{name}"
    else
      puts "✗ #{name}"
      puts "  Expected error matching: #{error_pattern}"
      puts "  Actual error: #{e.message}"
    end
  end
end

puts "Testing Environment..."
puts "====================="

# Test basic set/get
env = Env.new
env.set("x", 42)
test("Set and get", 42, env.get("x"))

env.set("y", "hello")
test("Multiple bindings", "hello", env.get("y"))
test("First binding still works", 42, env.get("x"))

# Test shadowing
env.set("x", 99)
test("Shadowing", 99, env.get("x"))

# Test not found
test_error("Unknown symbol", /Unknown symbol: z/) do
  env.get("z")
end

# Test nested environments
outer = Env.new
outer.set("a", 1)
outer.set("b", 2)

inner = Env.new(outer)
inner.set("b", 20)
inner.set("c", 30)

test("Inner env shadows outer", 20, inner.get("b"))
test("Inner env finds from outer", 1, inner.get("a"))
test("Inner env has own binding", 30, inner.get("c"))
test("Outer env unchanged", 2, outer.get("b"))

test_error("Outer doesn't see inner", /Unknown symbol: c/) do
  outer.get("c")
end

# Test find method
test("Find in current env", inner, inner.find("c"))
test("Find in outer env", outer, inner.find("a"))
test("Find returns nil when not found", nil, inner.find("z"))

# Test with symbols (as they would be in actual use)
env2 = Env.new
env2.set("foo", 123)
test("String keys work", 123, env2.get("foo"))

# Test deep nesting
level1 = Env.new
level1.set("x", 1)

level2 = Env.new(level1)
level2.set("x", 2)
level2.set("y", 2)

level3 = Env.new(level2)
level3.set("x", 3)
level3.set("z", 3)

test("Deep nesting - level 3 x", 3, level3.get("x"))
test("Deep nesting - level 3 y", 2, level3.get("y"))
test("Deep nesting - level 3 z", 3, level3.get("z"))
test("Deep nesting - level 2 x", 2, level2.get("x"))
test("Deep nesting - level 1 x", 1, level1.get("x"))

# Summary
puts ""
puts "#{$pass_count}/#{$test_count} tests passed"
exit($pass_count == $test_count ? 0 : 1)