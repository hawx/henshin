require File.join(File.dirname(__FILE__) ,'helper')

class TestSite < Test::Unit::TestCase
  context "Building sites" do
  
    setup do
      @site = new_site
    end
    
    should "reset all data before anything else" do
      remove_site
      @site.reset
      
      assert_equal @site.posts.length, 0
      assert_equal @site.gens.length, 0
      assert_equal @site.statics.length, 0
      assert_equal @site.archive.length, 0
      assert_equal @site.tags.length, 0
      assert_equal @site.categories.length, 0
      assert_equal @site.layouts.length, 0
    end
    
    should "read posts" do
      @site.read_posts
      p = Dir.glob( File.join(root_dir, 'posts', '**', '*.*') )
      assert_equal p.size, @site.posts.size
    end
    
    should "read layouts" do
      @site.read_layouts
      l = Dir.glob( File.join(root_dir, 'layouts', '*.*') )
      assert_equal l.size, @site.layouts.size
    end

  end
end