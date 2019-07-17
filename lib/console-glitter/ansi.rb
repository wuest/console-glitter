require 'console-glitter'

module ConsoleGlitter
  module ANSI extend self
    # Public: Generate an escape sequence to set the foreground color to an
    # approximation of a 4 or 8 bit per channel hex RGB color a la CSS.
    #
    # color - String containing hex digits describing the color to convert.
    #         May be 4 or 8 bits per channel (3 or 6 characters long,
    #         respectively).
    #
    # Examples
    #
    #   ConsoleGlitter::ANSI.hex_color("00FFFF")
    #   # => "\033[38;5;51m"
    #   ConsoleGlitter::ANSI.hex_color("F0F")
    #   # => "\033[38;5;201m"
    #
    # Returns the appropriate escape code as a Fixnum.
    def hex_color(color)
      escape [38, 5, closest(color)].join(';')
    end

    # Public: Generate an escape sequence to set the bg color to an
    # approximation of a 4 or 8 bit per channel hex RGB color a la CSS.
    #
    # color - String containing hex digits describing the color to convert.
    #         May be 4 or 8 bits per channel (3 or 6 characters long,
    #         respectively).
    #
    # Examples
    #
    #   ConsoleGlitter::ANSI.bg_hex_color("00FFFF")
    #   # => "\033[38;5;51m"
    #   ConsoleGlitter::ANSI.bg_hex_color("F0F")
    #   # => "\033[38;5;201m"
    #
    # Returns the appropriate escape code as a Fixnum.
    def bg_hex_color(color)
      escape [48, 5, closest(color)].join(';')
    end

    private

    # Internal: Wrap ConsoleGlitter#escape, appending the character 'm' to the
    # control code (per SGR spec).
    #
    # sequence - String containing the control code(s) to be escaped.  Multiple
    #            codes may be chained, separated by a ';'.
    #
    # Examples
    #
    #   escape('0')
    #   # => "\033[0m"
    #   escape('1;31')
    #   # => "\033[1;31m"
    #
    # Returns a String.
    def escape(sequence)
      ConsoleGlitter.escape(sequence.to_s + 'm')
    end

    # Internal: Allow on-the-fly definition of ANSI control sequences.  Methods
    # are created for convenience which will either wrap the result of a block
    # in the tag specified and a reset tag, or else simply return the code in
    # question.
    #
    # name - String or Symbol containing the name of the constant to be
    #        defined.
    # code - ANSI escape code to be saved.
    #
    # Returns nothing.
    #
    # Signature
    #
    #   <name>(block)
    #
    # name  - Name specified.
    # block - Optional block to be evaluated, the result of which will placed
    #         in between the escape code specified.
    def ansi(name, code)
      code = escape(code)

      define_method(name.to_sym) do |&block|
        if block
          "#{code}#{block.call}#{reset}"
        else
          code
        end
      end
    end

    # Internal: Parse a string describing either a 4 or 8 bit-per-channel color
    # (similar to CSS formatting), matching it with the closest approximation
    # for 256 color mode.
    #
    # color - String containing hex digits describing the color to convert.
    #         May be 4 or 8 bits per channel (3 or 6 characters long,
    #         respectively).
    #
    # Examples
    #
    #   ConsoleGlitter::ANSI.closest("00FFFF")
    #   # => 51
    #   ConsoleGlitter::ANSI.closest("F0F")
    #   # => 201
    #
    # Returns the appropriate escape code as a Fixnum.
    def closest(color)
      bpc = 4
      bpc *= 2 if color.length > 3
      color = color.to_i(16)

      blue = color % (1 << bpc)
      green = ((color - blue) % (1 << (bpc * 2))) >> bpc
      red = (color - (blue + green)) >> (bpc * 2)

      # 216 (6**3) colors are mapped in 256 color mode (40 colors are otherwise
      # reserved for normal and bold standard colors from 0x00 to 0x0f in
      # addition to a 24 color gradient from black to white from 0xe8 - 0xff.)
      [blue,green,red].each_with_index.map do |c,i|
        (c/(((1 << bpc)-1)/5)) * 6**i
      end.
      reduce(&:+) + 0x10
    end

    # Define most common ANSI sequences 
    ansi :reset,     0
    ansi :bold,      1
    ansi :faint,     2
    ansi :underline, 4
    ansi :blink,     5

    ansi :black,   30
    ansi :red,     31
    ansi :green,   32
    ansi :brown,   33
    ansi :blue,    34
    ansi :magenta, 35
    ansi :cyan,    36
    ansi :white,   37

    ansi :bg_black,   40
    ansi :bg_red,     41
    ansi :bg_green,   42
    ansi :bg_brown,   43
    ansi :bg_blue,    44
    ansi :bg_magenta, 45
    ansi :bg_cyan,    46
    ansi :bg_white,   47
  end
end
