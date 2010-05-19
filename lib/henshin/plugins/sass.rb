require 'henshin/plugin'
require 'sass'

class SassPlugin < Henshin::CSSGenerator
  
  attr_accessor :extensions
  
  def initialize
    @extensions = ['sass', 'scss']
  end
  
  def generate( content )
    # need to override this
  end
  
end