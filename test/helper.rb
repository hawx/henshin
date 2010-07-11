require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'henshin'

class Test::Unit::TestCase

  include RR::Adapters::TestUnit
  
  def site_override
    {'root' => root_dir, 'target' => target_dir}
  end
  
  def root_dir
    File.join(File.dirname(__FILE__), 'site')
  end
  
  def target_dir
    File.join(root_dir, "_site")
  end

  def remove_site
    FileUtils.rm_rf(File.join(root_dir, target_dir))
  end
  
  def new_site
    Henshin::Site.new(site_override)
  end
  
end
