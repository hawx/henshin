require File.join(File.dirname(__FILE__) ,'helper')

test_files = Dir.glob( File.join(File.dirname(__FILE__), "test_*.rb") )
test_files.each {|f| require f }