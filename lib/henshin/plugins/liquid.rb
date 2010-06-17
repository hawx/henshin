require 'henshin/plugin'
require 'liquid'

class LiquidPlugin < Henshin::LayoutParser

  attr_accessor :extensions
  
  def initialize
    @extensions = {:input => [],
                   :output => ''}
  end
  
  def generate( layout, data )
    Liquid::Template.parse(layout).render(data, {:filters => [Filters]})
  end
  
  module Filters
  
    def date_to_string(dt)
      dt.strftime "%d %b %Y"
    end
    
    def date_to_long(dt)
      dt.strftime "%d %B %Y at %H:%M"
    end
  
    def time_to_string(dt)
      dt.strtime "%H:%M"
    end
    
    def titlecase(str)
      str.upcase
    end
    
    def escape(str)
      CGI::escape str
    end
    
    def escape_html(str)
      CGI::escapeHTML str
    end
  
  end
  
  Henshin.register! self
end

