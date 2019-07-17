require 'console-glitter'

module ConsoleGlitter
  module Cursor extend self
    # Public: Move the cursor up for a given distance.
    #
    # distance  - Distance to move the cursor.
    #
    # Returns a String containing the VT control code.
    def up(distance = 1)
      ConsoleGlitter.escape("#{distance}A")
    end

    # Public: Move the cursor down for a given distance.
    #
    # distance  - Distance to move the cursor.
    #
    # Returns a String containing the VT control code.
    def down(distance = 1)
      ConsoleGlitter.escape("#{distance}B")
    end

    # Public: Move the cursor forward for a given distance.
    #
    # distance  - Distance to move the cursor.
    #
    # Returns a String containing the VT control code.
    def forward(distance = 1)
      ConsoleGlitter.escape("#{distance}C")
    end
    alias :right :forward

    # Public: Move the cursor back for a given distance.
    #
    # distance  - Distance to move the cursor.
    #
    # Returns a String containing the VT control code.
    def back(distance = 1)
      ConsoleGlitter.escape("#{distance}D")
    end
    alias :left :back

    # Public: Move the cursor to the next line, returning the cursor to the
    # beginning of the line.
    #
    # Returns a String containing the VT control code.
    def nextline(distance = 1)
      ConsoleGlitter.escape("#{distance}E")
    end

    # Public: Move the cursor to the previous line, returning the cursor to the
    # beginning of the line.
    #
    # Returns a String containing the VT control code.
    def prevline(distance = 1)
      ConsoleGlitter.escape("#{distance}F")
    end
    alias :previousline :prevline

    # Public: Move the absolute horizontal position specified.
    #
    # position - Number of the column to which the cursor should be moved.
    #
    # Returns a String containing the VT control code.
    def column(position)
      ConsoleGlitter.escape("#{position}G")
    end

    # Public: Move the cursor to the position specified.  The top left position
    # is 1,1.
    #
    # x - Column (x-position) to which the cursor should be moved.
    # x - Row (y-position) to which the cursor should be moved.
    #
    # Returns a String containing the VT control code.
    def move(x, y)
      ConsoleGlitter.escape("#{y};#{x}H")
    end

    # Public: Save the cursor's current position, replacing any previously
    # saved position.
    #
    # Returns a String containing the VT control code.
    def save
      ConsoleGlitter.escape("s")
    end

    # Public: Move the cursor to a previously saved position.
    #
    # Note: If the cursor's position was never previously saved, it will
    # default to 1,1.
    #
    # Returns a String containing the VT control code.
    def restore
      ConsoleGlitter.escape("u")
    end

    # Public: Hide the cursor.
    #
    # Returns a String containing the VT control code.
    def hide
      ConsoleGlitter.escape("?25l")
    end

    # Public: Show the cursor.
    #
    # Returns a String containing the VT control code.
    def show
      ConsoleGlitter.escape("?25h")
    end
  end
end
