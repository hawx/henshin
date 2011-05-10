require_relative 'base'
require_relative 'file/page'
require_relative 'engine/basic'

module Henshin
  class Site < Base
  
    include BasicRules
        
    ## Filters
    
    filter 'layouts/*.*', Layout, :internal
    filter '**/*.{liquid,md,mkd,markdown,erb,haml,textile}', Page
    
    ## Rules
    
    ## Others
    
    ignore '_site/**'
    ignore '*.yml'
    
    after_each :write do |file|
      if file.writeable?
        puts "  #{'->'.green} #{file.write_path.to_s.grey}"
      end
    end
    
  end
end

Henshin.register 'site', Henshin::Site