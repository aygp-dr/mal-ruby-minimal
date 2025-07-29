# Reader module for MAL - Parsing without arrays/hashes/blocks
# 
# PEDAGOGICAL NOTE: This module demonstrates how to build a complete
# parser using only cons cells. This is fundamental to understanding
# how Lisp works at its core.
#
# Key concepts:
# 1. Everything is built from pairs (cons cells)
# 2. Lists are chains of pairs ending in nil
# 3. Parsing is recursive descent
# 4. No Ruby conveniences - everything explicit

# ===== FUNDAMENTAL DATA STRUCTURE: The Cons Cell =====
# A cons cell is just a pair with two slots: car and cdr
# This is THE building block for all our data structures
#
# Visual representation:
#   [car|cdr] 
#
# List (1 2 3) looks like:
#   [1|•]-->[2|•]-->[3|nil]
#
def cons(car_val, cdr_val)
  # Create a new object to represent our pair
  pair = Object.new
  
  # Store the two values
  pair.instance_variable_set(:@car, car_val)
  pair.instance_variable_set(:@cdr, cdr_val)
  
  # Define methods for accessing the values
  # We use eval to define methods because we can't use blocks
  eval <<-RUBY
    def pair.car; @car; end
    def pair.cdr; @cdr; end
    def pair.pair?; true; end
  RUBY
  
  pair
end

# Access first element of pair
def car(pair)
  if pair.respond_to?(:car)
    pair.car
  else
    raise "car: not a pair - tried to take car of #{pair.inspect}"
  end
end

# Access second element of pair  
def cdr(pair)
  if pair.respond_to?(:cdr)
    pair.cdr
  else
    raise "cdr: not a pair - tried to take cdr of #{pair.inspect}"
  end
end

# Check if something is a pair
def pair?(obj)
  obj.respond_to?(:pair?) && obj.pair?
end

# Check if something is nil (empty list)
def null?(obj)
  obj.nil?
end

# ===== THE READER: Managing Token Stream =====
# The Reader keeps track of our position in a list of tokens
# Think of it as a cursor moving through the token list
class Reader
  def initialize(tokens)
    @tokens = tokens      # Cons list of tokens
    @position = 0         # Current position (0-based)
  end
  
  # Get current token and advance position
  def next
    # If we've read all tokens, return nil
    return nil if @position >= count_tokens(@tokens)
    
    # Get the token at current position
    token = nth_token(@tokens, @position)
    
    # Advance to next position
    @position += 1
    
    token
  end
  
  # Look at current token without advancing
  def peek
    # If we've read all tokens, return nil
    return nil if @position >= count_tokens(@tokens)
    
    # Return token at current position
    nth_token(@tokens, @position)
  end
  
  private
  
  # Count elements in a cons list
  # PEDAGOGICAL NOTE: This is O(n) - arrays would be O(1)
  # This shows the trade-off we make for simplicity
  def count_tokens(lst)
    count = 0
    current = lst
    
    # Walk the list until we hit nil
    while !null?(current)
      count += 1
      current = cdr(current)
    end
    
    count
  end
  
  # Get the nth element of a cons list (0-based)
  # PEDAGOGICAL NOTE: This is O(n) - arrays would be O(1)
  def nth_token(lst, n)
    current = lst
    
    # Walk n steps through the list
    while n > 0 && !null?(current)
      current = cdr(current)
      n -= 1
    end
    
    # If we hit nil, return nil; otherwise return the element
    null?(current) ? nil : car(current)
  end
end

# ===== TOKENIZER: String → Token List =====
# This function breaks a string into tokens
# A token is an atomic unit: (, ), symbol, number, string, etc.
#
# PEDAGOGICAL NOTE: We build a state machine character by character
# Most parsers use regex, but we're being explicit about the process
def tokenize(str)
  tokens = nil          # Our result list (built backwards)
  current_token = ""    # Current token we're building
  i = 0                 # Position in string
  in_string = false     # Are we inside a string?
  escape_next = false   # Should we escape the next char?
  
  # Process each character
  while i < str.length
    char = str.slice(i, 1)  # Get one character
    
    if in_string
      # ===== STRING STATE: Inside a string literal =====
      if escape_next
        # Previous char was \, so handle escape sequence
        case char
        when 'n' then current_token += "\n"  # \n → newline
        when 't' then current_token += "\t"  # \t → tab
        when 'r' then current_token += "\r"  # \r → return
        when '\\' then current_token += "\\" # \\ → backslash
        when '"' then current_token += '"'   # \" → quote
        else current_token += char           # \x → x (unknown escape)
        end
        escape_next = false
      elsif char == '\\'
        # Start escape sequence
        escape_next = true
      elsif char == '"'
        # End of string - add closing quote and save token
        current_token += char
        tokens = cons(current_token, tokens)
        current_token = ""
        in_string = false
      else
        # Regular character in string
        current_token += char
      end
      
    elsif char == '"'
      # ===== START STRING: Beginning a string literal =====
      # Save any token we were building
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
      # Start new string token
      current_token = char
      in_string = true
      
    elsif char == ' ' || char == "\n" || char == "\t" || char == ','
      # ===== WHITESPACE: Separates tokens =====
      # Commas are treated as whitespace in Lisp
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
      
    elsif char == '(' || char == ')' || char == '[' || char == ']' || 
          char == '{' || char == '}' || char == "'" || char == '`' ||
          char == '~' || char == '^' || char == '@'
      # ===== SPECIAL CHARACTERS: Always separate tokens =====
      # Save any token we were building
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
      
      # Handle ~@ as a single token (splice-unquote)
      if char == '~' && i + 1 < str.length && str.slice(i + 1, 1) == '@'
        tokens = cons("~@", tokens)
        i += 1  # Skip the @
      else
        # Single character token
        tokens = cons(char, tokens)
      end
      
    elsif char == ';'
      # ===== COMMENTS: Skip to end of line =====
      # Save any token we were building
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
      
      # Skip characters until newline
      while i < str.length && str.slice(i, 1) != "\n"
        i += 1
      end
      i -= 1  # Back up so loop increment doesn't skip newline
      
    else
      # ===== REGULAR CHARACTER: Part of a symbol/number =====
      current_token += char
    end
    
    i += 1
  end
  
  # Don't forget the last token!
  if current_token.length > 0
    tokens = cons(current_token, tokens)
  end
  
  # We built the list backwards, so reverse it
  reverse_list(tokens)
end

# Reverse a cons list
# PEDAGOGICAL NOTE: We can only efficiently add to the front of a
# cons list, so we often build backwards then reverse
def reverse_list(lst)
  result = nil
  current = lst
  
  # Take each element and add to front of result
  while !null?(current)
    result = cons(car(current), result)
    current = cdr(current)
  end
  
  result
end

# ===== MAIN ENTRY POINT: String → AST =====
def read_str(str)
  # First tokenize the string
  tokens = tokenize(str)
  
  # If no tokens, return nil
  return nil if null?(tokens)
  
  # Create a reader to track position
  reader = Reader.new(tokens)
  
  # Parse and return one form
  read_form(reader)
end

# ===== RECURSIVE DESCENT PARSER =====
# This is the heart of the parser - it looks at the current token
# and decides how to parse it
def read_form(reader)
  token = reader.peek
  return nil if token.nil?
  
  case token
  when '('
    # List: (a b c)
    read_list(reader)
  when '['
    # Vector: [a b c]
    read_vector(reader)
  when '{'
    # Hash-map: {key val key val}
    read_hash_map(reader)
  when "'"
    # Quote: 'x → (quote x)
    reader.next  # consume '
    form = read_form(reader)
    list2(make_symbol("quote"), form)
  when '`'
    # Quasiquote: `x → (quasiquote x)
    reader.next  # consume `
    form = read_form(reader)
    list2(make_symbol("quasiquote"), form)
  when '~'
    # Unquote: ~x → (unquote x)
    reader.next  # consume ~
    form = read_form(reader)
    list2(make_symbol("unquote"), form)
  when '~@'
    # Splice-unquote: ~@x → (splice-unquote x)
    reader.next  # consume ~@
    form = read_form(reader)
    list2(make_symbol("splice-unquote"), form)
  when '^'
    # Metadata: ^meta x → (with-meta x meta)
    reader.next  # consume ^
    meta = read_form(reader)
    form = read_form(reader)
    list3(make_symbol("with-meta"), form, meta)
  when '@'
    # Deref: @x → (deref x)
    reader.next  # consume @
    form = read_form(reader)
    list2(make_symbol("deref"), form)
  else
    # Must be an atom (symbol, number, string, etc.)
    read_atom(reader)
  end
end

# Parse a list: (a b c)
def read_list(reader)
  reader.next  # consume opening (
  elements = nil
  
  # Read elements until we hit )
  while reader.peek && reader.peek != ')'
    element = read_form(reader)
    elements = cons(element, elements)
  end
  
  # Make sure we have closing )
  if reader.peek != ')'
    raise "Expected ')', got EOF while reading list"
  end
  
  reader.next  # consume closing )
  
  # We built backwards, so reverse
  reverse_list(elements)
end

# Parse a vector: [a b c]
# PEDAGOGICAL NOTE: Vectors are different from lists in Lisp
# Lists are evaluated as function calls, vectors are not
def read_vector(reader)
  reader.next  # consume opening [
  elements = nil
  
  # Read elements until we hit ]
  while reader.peek && reader.peek != ']'
    element = read_form(reader)
    elements = cons(element, elements)
  end
  
  # Make sure we have closing ]
  if reader.peek != ']'
    raise "Expected ']', got EOF while reading vector"
  end
  
  reader.next  # consume closing ]
  
  # Create a special vector object
  vec = Object.new
  vec.instance_variable_set(:@elements, reverse_list(elements))
  eval <<-RUBY
    def vec.vector?; true; end
    def vec.elements; @elements; end
  RUBY
  vec
end

# Parse a hash-map: {key val key val}
def read_hash_map(reader)
  reader.next  # consume opening {
  pairs = nil
  
  # Read key-value pairs until we hit }
  while reader.peek && reader.peek != '}'
    # Read key
    key = read_form(reader)
    
    # Make sure we have a value
    if reader.peek == '}'
      raise "Hash map must have even number of elements"
    end
    
    # Read value
    value = read_form(reader)
    
    # Store as a pair (key . value)
    pairs = cons(cons(key, value), pairs)
  end
  
  # Make sure we have closing }
  if reader.peek != '}'
    raise "Expected '}', got EOF while reading hash-map"
  end
  
  reader.next  # consume closing }
  
  # Create a special hash-map object
  hm = Object.new
  hm.instance_variable_set(:@pairs, reverse_list(pairs))
  eval <<-RUBY
    def hm.hash_map?; true; end
    def hm.pairs; @pairs; end
  RUBY
  hm
end

# Parse an atom (not a list/vector/hash-map)
def read_atom(reader)
  token = reader.next
  
  # Try integer
  if token.match(/^-?\d+$/)
    return token.to_i
  end
  
  # Try string
  if token.start_with?('"')
    if !token.end_with?('"') || token.length < 2
      raise "Unterminated string: #{token}"
    end
    # Remove quotes and process escapes
    str_content = token.slice(1, token.length - 2)
    return process_string_escapes(str_content)
  end
  
  # Check for literals
  case token
  when "nil" then return nil
  when "true" then return true
  when "false" then return false
  end
  
  # Keywords start with :
  if token.start_with?(':')
    keyword = Object.new
    keyword.instance_variable_set(:@name, token)
    eval <<-RUBY
      def keyword.keyword?; true; end
      def keyword.name; @name; end
      def keyword.to_s; @name; end
    RUBY
    return keyword
  end
  
  # Everything else is a symbol
  make_symbol(token)
end

# Process escape sequences in a string
def process_string_escapes(str)
  result = ""
  i = 0
  
  while i < str.length
    if str.slice(i, 1) == '\\' && i + 1 < str.length
      # Escape sequence
      case str.slice(i + 1, 1)
      when 'n' then result += "\n"
      when 't' then result += "\t"
      when 'r' then result += "\r"
      when '\\' then result += "\\"
      when '"' then result += '"'
      else 
        # Unknown escape - just include the character
        result += str.slice(i + 1, 1)
      end
      i += 2  # Skip escape and escaped char
    else
      # Regular character
      result += str.slice(i, 1)
      i += 1
    end
  end
  
  result
end

# ===== TYPE CONSTRUCTORS AND PREDICATES =====

# Create a symbol object
# PEDAGOGICAL NOTE: Symbols are like variable names in Lisp
# They're different from strings - symbols are atomic identifiers
def make_symbol(name)
  sym = Object.new
  sym.instance_variable_set(:@name, name)
  eval <<-RUBY
    def sym.symbol?; true; end
    def sym.name; @name; end
    def sym.to_s; @name; end
  RUBY
  sym
end

# Type predicates - check what kind of object we have
def symbol?(obj)
  obj.respond_to?(:symbol?) && obj.symbol?
end

def keyword?(obj)
  obj.respond_to?(:keyword?) && obj.keyword?
end

def vector?(obj)
  obj.respond_to?(:vector?) && obj.vector?
end

def hash_map?(obj)
  obj.respond_to?(:hash_map?) && obj.hash_map?
end

def list?(obj)
  # A list is either nil or a pair
  null?(obj) || pair?(obj)
end

# ===== HELPER FUNCTIONS =====
# These create lists of specific sizes

# Create a 2-element list
def list2(a, b)
  cons(a, cons(b, nil))
end

# Create a 3-element list  
def list3(a, b, c)
  cons(a, cons(b, cons(c, nil)))
end