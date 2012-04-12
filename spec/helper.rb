$: << File.dirname(__FILE__) + '/..'

begin
  require 'duvet'
  Duvet.start :filter => 'lib/henshin'
rescue LoadError
  # Doesn't matter if duvet doesn't run
end

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha'
require 'lib/henshin'
