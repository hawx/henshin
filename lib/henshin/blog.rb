require 'henshin/base'

require 'henshin/file/page'
require 'henshin/file/archive'
require 'henshin/file/label'
require 'henshin/file/post'

require 'henshin/rules/basic'

module Henshin
  
  # For this to be a Blog we need the following things:
  #
  #  - Posts
  #  - Tags & Categories
  #  - Archives
  #
  class Blog < Base
  
    include Rules::Basic
    
    ## Filters
    
    filter 'layouts/*.*', Layout, :internal
    filter 'posts/*.*', Post, :high
    filter '**/*.{liquid,md,mkd,markdown,erb,haml,textile}', Page
    
    ## Rules

    rule 'posts/:title.*' do
      set :title, title
    end
    
    rule 'posts/:category/:title.*' do
      set :category, category
      set :title,    title
    end
    
    rule 'posts/:year/:month/:date/:title.*' do
      set :date,  Time.new(year, month, date)
      set :title, title
    end
    
    ## Others
        
    ignore '_site/**'
    ignore '*.yml'
    
    after_each :write do |file|
      if file.writeable?
        puts "  #{'->'.green} #{file.write_path.to_s.grey}"
      end
    end

    # @return [Array[Henshin::Post]]
    #   Returns an array of all posts created.
    def posts
      self.files.find_all {|i| i.class.name =~ /Post/}
    end
    
    Archive.create self
    
    Labels.define :tag, :tags, self
    Labels.define :category, :categories, self
    
  end
end

Henshin.register 'blog', Henshin::Blog