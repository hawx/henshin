require 'henshin/plugin'
require 'liquid'

class LiquidPlugin < Henshin::LayoutParser

  attr_accessor :extensions
  
  def initialize
    @extensions = {:input => [],
                   :output => ''}
  end
  
  def generate( layout, data )
    if File.exists? layout
      t = Liquid::Template.parse( read(layout) ).render(data)
    else
      t = Liquid::Template.parse(layout).render(data)
    end
  end
  
  # returns the layout as a string
  def read( file )
    f = File.open(file, "r")
    r = ""
    f.each do |l|
      r << l
    end
    r
  end
  
  Henshin.register! self
end
