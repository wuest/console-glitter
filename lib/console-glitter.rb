# typed: strong
module ConsoleGlitter
  VERSION = '0.3.0'

  extend self

    # Public: Return an appropriate escape sequence depending upon the current
    # platform.
    #
    # sequence - String containing control code(s) to be escaped.
    #
    # Examples
    #
    #   ConsoleGlitter.escape 'A'
    #   # => "\033[A"
    #
    # Returns a String.
    def escape(sequence)
      RUBY_PLATFORM =~ /(^win)|mingw/i ? '' : "\033[#{sequence}" 
    end
end
