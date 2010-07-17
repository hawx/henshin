require File.join(File.dirname(__FILE__) ,'helper')

class TestSite < Test::Unit::TestCase
  context "A new site" do
    
    should "reset data" do
      site = new_site
      site.reset
      assert_equal [], site.posts
      assert_equal [], site.gens
      assert_equal [], site.statics
      assert_equal Hash.new, site.layouts
      assert site.archive.size.zero?
      assert site.tags.size.zero?
      assert site.categories.size.zero?
    end
    
    should "load and sort plugins" do
      site = new_site
      
      site.plugins[:generators].each_value do |i|
        assert_is_a Henshin::Generator, i
      end
      
      site.plugins[:layoutors].each do |i|
        assert_is_a Henshin::Layoutor, i
      end
    end
    
  end


  context "Reading site" do

    should "read layouts" do
      site = new_site
      site.read_layouts
      l = Dir.glob( File.join(root_dir, 'layouts', '*.*') )
      assert_equal l.size, site.layouts.size
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
      site = new_site
      site.read_posts
      p = Dir.glob( File.join(root_dir, 'posts', '**', '*.*') )
      assert_equal p.size, site.posts.size
    end
    
    should "read gens" do
      site = new_site
      site.read_gens
      # For reference these are the gens
      # /css/print.sass
      # /index.html
      assert_equal 2, site.gens.size
    end
    
    should "read statics" do
      site = new_site
      site.read_statics
      # For reference these are the static files:
      # /css/screen.css
      # /static.html
      assert_equal 2, site.statics.size
    end
    
  end
  
  context "Processing site" do
  
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
      site = new_site
      site.read.process
      assert_equal site.posts, site.posts.sort
    end
    
    should "sort gens" do
      site = new_site
      site.read.process
      assert_equal site.gens, site.gens.sort
    end
    
    should "build tags array" do
      site = new_site
      site.read.process
      # For reference these are the tags:
      # test: lorem-ipsum.markdown, same-date.markdown, Testing-Stuff.markdown, Textile-Test.textile
      # markdown: Testing-Stuff.markdown
      # lorem: lorem-ipsum.markdown, same-date.markdown
      # plugin: Textile-Test.textile
      assert_equal 4, site.tags.size
      assert site.tags[0].is_a? Henshin::Label
      assert_equal 'tag', site.tags.base
    end
    
    should "build categories array" do
      site = new_site
      site.read.process
      # For reference these are the categories:
      # cat: cat/test.markdown
      # test: Testing-Stuff.markdown
      assert_equal 2, site.categories.size
      assert site.categories[0].is_a? Henshin::Label
      assert_equal 'category', site.categories.base
    end
    
    should "build archives" do
      site = new_site
      site.read.process
      assert site.archive.size > 0
    end
    
  end
  
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
  
  context "Writing site" do
  
    should "write posts" do
      
    end
    
    should "write gens" do
    
    end
    
    should "write statics" do
    
    end
    
    should "write tags" do
    
    end
    
    should "write categories" do
    
    end
    
    should "write archive" do
    
    end
  
  end
  
end