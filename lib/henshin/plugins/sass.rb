require 'henshin/plugin'
require 'haml'
require 'sass/engine'

class SassPlugin < Henshin::CSSGenerator
  
  attr_accessor :extensions, :config
  
  Defaults = {:target => 'css',
              :root => 'sass',
              :file_type => 'css',
              :ignore_layouts => true,
              :style => :nested}
  
  def initialize( override={} )
    @extensions = ['sass', 'scss']
    @config = Defaults.merge(override)
  end
  
  def generate( content )
    engine = Sass::Engine.new(content, config)
    output = engine.render
  end
  
end