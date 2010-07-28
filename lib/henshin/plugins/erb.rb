require 'erb'
require 'ostruct'

module Henshin
  class ERBPlugin < Layoutor
    
    def initialize(site)
      @extensions = {:input => ['erb', 'rhtml']}
      @config = {}
      @priority = 4
    end
    
    # @see http://refactormycode.com/codes/281-given-a-hash-of-variables-render-an-erb-template
    def generate(content, data)
      data = OpenStruct.new(data)
      ERB.new(content).result(data.send(:binding))
    end
      
  end
end
