require 'henshin/plugin'
require 'sass'

class SassPlugin < Henshin::Generator
  
  attr_accessor :extensions, :config, :priority
  
  Defaults = {:ignore_layouts => true,
              :style => :nested}
  
  def initialize
    @extensions = {:input => ['sass', 'scss'],
                   :output => 'css'}
    @config = {:ignore_layouts => true,
               :style => :nested}
    @priority = 5
  end
  
  def configure( override )
    @config.merge!(override) if override
  end
  
  def generate( content )
    Sass::Engine.new(content, @config).render
  end
  
  Henshin.register! self, :sass
end