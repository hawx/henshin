require 'henshin/plugin'
require 'maruku'

class MarukuPlugin < Henshin::HTMLGenerator
  
  attr_accessor :extensions, :config
  
  Defaults = {}
  
  def initialize( override={} )
    @extensions = ['markdown', 'mkdwn', 'md']
    @config = Defaults.merge(override)
  end
  
  def generate( content )
    Maruku.new(content).to_html
  end
  
end