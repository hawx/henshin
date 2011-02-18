require_relative 'base'
require_relative 'file/page'

#%w(coffeescript erb haml liquid maruku redcloth sass).each do |l|
#  require_relative "filter/#{l}"
#end

require_relative 'engine/basic'

module Henshin
  class Site < Base
  
    include BasicRender
        
    ## Filters
    
    filter 'layouts/*.*', Layout, :internal
    filter '**/*.{liquid,md,mkd,markdown,erb,haml,textile}', Page
    
    ## Renders
    
    ## Others
    
    set :layout_paths, ['layouts/*.*', '**/layouts/*.*']
    
    ignore '_site/**', '**/_site/**' # sort these out!
    ignore '*.yml', '**/*.yml'
    
    after_each :write do |file|
      if file.can_write?
        puts "  #{'->'.green} #{file.write_path.to_s.grey}"
      end
    end
    
  end
end

Henshin.register 'site', Henshin::Site