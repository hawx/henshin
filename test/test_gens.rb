require File.join(File.dirname(__FILE__) ,'helper')

class TestGens < Test::Unit::TestCase
  context "A gen" do
    
    setup do
      @site = new_site
      @gen = Henshin::Gen.new "#{root_dir}/index.html", @site
      remove_site
    end
    
    should "have frontmatter read" do
      @site.read_layouts
      @gen.read_yaml
      assert_equal 'Home Page', @gen.title
      assert_equal File.open("#{root_dir}/layouts/main.html", "r"){|f| f.read}, @gen.layout
    end
    
    should "render with correct layout" do
      @site.read_layouts
      @gen.read_yaml
      # index.html uses 'layout: main'
      assert_equal File.open("#{root_dir}/layouts/main.html", "r"){|f| f.read}, @gen.layout
    end
    
    should "have the correct permalink and url" do
      @gen.read_yaml
      assert_equal '/index.html', @gen.permalink
      assert_equal '/', @gen.url
    end
    
    should "respond to #to_hash" do
      @gen.process
      assert_equal @gen.title, @gen.to_hash['title']
      assert_equal @gen.permalink, @gen.to_hash['permalink']
      assert_equal @gen.url, @gen.to_hash['url']
      assert_equal @gen.content, @gen.to_hash['content']
    end
    
    should "allow a hash to be added to the payload" do
      payload = { :name => 'people', :payload => {'fname' => 'John', 'sname' => 'Doe'} }
      gen = Henshin::Gen.new( "#{root_dir}/index.html", @site, payload )
      gen.read_yaml
      assert_equal payload[:payload], gen.payload['people']
    end
    
    should "be sortable" do
      another_gen = Henshin::Gen.new( "#{root_dir}/css/print.sass", @site )
      gen_array = [@gen, another_gen]
      assert_equal gen_array.reverse, gen_array.sort
    end
    
  end
end