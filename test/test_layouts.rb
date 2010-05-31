require File.join(File.dirname(__FILE__) ,'helper')

class TestLayouts < Test::Unit::TestCase
  context "A layout" do
  
    setup do
      @site = new_site
      remove_site
    end
    
    should "read layouts" do
      @site.read_layouts
      l = Dir.glob( File.join(root_dir, 'layouts', '*.*') )
      assert_equal l.size, @site.layouts.size
    end
  
  end
end