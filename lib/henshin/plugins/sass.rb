require 'sass'

module Henshin
  class SassPlugin < Generator
    
    def initialize(site)
      @extensions = {:input => ['sass', 'scss'],
                     :output => 'css'}
      @config = {'ignore_layouts' => true,
                 'style' => :nested,
                 'load_paths' => Dir.glob((site.root + '*').to_s),
                 'syntax' => :sass}
  
      @config.merge!(site.config['sass']) if site.config['sass']
      
      @priority = 5
    end
    
    def generate( content )
      Sass::Engine.new(content, @config.to_options).render
    end

  end
end