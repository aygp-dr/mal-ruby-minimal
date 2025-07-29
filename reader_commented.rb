#!/usr/bin/env ruby

# MAL Reader - Parsing S-expressions without Ruby conveniences
# 
# PEDAGOGICAL NOTES:
# This module demonstrates how to build a parser using only fundamental
# data structures. We avoid Ruby's arrays, hashes, and blocks to show
# how parsing works at a low level.
#
# KEY CONCEPTS:
# 1. Cons cells (pairs) as the universal data structure
# 2. Recursive descent parsing
# 3. Manual tokenization without regex
# 4. Building complex structures from simple primitives

# ===== CONS CELLS: The Foundation =====
# A cons cell is simply a pair of values, traditionally called
# CAR (Contents of Address Register) and CDR (Contents of Decrement Register)
# from Lisp's IBM 704 origins.
#
# Visual representation:
#   [CAR|CDR] -> [CAR|CDR] -> [CAR|CDR] -> nil
#
# List (1 2 3) becomes:
#   [1|•] -> [2|•] -> [3|nil]

def cons(car_val, cdr_val)
  # Create a new object to represent our pair
  pair = Object.new
  
  # Store the values as instance variables
  pair.instance_variable_set(:@car, car_val)
  pair.instance_variable_set(:@cdr, cdr_val)
  
  # Define methods on this specific object
  # We use eval to dynamically define methods because we can't use blocks
  eval <<-RUBY
    def pair.car; @car; end      # Get first element
    def pair.cdr; @cdr; end      # Get rest of list
    def pair.pair?; true; end    # Type predicate
  RUBY
  
  pair
end

# CAR: Get the first element of a pair
# Historical note: "Contents of Address Register" from IBM 704
def car(pair)
  pair.respond_to?(:car) ? pair.car : raise("car: not a pair")
end

# CDR: Get the rest of the list (second element of pair)
# Historical note: "Contents of Decrement Register" from IBM 704
def cdr(pair)
  pair.respond_to?(:cdr) ? pair.cdr : raise("cdr: not a pair")
end

# Type predicates - these help us identify what kind of data we have
def pair?(obj)
  obj.respond_to?(:pair?) && obj.pair?
end

def null?(obj)
  obj.nil?
end

# ===== READER CLASS: Managing Token Stream =====
# The Reader maintains our position in the token stream.
# Think of it as a cursor moving through the tokens.
class Reader
  def initialize(tokens)
    @tokens = tokens      # List of tokens (as cons cells)
    @position = 0         # Current position in token list
  end
  
  # Get current token and advance position
  def next
    return nil if @position >= count_tokens(@tokens)
    token = nth_token(@tokens, @position)
    @position += 1
    token
  end
  
  # Look at current token without advancing
  def peek
    return nil if @position >= count_tokens(@tokens)
    nth_token(@tokens, @position)
  end
  
  private
  
  # Count tokens by walking the list
  # O(n) operation - shows why arrays are more efficient!
  def count_tokens(tokens)
    count = 0
    current = tokens
    while !null?(current)
      count += 1
      current = cdr(current)
    end
    count
  end
  
  # Get nth token by walking the list
  # O(n) operation - another efficiency lesson
  def nth_token(tokens, n)
    current = tokens
    n.times do
      return nil if null?(current)
      current = cdr(current)
    end
    null?(current) ? nil : car(current)
  end
end

# ===== TOKENIZER: Breaking Input into Tokens =====
# Tokenization is the first step of parsing. We break the input
# string into meaningful chunks (tokens) like "(", ")", numbers, symbols.
#
# APPROACH: Character-by-character processing
# - No regex (that would be too easy!)
# - Manual state tracking
# - Build tokens character by character
def tokenize(str)
  tokens = nil          # We'll build a list backwards
  i = 0                 # Current position in string
  
  while i < str.length
    char = str[i]
    
    case char
    when ' ', "\t", "\n", "\r", ','  # Whitespace and comma
      i += 1  # Skip
      
    when '('  # List start
      tokens = cons('(', tokens)
      i += 1
      
    when ')'  # List end
      tokens = cons(')', tokens)
      i += 1
      
    when '['  # Vector start
      tokens = cons('[', tokens)
      i += 1
      
    when ']'  # Vector end
      tokens = cons(']', tokens)
      i += 1
      
    when '{'  # Hash-map start
      tokens = cons('{', tokens)
      i += 1
      
    when '}'  # Hash-map end
      tokens = cons('}', tokens)
      i += 1
      
    when '"'  # String - collect until closing quote
      j = i + 1
      # Find closing quote, handling escapes
      while j < str.length && str[j] != '"'
        j += 1 if str[j] == '\\'  # Skip escaped character
        j += 1
      end
      
      if j >= str.length
        raise "Unterminated string starting at position #{i}"
      end
      
      # Include both quotes in token
      tokens = cons(str[i..j], tokens)
      i = j + 1
      
    when ';'  # Comment - skip to end of line
      while i < str.length && str[i] != "\n"
        i += 1
      end
      
    when '~'  # Special reader macros
      if i + 1 < str.length && str[i + 1] == '@'
        tokens = cons('~@', tokens)
        i += 2
      else
        tokens = cons('~', tokens)
        i += 1
      end
      
    when "'", '`', '^', '@'  # Other reader macros
      tokens = cons(char, tokens)
      i += 1
      
    else  # Everything else is an atom (number, symbol, etc)
      j = i
      # Collect characters that form an atom
      while j < str.length && 
            ![' ', "\t", "\n", "\r", '(', ')', '[', ']', '{', '}', '"', ';', ','].include?(str[j])
        j += 1
      end
      
      tokens = cons(str[i...j], tokens)
      i = j
    end
  end
  
  # We built the list backwards, so reverse it
  reverse_list(tokens)
end

# ===== LIST MANIPULATION UTILITIES =====

# Reverse a list - needed because we often build lists backwards
# for efficiency (adding to front is O(1), to end is O(n))
def reverse_list(lst)
  result = nil
  current = lst
  
  while !null?(current)
    result = cons(car(current), result)
    current = cdr(current)
  end
  
  result
end

# ===== SYMBOL TYPE =====
# Symbols are identifiers in our language (variable names, function names)
def make_symbol(name)
  sym = Object.new
  sym.instance_variable_set(:@name, name)
  
  eval <<-RUBY
    def sym.name; @name; end
    def sym.symbol?; true; end
    def sym.to_s; @name; end
  RUBY
  
  sym
end

def symbol?(obj)
  obj.respond_to?(:symbol?) && obj.symbol?
end

# ===== KEYWORD TYPE =====
# Keywords are like symbols but self-evaluating (used as hash keys)
def make_keyword(name)
  kw = Object.new
  kw.instance_variable_set(:@name, name)
  
  eval <<-RUBY
    def kw.name; @name; end
    def kw.keyword?; true; end
    def kw.to_s; ":#{@name}"; end
  RUBY
  
  kw
end

def keyword?(obj)
  obj.respond_to?(:keyword?) && obj.keyword?
end

# Continue with more documented sections...