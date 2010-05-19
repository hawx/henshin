require 'henshin/plugin'

class PygmentsPlugin < Henshin::HTMLGenerator
  
  attr_accessor :extensions
  
  def initialize
    @extensions = ['hmm']
  end
  
  def generate( content )
  
  end
  
end