require File.join(File.dirname(__FILE__) ,'helper')

class TestGen < Test::Unit::TestCase
  context "A gen" do
    
    setup do
      @site = Henshin::Site.new(site_override).read.process
      @index = "#{root_dir}/index.html"
      @sass = "#{root_dir}/css/screen.sass"
      remove_site
    end
    
    def new_sass_gen 
      Henshin::Gen.new(@sass.to_p, @site)
    end
    
    def new_html_gen
      Henshin::Gen.new(@index.to_p, @site)
    end
    
    should "be have file data read" do
      gen = new_html_gen
      gen.read_file
      
      assert_equal 'Home Page', gen.data['title']
      assert_equal "main", gen.data['layout']
    end
    
    should "be rendered" do
      gen = new_html_gen
      gen.read
      gen2 = new_html_gen
      gen2.read
      gen2.render
      assert_not_equal gen.content, gen2.content
    end
    
    should "get output extension from plugin" do
      gen = new_sass_gen
      gen.read
      assert_equal 'sass', gen.data['input']
      assert_equal 'css', gen.data['output']
    end
    
    should "render with correct layout" do
      gen = new_html_gen
      # index.html should use 'main'
      gen.read
      gen.render
      l = File.open("#{root_dir}/layouts/main.html", 'r') {|f| f.read}
      assert_equal l, gen.data['layout']
    end
    
    should "have the correct permalink" do
      gen = new_html_gen
      gen.read
      assert_equal '/index.html', gen.permalink
    end
    
    should "have the correct url" do
      gen = new_html_gen
      gen.read
      assert_equal '/', gen.url
    end
    
    should "be written to the correct place" do
      gen = new_html_gen
      gen.read
      assert_equal "#{target_dir}/index.html".to_p, gen.write_path
    end
    
    should "write with the correct output" do
      gen = new_sass_gen
      gen.read
      assert_equal "#{target_dir}/css/screen.css".to_p, gen.write_path
    end
    
    should "turn all data to hash" do
      gen = new_html_gen
      gen.read
      assert gen.to_hash.is_a? Hash
    end
    
    should "insert optional payload" do
      gen = Henshin::Gen.new(@index.to_p, @site, {:name => 'test', :payload => {'data' => 'to_test'}})
      gen.read
      assert_equal 'to_test', gen.payload['test']['data']
    end
    
    should "be sortable" do
      gen = new_html_gen
      gen2 = new_sass_gen
      gens = [gen, gen2]
      assert_equal gens.reverse, gens.sort
    end
    
  end
end