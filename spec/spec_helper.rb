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


def mock_file(file, content="")
  file.path.stub!(:read).and_return(content)
  file.path.stub!(:read).with(3).and_return(content[0..2])
  file.path.stub!(:binary?).and_return(false) unless file.path.exist?
  file
end


