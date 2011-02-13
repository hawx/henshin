require_relative 'base'
require_relative 'file/page'

#%w(coffeescript erb haml liquid maruku redcloth sass).each do |l|
#  require_relative "filter/#{l}"
#end

require_relative 'filter/basic'

module Henshin
  class Site < Base
  
    include BasicRender
        
    ## Filters
    
    filter 'layouts/*.*', Layout, :internal
    filter '**/*.(liquid|md|mkd|markdown|erb|haml|textile)', Page
    
    ## Renders
    
    render '**/:title.liquid' do
      set :output, 'html'
      set :title, keys[:title]
    end
    
    render '**/:title.(md|mkd|markdown)' do
      set :output, 'html'
      set :title, keys[:title]
    end
    
    render '**/*.sass' do
      set :output, 'css'
      set :layout, false # would be better as +set :layout, false+
    end
    
    render '**/*.scss' do
      set :output, 'css'
      set :layout, false
    end
    
    render '**/*.coffee' do
      set :output, 'js'
      set :layout, false
    end
    
    ## Others
    
    set :layout_paths, ['layouts/*.*', '**/layouts/*.*']
    
    ignore '_site/**', '**/_site/**'
    ignore '*.yml', '**/*.yml'
    
    after_each :write do |file|
      if file.can_write?
        puts "  #{'->'.green} #{file.write_path.to_s.grey}"
      end
    end
    
  end
end

Henshin.register 'site', Henshin::Site