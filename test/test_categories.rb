require File.join(File.dirname(__FILE__) ,'helper')

class TestCategories < Test::Unit::TestCase
  context "A category" do
    
    setup do
      @site = new_site
      @site.read
      @site.process
    end
    
  end
end