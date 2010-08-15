require File.join(File.dirname(__FILE__) ,'helper')

class TestStatic < Test::Unit::TestCase
  context "A static" do
    
    setup do
      @site = new_site
      @static = Henshin::Static.new(@site.root + "static.html", @site)
    end
    
    should "have content" do
      assert <<EOS, @static.content
<!DOCTYPE html>  
<html lang="en">  
  <head>  
    <meta charset="utf-8" />  
    <title></title>  
    <link rel="stylesheet" href="" type="text/css" />  
  </head>  
  <body>  
    
    
    <header>
    	<h1>This should just be copied over</h1>
    </header>
    
    <p>I should be in the root folder! No templates or anything</p>
  </body>  
</html> 
EOS
    end
    
    should "have a path" do
      assert_equal @site.root+"static.html", @static.path
    end
    
    should "have a site" do
      assert_equal @site, @static.site
    end
    
    should "be written to the same relative path" do
      assert_equal Pathname.new("#{target_dir}/static.html"), @static.write_path
    end
    
  end
end