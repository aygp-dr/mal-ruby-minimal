#!/usr/bin/env ruby

# Enable code coverage if running all tests
if ENV['COVERAGE'] || ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/experiments/'
    add_filter '/examples/'
    add_filter '/docs/'
    
    add_group 'Core', %w[reader.rb printer.rb env.rb]
    add_group 'Steps', 'step'
    add_group 'Main', 'mal_minimal.rb'
  end
end

# Common test utilities
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

# Test assertion helpers
def assert(condition, message = "Assertion failed")
  unless condition
    raise AssertionError, message
  end
end

def assert_equal(expected, actual, message = nil)
  unless expected == actual
    msg = message || "Expected #{expected.inspect}, got #{actual.inspect}"
    raise AssertionError, msg
  end
end

def assert_raises(exception_class, message = nil)
  begin
    yield
    raise AssertionError, message || "Expected #{exception_class} to be raised"
  rescue exception_class
    # Expected
  end
end

class AssertionError < StandardError; end