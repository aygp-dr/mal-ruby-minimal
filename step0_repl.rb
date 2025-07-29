#!/usr/bin/env ruby

# Step 0: Basic REPL
# A simple Read-Eval-Print-Loop that echoes input

def READ(str)
  str
end

def EVAL(ast, env)
  ast
end

def PRINT(exp)
  exp
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
    
    puts rep(input)
  end
end