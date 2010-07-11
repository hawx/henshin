require File.join(File.dirname(__FILE__) ,'helper')

class TestPosts < Test::Unit::TestCase
  context "A post" do
  
    setup do
      @site = Henshin::Site.new(site_override)
      @post_with_date = "#{root_dir}/posts/2010-08-10-lorem-ipsum.markdown"
      @post = "#{root_dir}/posts/lorem-ipsum.markdown"
      remove_site
    end
    
    should "get data from filename" do
      site = @site.dup
      site.config['file_name'] = "{date}-{title-with-dashes}.{extension}"
      post = Henshin::Post.new(@post_with_date.to_p, site)
      post.read_name
      assert_equal 'Lorem Ipsum', post.data['title']
      assert_equal '2010-08-10', post.data['date']
      assert_equal 'markdown', post.data['input']
    end
    
    should "turn date to Time object" do
      post = Henshin::Post.new(@post.to_p, @site)
      post.process
      assert post.data['date'].is_a? Time
    end
    
    should "get next post" do
      
    end
    
    should "get previous post" do
    
    end
    
    should "have correct permalink" do
      post = Henshin::Post.new(@post_with_date.to_p, @site)
      post.read_name
      p post.permalink
    end
    
    should "have correct url" do
    
    end
    
    should "be sortable" do
    
    end
    
  end
end