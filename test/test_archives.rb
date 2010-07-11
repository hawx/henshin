require File.join(File.dirname(__FILE__) ,'helper')

class TestArchives < Test::Unit::TestCase
  context "An archive" do
  
    setup do
      @site = new_site
      @site.read
      @site.process
    end
    
  end
end