require 'henshin/plugin'
require 'maruku'

class MarukuPlugin < Henshin::HTMLGenerator
  
  attr_accessor :extensions
  
  def initialize
    @extensions = ['markdown', 'mkdwn', 'md']
  end
  
  def generate( content )
    Maruku.new(content).to_html
  end
  
end