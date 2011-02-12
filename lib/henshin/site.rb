require_relative 'base'
require_relative 'file/page'

%w(coffeescript erb haml liquid maruku redcloth sass).each do |l|
  require_relative "filter/#{l}"
end

module Henshin
  class Site < Base
    
    include_filters ErbFilter, HamlFilter, MarukuFilter,
                    RedClothFilter, LiquidFilter, :using => Henshin::Page
    
    include_filters CoffeeScriptFilter, SassFilter, ScssFilter
    
    set :layout_paths, ['layouts/*.*', '**/layouts/*.*']
    
    ignore '_site/**', '**/_site/**'
    ignore '*.yml', '**/*.yml'
    
    
    after_each :write do |file|
      if file.can_write?
        puts "  #{'->'.green} #{file.write_path.to_s.grey}"
      end
    end
    
    
    class MarukuEngine
      def make(content, data)
        Maruku.new(content).to_html
      end
    end
    
    class LiquidEngine
      def make(content, data)
        
      end
    end
    
    class SassEngine
      def make(content, data)
        engine = Sass::Engine.new(content, :syntax => :sass)
        engine.render
      rescue NameError
        require 'sass'
        retry
      end
    end
    
    render '**/:title.liquid' do
      set :output, 'html'
      set :title, keys[:title]
      
      apply LiquidEngine
    end
    
    render '**/:title.markdown' do
      set :output, 'html'
      set :title, keys[:title]
      
      apply MarukuEngine
    end
    
    render '**/*.sass' do
      set :output, 'css'
      set :no_layout, true # would be better as +set :layout, false+
      
      apply SassEngine
    end
    
    filter 'layouts/*.*', Layout, :internal
    
  end
end

Henshin.register 'site', Henshin::Site