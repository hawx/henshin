require File.join(File.dirname(__FILE__) ,'helper')

class TestGens < Test::Unit::TestCase
  context "A gen" do
    
    setup do
      @site = new_site
      @gen = Henshin::Gen.new( "#{root_dir}/index.html", @site )
      remove_site
    end
    
    should "read frontmatter" do
      @site.read_layouts
      @gen.read_yaml
      assert_equal @gen.title, 'Home Page'
      assert_equal @gen.layout, "#{root_dir}/layouts/main.html"
    end
    
    should "render with correct layout" do
      @site.read_layouts
      @gen.read_yaml
      # index.html uses 'layout: main'
      assert_equal @gen.layout, "#{root_dir}/layouts/main.html"
    end
    
    should "have the correct permalink and url" do
      @gen.read_yaml
      assert_equal @gen.permalink, '/index.html'
      assert_equal @gen.url, '/'
    end
    
    should "respond to #to_hash" do
      @gen.process
      assert_equal @gen.to_hash['title'], @gen.title
      assert_equal @gen.to_hash['permalink'], @gen.permalink
      assert_equal @gen.to_hash['url'], @gen.url
      assert_equal @gen.to_hash['date'], @gen.date
      assert_equal @gen.to_hash['content'], @gen.content
    end
    
    should "allow a hash to be added to the payload" do
      payload = { :name => 'people', :payload => {'fname' => 'John', 'sname' => 'Doe'} }
      gen = Henshin::Gen.new( "#{root_dir}/index.html", @site, payload )
      gen.read_yaml
      assert_equal gen.payload['people'], payload[:payload]
    end
    
    should "be sortable" do
      another_gen = Henshin::Gen.new( "#{root_dir}/css/print.sass", @site )
      gen_array = [@gen, another_gen]
      assert_equal gen_array.sort, gen_array.reverse
    end
    
  end
end