require 'henshin/base'
require 'henshin/file/page'
require 'henshin/rules/basic'

module Henshin
  class Site < Base
  
    include Rules::Basic
        
    ## Filters
    
    filter 'layouts/*.*', File::Layout, :internal
    filter '**/*.{liquid,md,mkd,markdown,erb,haml,textile}', File::Page
    
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