require File.join(File.dirname(__FILE__) ,'helper')

class TestTags < Test::Unit::TestCase
  context "A tag" do
    
    setup do
      @site = new_site
      @site.read
      @site.process
    end
  
  end
end