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
    
    should "have the correct permalink" do
      @gen.read_yaml
      assert_equal @gen.permalink, '/index.html'
      assert_equal @gen.url, '/'
    end
    
    should "allow a hash to be added to the payload" do
      payload = { :name => 'people', :payload => {'fname' => 'John', 'sname' => 'Doe'} }
      gen = Henshin::Gen.new( "#{root_dir}/index.html", @site, payload )
      gen.read_yaml
      assert_equal gen.payload['people'], payload[:payload]
    end
    
  end
end