require 'redcloth'

module Henshin
  class TextilePlugin < Generator

    def initialize(site)
      @extensions = {:input => ['textile'],
                     :output => 'html'}
      @config = {}
      @priority = 5
    end
    
    def generate( content )
      RedCloth.new(content).to_html
    end
    
  end
end