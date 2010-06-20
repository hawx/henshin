require 'henshin/plugin'
require 'redcloth'

class TextilePlugin < Henshin::Generator
  
  attr_accessor :extensions, :config, :priority
  
  def initialize( override={} )
    @extensions = {:input => ['textile'],
                   :output => 'html'}
    @config = {}
    @priority = 5
  end
  
  def generate( content )
    RedCloth.new(content).to_html
  end
  
  Henshin.register! self
end