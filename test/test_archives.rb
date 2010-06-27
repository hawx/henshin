require File.join(File.dirname(__FILE__) ,'helper')

class TestArchives < Test::Unit::TestCase
  context "An archive" do
  
    setup do
      @site = new_site
      @site.read
      @site.process
    end
    
    should "turn to hash" do
      assert @site.archive.to_hash.is_a? Hash
      assert @site.archive.to_hash['2010'].has_key? 'posts'
      assert @site.archive.to_hash['2010']['5'].has_key? 'posts'
      assert @site.archive.to_hash['2010']['5']['15'].has_key? 'posts'
    end
    
    should "turn to hash of dates" do
      assert @site.archive.to_date_hash.is_a? Hash
      assert @site.archive.to_date_hash['2010']['5'].has_key? '15'
    end
    
    should "turn to hash of months" do
      assert @site.archive.to_month_hash.is_a? Hash
      assert @site.archive.to_month_hash['2010'].has_key? '5'
    end
    
    should "turn to hash of years" do
      assert @site.archive.to_year_hash.is_a? Hash
      assert @site.archive.to_year_hash.has_key? '2010'
    end
    
  end
end