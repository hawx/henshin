$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)

#require 'duvet'
#Duvet.start :filter => 'lib/henshin'

require 'henshin'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
  
  config.before(:each) do
  end
end