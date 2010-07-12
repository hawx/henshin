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
      mock($stderr).puts("-> can't convert String into Hash")
      
      assert_equal Henshin::Defaults, Henshin::Site.new.config
    end
    
    should "warn of no options.yaml" do
      mock(YAML).load_file(@opts) { raise "No such file or directory - #{@opts}" }
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> No such file or directory - #{@opts}")
      
      assert_equal Henshin::Defaults, Henshin::Site.new.config
    end

    should "use defaults if no options.yaml" do
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> No such file or directory - #{@opts}")
      
      assert_equal Henshin::Defaults, Henshin::Site.new.config
    end
    
    should "merge override with defaults" do
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> No such file or directory - #{@opts}")
    
      override = {'time_zone' => '+01:00'}
      site = Henshin::Site.new(override)
      assert_equal '+01:00', site.config['time_zone']
    end
    
    should "add special directories to exclude after loading" do
      mock($stderr).puts("\nCould not read configuration, falling back to defaults...")
      mock($stderr).puts("-> No such file or directory - #{@opts}")
      site = Henshin::Site.new
      to_ignore = ['/_site', '/plugins']
      assert_equal to_ignore, site.config['exclude']
      
      mock(YAML).load_file(@opts) { {'exclude' => ['/my_dir', 'my_file.txt']} }
      site2 = Henshin::Site.new
      to_ignore = ['/my_dir', 'my_file.txt', '/_site', '/plugins']
      assert_equal to_ignore, site2.config['exclude']
    end
    
    should "convert root, target to Pathnames" do
      site = Henshin::Site.new
      assert site.root.is_a? Pathname
      assert site.target.is_a? Pathname
    end
    
    should "set base" do
      site = Henshin::Site.new
      assert site.base
    end

  end
end