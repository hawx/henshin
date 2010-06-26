require File.join(File.dirname(__FILE__) ,'helper')

class TestSite < Test::Unit::TestCase
  context "Building sites" do
  
    setup do
      @site = new_site
    end
    
    should "reset all data before anything else" do
      remove_site
      @site.reset
      
      assert_equal 0, @site.posts.length
      assert_equal 0, @site.gens.length
      assert_equal 0, @site.statics.length
      assert_equal 0, @site.tags.length
      assert_equal 0, @site.categories.length
      assert_equal 0, @site.layouts.length
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
    
    should "read static files" do
      @site.read_statics
      # For reference these are the static files:
      # /css/screen.css
      # /static.html
      assert_equal 2, @site.statics.size
    end
    
    should "read gens" do
      @site.read_gens
      # For reference these are the gens
      # /css/print.sass
      # /index.html
      assert_equal 2, @site.gens.size
    end
    
    should "have a payload" do
      assert @site.payload['site'].is_a? Hash
    end
    
    should "create tags" do
      @site.read
      @site.process
      # For reference these are the tags:
      # test: lorem-ipsum.markdown, same-date.markdown, Testing-Stuff.markdown, Textile-Test.textile
      # markdown: Testing-Stuff.markdown
      # lorem: lorem-ipsum.markdown, same-date.markdown
      # plugin: Textile-Test.textile
      assert_equal 4, @site.tags.size
      assert_equal 4, @site.tags['test'].posts.size
    end
    
    should "create categories" do
      @site.read
      @site.process
      # For reference these are the categories:
      # cat: cat/test.markdown
      # test: Testing-Stuff.markdown
      assert_equal 2, @site.categories.size
      assert_equal 1, @site.categories['cat'].posts.size
    end
    
    should "create archives" do
      @site.read
      @site.process
      assert @site.archive.is_a? Henshin::Archive
    end

  end
end