# Extensions to MacRuby
#
# Define some convenience methods for classes
# with sharp edges

# Check for macruby
unless defined? RUBY_ENGINE && RUBY_ENGINE == 'macruby'
  puts "You need to install MacRuby"
  exit 1
end

# Monkey patch for MacRuby 0.3.0 release version:
# String does not respond to :each, only :each_byte
class String; alias :each :each_line; end

class Pointer
  def self.ptr(type = :object)
    case type
      when :object
        new_with_type('@')
      when :int
        new_with_type('i')
      when :bool
      when :BOOL
        new_with_type('c')
      when :unsigned
        new_with_type('I')
    end
  end
  
  def value
    self[0]
  end
end