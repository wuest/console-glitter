# typed: false
require 'helper'

class TestColorEscapes < Test::Unit::TestCase
  def test_literal_codes
    # VT100 color codes
    colors = [:black, :red, :green, :brown, :blue, :magenta, :cyan, :white]

    colors.each_with_index do |c,i|
      expected = expected_escape("\033[#{30 + i}m")
      assert_equal(expected, ConsoleGlitter::ANSI.send(c))
    end
  end

  def test_ansi_block_syntax
    block_result = ConsoleGlitter::ANSI.red() { "test" }
    red = expected_escape("\033[31m")
    reset = expected_escape("\033[0m")
    expected = "#{red}test#{reset}"

    assert_equal(expected, block_result)
  end

  def test_closest_match_8bpc
    codes = {"000000" => 16,
             "0000FF" => 21,
             "00FF00" => 46,
             "FF0000" => 196,
             "00FFFF" => 51,
             "FF00FF" => 201,
             "FFFF00" => 226,
             "FFFFFF" => 231
             }

    codes.each do |k,v|
      expected_fg = expected_escape("\033[38;5;#{v}m")
      expected_bg = expected_escape("\033[48;5;#{v}m")

      assert_equal(expected_fg, ConsoleGlitter::ANSI.hex_color(k))
      assert_equal(expected_bg, ConsoleGlitter::ANSI.bg_hex_color(k))
    end
  end

  def test_closest_match_4bpc
    codes = {"000" => 16,
             "00F" => 21,
             "0F0" => 46,
             "F00" => 196,
             "0FF" => 51,
             "F0F" => 201,
             "FF0" => 226,
             "FFF" => 231
             }

    codes.each do |k,v|
      expected_fg = expected_escape("\033[38;5;#{v}m")
      expected_bg = expected_escape("\033[48;5;#{v}m")

      assert_equal(expected_fg, ConsoleGlitter::ANSI.hex_color(k))
      assert_equal(expected_bg, ConsoleGlitter::ANSI.bg_hex_color(k))
    end
  end
end
