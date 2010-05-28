require 'henshin/plugin'
require 'haml'
require 'sass/engine'

class SassPlugin < Henshin::Generator
  
  attr_accessor :extensions, :config
  
  Defaults = {:target => 'css',
              :root => 'sass',
              :ignore_layouts => true,
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
  
end