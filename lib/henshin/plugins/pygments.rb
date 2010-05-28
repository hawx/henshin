require 'henshin/plugin'

class PygmentsPlugin < Henshin::Generator
  
  attr_accessor :extensions
  
  def initialize
    @extensions = {:input => [],
                   :output => ''}
  end
  
  def generate( content )
  
  end
  
end