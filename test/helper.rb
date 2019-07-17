require 'test/unit'
require 'console-glitter'
require 'console-glitter/cursor'
require 'console-glitter/screen'
require 'console-glitter/ansi'

$LOAD_PATH.unshift File.dirname(__FILE__)

def expected_escape(value)
  RUBY_PLATFORM =~ /(^win)|mingw/i ? '' : value
end
