require File.join(File.dirname(__FILE__) ,'helper')

class TestPost < Test::Unit::TestCase
  context "A post" do
  
    setup do
      @site = new_site
      @path = "#{root_dir}/posts/lorem-ipsum.markdown"
      @post = Henshin::Post.new(@path.to_p, @site)
      @path2 = "#{root_dir}/posts/Testing-Stuff.markdown"
      @post2 = Henshin::Post.new(@path2.to_p, @site)
      @site.posts = [@post, @post2]
    end
    
    should "get data from filename" do
      @post.read_name
      assert_equal 'Lorem Ipsum', @post.data['title']
      assert_equal 'markdown', @post.data['input']
    end
    
    should "turn date to Time object" do
      @post.read
      assert_instance_of Time, @post.data['date']
    end
    
    should "get next post" do
      assert_equal @post2, @post.next
    end
    
    should "get previous post" do
      assert_equal @post, @post2.prev
    end
    
    should "have correct permalink" do
      @post.read
      assert_equal '/2010/5/15/lorem-ipsum/index.html', @post.permalink
    end
    
    should "have correct url" do
      @post.read
      @post.render
      assert_equal '/2010/5/15/lorem-ipsum', @post.url
    end
    
    should "be written to the correct place" do
      @post.read
      path = Pathname.new("#{root_dir}/_site/2010/5/15/lorem-ipsum/index.html")
      assert_equal path, @post.write_path
    end
    
    should "be sortable" do
      @post.read
      assert_equal @post <=> @post2, -1
    end
    
  end
end