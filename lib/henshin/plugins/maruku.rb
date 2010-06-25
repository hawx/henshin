require 'henshin/plugin'
require 'maruku'

class MarukuPlugin < Henshin::Generator
  
  def initialize( override={} )
    @extensions = {:input => ['markdown', 'mkdwn', 'md'],
                   :output => 'html'}
    @config = {}
    @priority = 5
  end
  
  def generate( content )
    Maruku.new(content).to_html
  end
  
  Henshin.register! self
end