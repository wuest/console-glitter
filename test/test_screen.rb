# typed: false
require 'helper'

class TestCursorMovement < Test::Unit::TestCase
  def test_screen_clear
    expected = { end:       expected_escape("\033[0J"),
                 beginning: expected_escape("\033[1J"),
                 both:      expected_escape("\033[2J") }

    expected.each do |method, result|
      explicit_call = "clear_to_#{method}"
      assert_equal(result, ConsoleGlitter::Screen.clear(method))
      assert_equal(result, ConsoleGlitter::Screen.clear_to(method))
      assert_equal(result, ConsoleGlitter::Screen.send(explicit_call))
    end

    assert_raises(ArgumentError) { ConsoleGlitter::Screen.clear(:nonexistent) }
  end

  def test_erase_line
    expected = { end:       expected_escape("\033[0K"),
                 beginning: expected_escape("\033[1K"),
                 both:      expected_escape("\033[2K") }

    expected.each do |method, result|
      explicit_call = "erase_line_to_#{method}"
      assert_equal(result, ConsoleGlitter::Screen.erase_line(method))
      assert_equal(result, ConsoleGlitter::Screen.erase_line_to(method))
      assert_equal(result, ConsoleGlitter::Screen.send(explicit_call))
    end

    assert_raises(ArgumentError) { ConsoleGlitter::Screen.clear(:nonexistent) }
  end

  def test_scrolling
    { scroll_up: 'S', scroll_down: 'T' }.each do |method, output|
      expected_single = expected_escape("\033[1#{output}")
      expected_double = expected_escape("\033[2#{output}")

      assert_equal(expected_single, ConsoleGlitter::Screen.send(method))
      assert_equal(expected_double, ConsoleGlitter::Screen.send(method, 2))
    end
  end
end
