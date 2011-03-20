require 'henshin/base'

require 'henshin/file/page'
require 'henshin/file/archive'
require 'henshin/file/label'
require 'henshin/file/post'

require_relative 'engine/basic'

module Henshin
  
  # For this to be a Blog we need the following things:
  #
  #  - Posts
  #  - Tags & Categories
  #  - Archives
  #
  class Blog < Base
  
    include BasicRender
    
    ## Filters
    
    filter 'layouts/*.*', Layout, :internal
    filter 'posts/*.*', Post, :high
    filter '**/*.{liquid,md,mkd,markdown,erb,haml,textile}', Page
    
    ## Renders

    render 'posts/:title.*' do
      set :title, keys[:title]
    end
    
    render 'posts/:category/:title.*' do
      set :category, keys[:category]
      set :title, keys[:title]
    end
    
    render 'posts/:year/:month/:date/:title.*' do |y,m,d,t|
      set :date, Chronic.parse("#{y}/#{m}/#{d}")
      set :title, t
    end
    
    ## Others
    
    set :layout_paths, ['layouts/*.*', '**/layouts/*.*']
    
    ignore '_site/**'
    ignore '*.yml'
    
    after_each :write do |file|
      if file.writeable?
        puts "  #{'->'.green} #{file.write_path.to_s.grey}"
      end
    end

    def posts
      self.files.find_all {|i| i.class.name =~ /Post/}
    end
    
    Archive.create self
    
    Labels.define :tag, :tags, self
    Labels.define :category, :categories, self
    
  end
end

Henshin.register 'blog', Henshin::Blog