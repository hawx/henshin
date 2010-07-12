require File.join(File.dirname(__FILE__) ,'helper')

class TestGens < Test::Unit::TestCase
  context "A gen" do
    
    setup do
      @site = Henshin::Site.new(site_override)
      @index = "#{root_dir}/index.html"
      @sass = "#{root_dir}/css/screen.sass"
      remove_site
    end
    
    should "have yaml frontmatter read" do
      gen = Henshin::Gen.new(@index.to_p, @site)
      @site.read
      gen.read
      assert_equal 'Home Page', gen.data['title']
      assert_equal "main", gen.data['layout']
    end
    
    should "be rendered" do
      @site.read.process
      gen = Henshin::Gen.new(@index.to_p, @site)
      gen.read
      gen2 = Henshin::Gen.new(@index.to_p, @site)
      gen2.read
      gen2.render
      assert_not_equal gen.content, gen2.content
    end
    
    should "get output extension from plugin" do
      gen = Henshin::Gen.new(@sass.to_p, @site)
      gen.read
      gen.render
      assert_equal 'sass', gen.data['input']
      assert_equal 'css', gen.data['output']
    end
    
    should "render with correct layout" do
      @site.read.process
      gen = Henshin::Gen.new(@index.to_p, @site)
      # index.html should use 'main'
      gen.read
      gen.render
      l = File.open("#{root_dir}/layouts/main.html", 'r') {|f| f.read}
      assert_equal l, gen.data['layout']
    end
    
    should "have the correct permalink" do
      gen = Henshin::Gen.new(@index.to_p, @site)
      gen.read
      assert_equal '/index.html', gen.permalink
    end
    
    should "have the correct url" do
      gen = Henshin::Gen.new(@index.to_p, @site)
      gen.read
      assert_equal '/', gen.url
    end
    
    should "turn all data to hash" do
      gen = Henshin::Gen.new(@index.to_p, @site)
      gen.read
      assert gen.to_hash.is_a? Hash
    end
    
    should "insert optional payload" do
      gen = Henshin::Gen.new(@index.to_p, @site, {:name => 'test', :payload => {'data' => 'to_test'}})
      gen.read
      assert_equal 'to_test', gen.payload['test']['data']
    end
    
    should "be sortable" do
      gen = Henshin::Gen.new(@index.to_p, @site)
      gen2 = Henshin::Gen.new(@sass.to_p, @site)
      gens = [gen, gen2]
      assert_equal gens.reverse, gens.sort
    end
    
  end
end