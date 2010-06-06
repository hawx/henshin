require File.join(File.dirname(__FILE__) ,'helper')

class TestPosts < Test::Unit::TestCase
  context "A post" do
  
    setup do
      @site = new_site
      remove_site
    end
    
    should "get data from the filename" do
      post_file = "#{root_dir}/posts/2010-08-10-lorem-ipsum.markdown"
      site = @site
      site.config[:file_name] = "{date}-{title-with-dashes}.{extension}"
      post = Henshin::Post.new( post_file, site )
      post.read_name
      assert_equal post.title, 'lorem ipsum'
      assert_equal post.date, Time.parse('2010-08-10')
      assert_equal post.extension, 'markdown'
    end
    
    should "read frontmatter" do
      post_file = "#{root_dir}/posts/lorem-ipsum.markdown"
      post = Henshin::Post.new( post_file, @site )
      post.read_yaml
      assert_equal post.title, 'Lorem Ipsum'
      assert_equal post.date, Time.parse('2010-05-15 at 13:23:47')
      assert_equal post.tags, ['test', 'lorem']
    end
    
    should "have the correct permalink" do
      post_file = "#{root_dir}/posts/lorem-ipsum.markdown"
      post = Henshin::Post.new( post_file, @site )
      post.process
      assert_equal post.permalink, "/2010/5/15-lorem-ipsum/index.html"
    end
    
  end
end