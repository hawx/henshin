require File.join(File.dirname(__FILE__) ,'helper')

class TestStatic < Test::Unit::TestCase
  context "A static" do
  
    should "be written to the same relative path" do
      site = new_site
      stat = Henshin::Static.new(site.root + "static.html", site)
      assert_equal Pathname.new("#{target_dir}/static.html"), stat.write_path
    end
  
  end
end