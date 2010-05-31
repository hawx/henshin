require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'henshin'

class Test::Unit::TestCase

  def root_dir
    File.join(File.dirname(__FILE__), 'site')
  end
  
  def target_dir
    "_site"
  end

  def remove_site
    FileUtils.rm_rf(File.join(root_dir, target_dir))
  end
  
  def new_site
    override = {:root => File.join(File.dirname(__FILE__), 'site'),:target => '_site'}
    config = Henshin.configure(override)
    Henshin::Site.new(config)
  end
  
end
