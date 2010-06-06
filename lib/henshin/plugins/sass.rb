require 'henshin/plugin'
require 'sass'

class SassPlugin < Henshin::Generator
  
  attr_accessor :extensions, :config, :opts_name
  
  Defaults = {:ignore_layouts => true,
              :style => :nested}
  
  def initialize
    @extensions = {:input => ['sass', 'scss'],
                   :output => 'css'}
    @opts_name = :sass
  end
  
  def configure( override )
    override ? @config = Defaults.merge(override) : @config = Defaults
  end
  
  def generate( content )
    engine = Sass::Engine.new(content, config)
    output = engine.render
  end
  
  Henshin.register! self
end