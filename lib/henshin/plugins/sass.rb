require 'sass'

module Henshin
  class SassPlugin < Generator
    
    def initialize(site)
      @extensions = {:input => ['sass', 'scss'],
                     :output => 'css'}
      @config = {:ignore_layouts => true,
                 :style => :nested}
                 
      if site.config['sass']
        @config.merge!(site.config['sass'])
        @config['load_paths'] = Dir.glob((site.root + '*').to_s)
      end
      @priority = 5
    end
    
    def generate( content )
      Sass::Engine.new(content, @config).render
    end

  end
end