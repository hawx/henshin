require File.join(File.dirname(__FILE__) ,'helper')

class TestPosts < Test::Unit::TestCase
  context "A post" do
  
    setup do
      @site = new_site
      remove_site
    end
    
    should "read posts" do
      @site.read_posts
      p = Dir.glob( File.join(root_dir, 'posts', '**', '*.*') )
      assert_equal p.size, @site.posts.size
    end
    
  end
end