$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)

require 'duvet'
Duvet.start :filter => 'lib/henshin'

require 'henshin'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
  
  config.before(:each) do
  end
end

def mock_file(file, content="")
  file.path.stub!(:read).and_return(content)
  file.stub!(:has_yaml?).and_return { content[0..2] == "---" ? true : false }
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