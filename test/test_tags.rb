require File.join(File.dirname(__FILE__) ,'helper')

class TestTags < Test::Unit::TestCase
  context "A tag" do
    
    setup do
      @site = new_site
      @site.read
      @site.process
    end
    
    should "turn to hash" do
      assert @site.tags.to_hash.is_a? Hash
    end
    
    should "have a name" do
      @site.tags.each do |i, tag|
        assert tag.name != ''
      end
    end
    
    should "have a list of posts" do
      @site.tags.each do |i, tag|
        assert tag.posts.is_a? Array
        assert tag.posts[0].is_a? Henshin::Post
      end
    end
    
    should "have a url" do
      @site.tags.each do |i, tag|
        assert tag.url != ''
        assert tag.url.include? '/tags/'
      end
    end
    
  end
end