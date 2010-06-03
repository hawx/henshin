require 'henshin/plugin'
require 'sass'

class SassPlugin < Henshin::Generator
  
  attr_accessor :extensions, :config
  
  Defaults = {:ignore_layouts => true,
              :style => :nested}
  
  def initialize( override={} )
    @extensions = {:input => ['sass', 'scss'],
                   :output => 'css'}
    @config = Defaults.merge(override)
  end
  
  def generate( content )
    engine = Sass::Engine.new(content, config)
    output = engine.render
  end
  
  Henshin.register! self
end