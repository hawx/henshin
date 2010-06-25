require 'henshin/plugin'
require 'sass'

class SassPlugin < Henshin::Generator
  
  def initialize
    @extensions = {:input => ['sass', 'scss'],
                   :output => 'css'}
    @config = {:ignore_layouts => true,
               :style => :nested}
    @priority = 5
  end
  
  def configure( override, site )
    @config.merge!(override) if override
    @config[:load_paths] = Dir.glob( File.join(site[:root], '*') )
  end
  
  def generate( content )
    Sass::Engine.new(content, @config).render
  end
  
  Henshin.register! self, :sass
end