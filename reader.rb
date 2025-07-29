# Reader module for MAL - parsing without arrays/hashes/blocks
# Uses only cons cells for all data structures

# ===== Pairs (cons cells) =====
def cons(car_val, cdr_val)
  pair = Object.new
  pair.instance_variable_set(:@car, car_val)
  pair.instance_variable_set(:@cdr, cdr_val)
  
  eval <<-RUBY
    def pair.car; @car; end
    def pair.cdr; @cdr; end
    def pair.pair?; true; end
  RUBY
  
  pair
end

def car(pair)
  pair.respond_to?(:car) ? pair.car : raise("car: not a pair")
end

def cdr(pair)
  pair.respond_to?(:cdr) ? pair.cdr : raise("cdr: not a pair")
end

def pair?(obj)
  obj.respond_to?(:pair?) && obj.pair?
end

def null?(obj)
  obj.nil?
end

# ===== Reader =====
class Reader
  def initialize(tokens)
    @tokens = tokens
    @position = 0
  end
  
  def next
    return nil if @position >= count_tokens(@tokens)
    token = nth_token(@tokens, @position)
    @position += 1
    token
  end
  
  def peek
    return nil if @position >= count_tokens(@tokens)
    nth_token(@tokens, @position)
  end
  
  private
  
  def count_tokens(lst)
    count = 0
    while !null?(lst)
      count += 1
      lst = cdr(lst)
    end
    count
  end
  
  def nth_token(lst, n)
    while n > 0 && !null?(lst)
      lst = cdr(lst)
      n -= 1
    end
    null?(lst) ? nil : car(lst)
  end
end

def tokenize(str)
  tokens = nil
  current_token = ""
  i = 0
  in_string = false
  escape_next = false
  
  while i < str.length
    char = str.slice(i, 1)
    
    if in_string
      if escape_next
        # Handle escape sequences
        case char
        when 'n' then current_token += "\n"
        when 't' then current_token += "\t"
        when 'r' then current_token += "\r"
        when '\\' then current_token += "\\"
        when '"' then current_token += '"'
        else current_token += char
        end
        escape_next = false
      elsif char == '\\'
        escape_next = true
      elsif char == '"'
        current_token += char
        tokens = cons(current_token, tokens)
        current_token = ""
        in_string = false
      else
        current_token += char
      end
    elsif char == '"'
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
      current_token = char
      in_string = true
    elsif char == ' ' || char == "\n" || char == "\t" || char == ','
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
    elsif char == '(' || char == ')' || char == '[' || char == ']' || 
          char == '{' || char == '}' || char == "'" || char == '`' ||
          char == '~' || char == '^' || char == '@'
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
      # Handle ~@ as a single token
      if char == '~' && i + 1 < str.length && str.slice(i + 1, 1) == '@'
        tokens = cons("~@", tokens)
        i += 1
      else
        tokens = cons(char, tokens)
      end
    elsif char == ';'
      # Comment - skip to end of line
      if current_token.length > 0
        tokens = cons(current_token, tokens)
        current_token = ""
      end
      while i < str.length && str.slice(i, 1) != "\n"
        i += 1
      end
      i -= 1  # Back up one so the loop increment doesn't skip the newline
    else
      current_token += char
    end
    
    i += 1
  end
  
  if current_token.length > 0
    tokens = cons(current_token, tokens)
  end
  
  reverse_list(tokens)
end

def reverse_list(lst)
  result = nil
  while !null?(lst)
    result = cons(car(lst), result)
    lst = cdr(lst)
  end
  result
end

def read_str(str)
  tokens = tokenize(str)
  return nil if null?(tokens)
  reader = Reader.new(tokens)
  read_form(reader)
end

def read_form(reader)
  token = reader.peek
  return nil if token.nil?
  
  case token
  when '('
    read_list(reader)
  when '['
    read_vector(reader)
  when '{'
    read_hash_map(reader)
  when "'"
    reader.next  # consume '
    form = read_form(reader)
    list2(make_symbol("quote"), form)
  when '`'
    reader.next  # consume `
    form = read_form(reader)
    list2(make_symbol("quasiquote"), form)
  when '~'
    reader.next  # consume ~
    form = read_form(reader)
    list2(make_symbol("unquote"), form)
  when '~@'
    reader.next  # consume ~@
    form = read_form(reader)
    list2(make_symbol("splice-unquote"), form)
  when '^'
    reader.next  # consume ^
    meta = read_form(reader)
    form = read_form(reader)
    list3(make_symbol("with-meta"), form, meta)
  when '@'
    reader.next  # consume @
    form = read_form(reader)
    list2(make_symbol("deref"), form)
  else
    read_atom(reader)
  end
end

def read_list(reader)
  reader.next  # consume (
  elements = nil
  
  while reader.peek && reader.peek != ')'
    element = read_form(reader)
    elements = cons(element, elements)
  end
  
  if reader.peek != ')'
    raise "Expected ')', got EOF"
  end
  
  reader.next  # consume )
  reverse_list(elements)
end

def read_vector(reader)
  reader.next  # consume [
  elements = nil
  
  while reader.peek && reader.peek != ']'
    element = read_form(reader)
    elements = cons(element, elements)
  end
  
  if reader.peek != ']'
    raise "Expected ']', got EOF"
  end
  
  reader.next  # consume ]
  
  # Create vector type
  vec = Object.new
  vec.instance_variable_set(:@elements, reverse_list(elements))
  eval <<-RUBY
    def vec.vector?; true; end
    def vec.elements; @elements; end
  RUBY
  vec
end

def read_hash_map(reader)
  reader.next  # consume {
  pairs = nil
  
  while reader.peek && reader.peek != '}'
    key = read_form(reader)
    if reader.peek == '}'
      raise "Hash map must have even number of elements"
    end
    value = read_form(reader)
    pairs = cons(cons(key, value), pairs)
  end
  
  if reader.peek != '}'
    raise "Expected '}', got EOF"
  end
  
  reader.next  # consume }
  
  # Create hash-map type
  hm = Object.new
  hm.instance_variable_set(:@pairs, reverse_list(pairs))
  eval <<-RUBY
    def hm.hash_map?; true; end
    def hm.pairs; @pairs; end
  RUBY
  hm
end

def read_atom(reader)
  token = reader.next
  
  # Integer
  if token.match(/^-?\d+$/)
    return token.to_i
  end
  
  # String
  if token.start_with?('"')
    if !token.end_with?('"') || token.length < 2
      raise "Unterminated string"
    end
    # Remove quotes and process escapes
    str_content = token.slice(1, token.length - 2)
    return process_string_escapes(str_content)
  end
  
  # nil, true, false
  case token
  when "nil" then return nil
  when "true" then return true
  when "false" then return false
  end
  
  # Keywords (start with :)
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

def process_string_escapes(str)
  result = ""
  i = 0
  while i < str.length
    if str.slice(i, 1) == '\\' && i + 1 < str.length
      case str.slice(i + 1, 1)
      when 'n' then result += "\n"
      when 't' then result += "\t"
      when 'r' then result += "\r"
      when '\\' then result += "\\"
      when '"' then result += '"'
      else 
        result += str.slice(i + 1, 1)
      end
      i += 2
    else
      result += str.slice(i, 1)
      i += 1
    end
  end
  result
end

# ===== Types =====
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

# Helper functions
def list2(a, b)
  cons(a, cons(b, nil))
end

def list3(a, b, c)
  cons(a, cons(b, cons(c, nil)))