require File.join(File.dirname(__FILE__) ,'helper')

class TestSite < Test::Unit::TestCase

  # Test methods called within Site#initialize
  # except #configure which is tested in test_options
  context "A new site" do
  
    setup do
      @site = new_site
    end
    
    should "reset data" do
      @site.reset
      assert_equal [], @site.posts
      assert_equal [], @site.gens
      assert_equal [], @site.statics
      assert_equal [], @site.layouts
      assert @site.archive.size.zero?
      assert @site.tags.size.zero?
      assert @site.categories.size.zero?
    end
    
    should "load and sort plugins" do
      @site.plugins[:generators].each_value do |i|
        assert_is_a Henshin::Generator, i
      end
      
      @site.plugins[:layoutors].each_value do |i|
        assert_is_a Henshin::Layoutor, i
      end
    end
    
  end

  # Test methods called within Site#read
  context "Reading site" do
  
    setup do
      @site = new_site
    end

    should "read layouts" do
      @site.read_layouts
      l = Dir.glob( File.join(root_dir, 'layouts', '*.*') )
      assert_equal l.size, @site.layouts.size
    end
    
    should "read layouts first" do
      site = new_site
      site.read
      if mock.instance_of(Henshin::Site).read_posts
        assert site.layouts.size > 0
      end
      if mock.instance_of(Henshin::Site).read_gens
        assert site.layouts.size > 0
      end
      if mock.instance_of(Henshin::Site).read_statics
        assert site.layouts.size > 0
      end
    end
    
    should "read posts" do
      @site.read_posts
      p = Dir.glob( File.join(root_dir, 'posts', '**', '*.*') )
      assert_equal p.size, @site.posts.size
    end
    
    should "read gens" do
      @site.read_gens
      # For reference these are the gens
      # /css/print.sass
      # /index.html
      # /erb.html
      assert_equal 3, @site.gens.size
    end
    
    should "read statics" do
      @site.read_statics
      # For reference these are the static files:
      # /css/screen.css
      # /static.html
      assert_equal 2, @site.statics.size
    end
    
  end
  
  # Test methods called within Site#process
  context "Processing site" do
  
    setup do
      @site = new_site.read.process
    end
  
    should "process posts" do
      site = new_site
      site.read
      site2 = new_site
      site2.read.process
      assert_not_equal site.posts, site2.posts
    end
    
    should "process gens" do
      site = new_site
      site.read
      site2 = new_site
      site2.read.process
      assert_not_equal site.gens, site2.gens
    end
    
    should "sort posts" do
      assert_equal @site.posts, @site.posts.sort
    end
    
    should "sort gens" do
      assert_equal @site.gens, @site.gens.sort
    end
    
    should "build tags array" do
      # For reference these are the tags:
      # test: lorem-ipsum.markdown, same-date.markdown, Testing-Stuff.markdown, Textile-Test.textile
      # markdown: Testing-Stuff.markdown
      # lorem: lorem-ipsum.markdown, same-date.markdown
      # plugin: Textile-Test.textile
      assert_equal 4, @site.tags.size
      assert @site.tags[0].is_a? Henshin::Label
      assert_equal 'tag', @site.tags.base
    end
    
    should "build categories array" do
      # For reference these are the categories:
      # cat: cat/test.markdown
      # test: Testing-Stuff.markdown
      assert_equal 2, @site.categories.size
      assert @site.categories[0].is_a? Henshin::Label
      assert_equal 'category', @site.categories.base
    end
    
    should "build archives" do
      assert @site.archive.size > 0
    end
    
  end
  
  # Test methods called within Site#render
  context "Rendering site" do
    
    should "render posts" do
      site = new_site.read.process
      site2 = new_site.read.process.render
      assert_not_equal site.posts, site2.posts
    end
    
    should "render gens" do
      site = new_site.read.process
      site2 = new_site.read.process.render
      assert_not_equal site.gens, site2.gens
    end
    
    should "not render statics" do
      site = new_site
      site.read.process
      site2 = new_site
      site2.read.process.render
      assert_equal site.statics[0].content, site2.statics[0].content
    end
    
  end
  
  # Test methods called within Site#write
  context "Writing site" do
    
    setup do
      @site = new_site
      @site.read.process.render
    end
  
  end
  
end