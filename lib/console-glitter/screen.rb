require 'console-glitter'

module ConsoleGlitter
  module Screen extend self
    # Public: From the cursor's position clear either the whole screen, or from
    # the cursor's position to the beginning or end of the screen.
    #
    # direction - Symbol denoting the direction the screen should be cleared,
    #             between :both :end or :beginning.  (default: :both)
    #
    # Returns a String containing the VT control code.
    def clear(direction = :both)
      options = [:both, :beginning, :end]
      target  = "clear_to_#{direction}"
      return(self.send(target)) if options.grep(direction).any?

      raise(ArgumentError,
            "Expected :both, :end, or :beginning, got #{direction}.")
    end
    alias :clear_to :clear

    # Public: Return the VT control code to clear from the cursor to the end of
    # the screen.
    #
    # Returns a String containing the VT control code.
    def clear_to_end
      ConsoleGlitter.escape('0J')
    end

    # Public: Return the VT control code to clear from the cursor to the
    # beginning of the screen.
    #
    # Returns a String containing the VT control code.
    def clear_to_beginning
      ConsoleGlitter.escape('1J')
    end

    # Public: Return the VT control code to clear the screen.
    #
    # Returns a String containing the VT control code.
    def clear_to_both
      ConsoleGlitter.escape('2J')
    end
    alias :clear_screen :clear_to_both

    # Public: From the cursor's position clear either the whole line, or from
    # the cursor's position to the beginning or end of the line.
    #
    # direction - Symbol denoting the direction the line should be cleared,
    #             between :both :end or :beginning.  (default: :both)
    #
    # Returns a String containing the VT control code.
    def erase_line(direction = :both)
      options = [:both, :beginning, :end]
      target  = "erase_line_to_#{direction}"
      return(self.send(target)) if options.grep(direction).any?

      raise(ArgumentError,
            "Expected :both, :end, or :beginning, got #{direction}.")
    end
    alias :erase_line_to :erase_line

    # Public: Return the VT control code to clear from the cursor to the end of
    # the line.
    #
    # Returns a String containing the VT control code.
    def erase_line_to_end
      ConsoleGlitter.escape('0K')
    end

    # Public: Return the VT control code to clear from the cursor to the
    # beginning of the line.
    #
    # Returns a String containing the VT control code.
    def erase_line_to_beginning
      ConsoleGlitter.escape('1K')
    end

    # Public: Return the VT control code to clear the line where the cursor is.
    #
    # Returns a String containing the VT control code.
    def erase_line_to_both
      ConsoleGlitter.escape('2K')
    end

    # Public: Return the VT control code to scroll the screen up by a given
    # amount.
    #
    # distance - Number of lines to scroll the screen.  (default: 1)
    #
    # Returns a String containing the VT control code.
    def scroll_up(distance = 1)
      ConsoleGlitter.escape("#{distance}S")
    end

    # Public: Return the VT control code to scroll the screen down by a given
    # amount.
    #
    # distance - Number of lines to scroll the screen.  (default: 1)
    #
    # Returns a String containing the VT control code.
    def scroll_down(distance = 1)
      ConsoleGlitter.escape("#{distance}T")
    end
  end
end
