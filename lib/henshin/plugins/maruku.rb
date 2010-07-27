require 'maruku'

module Henshin
  class MarukuPlugin < Generator
    
    def initialize(site)
      @extensions = {:input => ['markdown', 'mkdwn', 'md'],
                     :output => 'html'}
      @config = {}
      @priority = 4
    end
    
    def generate( content )
      Maruku.new(content).to_html
    end
    
  end
end