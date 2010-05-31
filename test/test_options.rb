require File.join(File.dirname(__FILE__) ,'helper')

class TestOptions < Test::Unit::TestCase
  context "Loading and setting options" do
    
    setup do
      @opts = File.join(root_dir, 'options.yaml')
    end
    
    should "warn of invalid options.yaml" do
    
    end
    
    should "warn of no options.yaml" do
    
    end
    
    should "use defaults if no options.yaml" do
      assert_equal Henshin::Defaults, Henshin.configure
    end
    
    should "load options and merge with defaults" do
    
    end
  
  end
end