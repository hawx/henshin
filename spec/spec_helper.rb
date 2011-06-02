$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)

require 'duvet'
Duvet.start :filter => 'lib/henshin'

require 'henshin'
require 'rspec'

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


# Not the best example, but
#
#   it "is an array of Hashes" do
#     all_of(subject).should be_kind_of Hash
#   end
#
class AllOf
  def initialize(items)
    @items = items
  end
  
  def should(*args)
    @items.all? {|i| i.should(*args)}
  end
  
  def should_not(*args)
    @items.all? {|i| i.should_not(*args)}
  end
end

def all_of(items)
  AllOf.new(items)
end