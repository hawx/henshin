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