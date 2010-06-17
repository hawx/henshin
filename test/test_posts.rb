require File.join(File.dirname(__FILE__) ,'helper')

class TestPosts < Test::Unit::TestCase
  context "A post" do
  
    setup do
      @site = new_site
      @site.read
      @site.process
      @post = Henshin::Post.new( "#{root_dir}/posts/lorem-ipsum.markdown", @site )
      remove_site
    end
    
    should "get data from the filename" do
      post_file = "#{root_dir}/posts/2010-08-10-lorem-ipsum.markdown"
      site = @site
      site.config[:file_name] = "{date}-{title-with-dashes}.{extension}"
      post = Henshin::Post.new( post_file, site )
      post.read_name
      assert_equal 'Lorem Ipsum', post.title
      assert_equal Time.parse('2010-08-10'), post.date
      assert_equal 'markdown', post.extension
    end
    
    should "get category from folder" do
      post_file = "#{root_dir}/posts/category/test-post.markdown"
      post = Henshin::Post.new( post_file, @site )
      post.read_name
      assert_equal 'category', post.category
    end
    
    should "render with correct layout" do
      @post.process
      # lorem-ipsum.markdown uses default 'layout: post'
      assert_equal File.open("#{root_dir}/layouts/post.html"){|f| f.read} , @post.layout
    end
    
    should "read frontmatter" do
      @post.read_yaml
      assert_equal 'Lorem Ipsum', @post.title
      assert_equal Time.parse('2010-05-15 at 13:23:47'), @post.date
      assert_equal ['test', 'lorem'], @post.tags
    end
    
    should "have the correct permalink and url" do
      @post.process
      assert_equal "/2010/5/15/lorem-ipsum/index.html", @post.permalink
      assert_equal "/2010/5/15/lorem-ipsum/", @post.url
    end
    
    should "respond to #to_hash" do
      @post.process
      assert_equal @post.title, @post.to_hash['title']
      assert_equal @post.author, @post.to_hash['author']
      assert_equal @post.permalink, @post.to_hash['permalink']
      assert_equal @post.url, @post.to_hash['url']
      assert_equal @post.date, @post.to_hash['date']
      assert_equal @post.category, @post.to_hash['category']
      assert_equal @post.tags, @post.to_hash['tags']
      assert_equal @post.content, @post.to_hash['content']
    end
    
    should "be sortable" do
      another_post = Henshin::Post.new( "#{root_dir}/posts/Testing-Stuff.markdown", @site )
      post_array = [@post, another_post]
      assert_equal post_array.reverse, post_array.sort
    end
    
    should "sort by url if dates are same" do
      another_post = Henshin::Post.new( "#{root_dir}/posts/same-date.markdown", @site )
      post_array = [@post, another_post]
      assert_equal post_array.reverse, post_array.sort
    end
    
  end
end