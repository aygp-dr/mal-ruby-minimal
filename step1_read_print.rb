#!/usr/bin/env ruby

# Step 1: Read and Print
# Adds parsing of input and printing of AST

require_relative 'reader'
require_relative 'printer'

def READ(str)
  read_str(str)
end

def EVAL(ast, env)
  ast
end

def PRINT(exp)
  pr_str(exp, true)
end

def rep(str)
  PRINT(EVAL(READ(str), nil))
end

# REPL
if __FILE__ == $0
  loop do
    print "user> "
    input = gets
    break if input.nil?  # EOF
    
    input = input.chomp
    next if input.empty?
    
    begin
      puts rep(input)
    rescue => e
      puts "Error: #{e.message}"
    end
  end
end