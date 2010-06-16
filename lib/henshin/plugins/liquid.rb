require 'henshin/plugin'
require 'liquid'

class LiquidPlugin < Henshin::LayoutParser

  attr_accessor :extensions
  
  def initialize
    @extensions = {:input => [],
                   :output => ''}
  end
  
  def generate( layout, data )
    Liquid::Template.parse(layout).render(data)
  end
  
  Henshin.register! self
end
