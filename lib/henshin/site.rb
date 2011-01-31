require 'henshin/base'
require 'henshin/file/page'

%w(coffeescript erb haml liquid maruku redcloth sass).each do |l|
  require "henshin/filter/#{l}"
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
      puts file.path.to_s
    end
    
  end
end
