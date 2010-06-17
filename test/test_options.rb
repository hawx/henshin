require File.join(File.dirname(__FILE__) ,'helper')

# Need to remember to remove loaded plugins from the returned
# config when comparing against Defaults!
class TestOptions < Test::Unit::TestCase
  context "Loading and setting options" do
    
    setup do
      @opts = './options.yaml'
    end
    
    should "warn of invalid options.yaml" do
      mock(YAML).load_file(@opts) {"boo"}
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> undefined method `to_options' for \"boo\":String")
      
      configured = Henshin.configure
      configured[:plugins] = ["maruku", "liquid"]
      assert_equal Henshin::Defaults, configured
    end
    
    should "warn of no options.yaml" do
      mock(YAML).load_file(@opts) { raise "No such file or directory - #{@opts}" }
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> No such file or directory - #{@opts}")
      
      configured = Henshin.configure
      configured[:plugins] = ["maruku", "liquid"]
      assert_equal Henshin::Defaults, configured
    end

    should "use defaults if no options.yaml" do
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> No such file or directory - #{@opts}")
    
      configured = Henshin.configure
      configured[:plugins] = ["maruku", "liquid"]
      assert_equal Henshin::Defaults, configured
    end
    
    should "merge override with defaults" do
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> No such file or directory - #{@opts}")
    
      override = {:time_zone => '+01:00'}
      configured = Henshin.configure(override)
      assert_equal '+01:00', configured[:time_zone]
    end
    
    should "load plugins" do    
      loaded = Henshin.load_plugins( ['maruku'], '.', {} )
      assert loaded[0].is_a? MarukuPlugin
    end

  end
end