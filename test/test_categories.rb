require File.join(File.dirname(__FILE__) ,'helper')

class TestCategories < Test::Unit::TestCase
  context "A category" do
    
    setup do
      @site = new_site
      @site.read
      @site.process
    end
    
    should "turn to hash" do
      assert @site.categories.to_hash.is_a? Hash
    end
    
    should "have a name" do
      @site.categories.each do |i, cat|
        assert cat.name != ''
      end
    end
    
    should "have a list of posts" do
      @site.categories.each do |i, cat|
        assert cat.posts.is_a? Array
        assert cat.posts[0].is_a? Henshin::Post
      end
    end
    
    should "have a url" do
      @site.categories.each do |i, cat|
        assert cat.url != ''
        assert cat.url.include? '/categories/'
      end
    end
    
  end
end