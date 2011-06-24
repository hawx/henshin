$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)

require 'duvet'
Duvet.start :filter => 'lib/henshin'

require 'henshin'
require 'rspec'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |c|
  c.color_enabled = true
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end

# These get rid of text being printed! Remove if you want to debug
# stuff.
$_stdout = $stdout
$_stderr = $stderr
$stdout = StringIO.new
$stderr = StringIO.new

# Like p, but for debugging
def d(str)
  $_stdout.puts str.inspect
end
# Like puts
def duts(str)
  $_stdout.puts str
end
# Like print
def drint(str)
  $_stdout.print str
end
# Like warn
def darn(str)
  $_stderr.puts str
end

# Stubs a file with the content given.
def mock_file(file, content="")
  file.path.stub!(:read).and_return(content)
  file.path.stub!(:read).with(3).and_return(content[0..2])
  file
end


