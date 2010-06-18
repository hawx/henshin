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
    @config = {:ignore_layouts => true,
               :style => :nested}
  end
  
  def configure( override )
    @config.merge!(override) if override
  end
  
  def generate( content )
    Sass::Engine.new(content, @config).render
  end
  
  Henshin.register! self
end