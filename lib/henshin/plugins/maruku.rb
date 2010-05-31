require 'henshin/plugin'
require 'maruku'

class MarukuPlug < Henshin::Generator
  
  attr_accessor :extensions, :config
  
  Defaults = {}
  
  def initialize( override={} )
    @extensions = {:input => ['markdown', 'mkdwn', 'md'],
                   :output => 'html'}
    @config = Defaults.merge(override)
  end
  
  def generate( content )
    Maruku.new(content).to_html
  end
  
  Henshin.register! self
end