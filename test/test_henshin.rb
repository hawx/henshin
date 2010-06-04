require File.join(File.dirname(__FILE__) ,'helper')

class TestHenshin < Test::Unit::TestCase
  context "Building sites" do
  
    setup do
      @site = new_site
    end
    
    should "reset all data before anything else" do
      remove_site
      @site.reset
      
      assert_equal @site.posts.length, 0
      assert_equal @site.gens.length, 0
      assert_equal @site.statics.length, 0
      assert_equal @site.archive.length, 0
      assert_equal @site.tags.length, 0
      assert_equal @site.categories.length, 0
      assert_equal @site.layouts.length, 0
    end

  end
end


test_files = Dir.glob( File.join(File.dirname(__FILE__), "test_*.rb") )
test_files -= [File.join(File.dirname(__FILE__), 'test_henshin.rb')] # don't include self!
test_files.each {|f| require f }