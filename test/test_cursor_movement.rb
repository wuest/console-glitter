require 'helper'

class TestCursorMovement < Test::Unit::TestCase
  def test_directions
    directions = { up: 'A', down: 'B', forward: 'C', back: 'D' }

    directions.each do |k,v|
      expected_1 = expected_escape("\033[1#{v}")
      expected_2 = expected_escape("\033[2#{v}")

      assert_equal(expected_1, ConsoleGlitter::Cursor.send(k))
      assert_equal(expected_2, ConsoleGlitter::Cursor.send(k, 2))
    end
  end

  def test_line_skips
    line_movement = { nextline: 'E', prevline: 'F', previousline: 'F' }

    line_movement.each do |k,v|
      expected       = expected_escape("\033[1#{v}")
      expected_multi = expected_escape("\033[2#{v}")

      assert_equal(expected, ConsoleGlitter::Cursor.send(k))
      assert_equal(expected_multi, ConsoleGlitter::Cursor.send(k, 2))
    end
  end

  def test_movement
    x = 3
    y = 12
    column = expected_escape("\033[#{x}G")
    move   = expected_escape("\033[#{y};#{x}H")

    assert_equal(column, ConsoleGlitter::Cursor.column(x))
    assert_equal(move, ConsoleGlitter::Cursor.move(x,y))
  end

  def test_save_and_restore
    save    = expected_escape("\033[s")
    restore = expected_escape("\033[u")

    assert_equal(save, ConsoleGlitter::Cursor.save)
    assert_equal(restore, ConsoleGlitter::Cursor.restore)
  end

  def test_hide_and_show
    hide = expected_escape("\033[?25l")
    show = expected_escape("\033[?25h")

    assert_equal(hide, ConsoleGlitter::Cursor.hide)
    assert_equal(show, ConsoleGlitter::Cursor.show)
  end
end
