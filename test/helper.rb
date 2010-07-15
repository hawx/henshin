require 'test/unit'
require 'shoulda'
require 'rr'

require File.dirname(__FILE__) + '/../lib/henshin'

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
  
  
  
  # Determines whether +instance+ is a +klass+ using #is_a?. 
  # This is similar to assert_instance_of except it doesn't 
  # have to be an instance of +klass+ just an instance of a 
  # decendant of +klass+.
  #
  # @param [Class] klass the klass to test for
  # @param [Object] instance of the object to test
  def assert_is_a(klass, instance)
    assert instance.is_a?(klass), "Expected #{instance} to be a #{klass}"
  end
  
end
