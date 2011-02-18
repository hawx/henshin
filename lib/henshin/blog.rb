require 'henshin/base'

require 'henshin/file/page'
require 'henshin/file/archive'
require 'henshin/file/label'
require 'henshin/file/post'

%w(coffeescript erb haml liquid maruku redcloth sass).each do |l|
  require "henshin/filter/#{l}"
end


module Henshin
  
  # For this to be a Blog we need the following things:
  #
  #  - Posts
  #  - Tags & Categories
  #  - Archives
  #
  class Blog < Base

    #class_attr_accessor :actions => {}
    
    before :render do |site|
      archive = Archive.new(site.source + 'archive.html', site)
      
      site.posts.each do |post|
        archive << post
      end
      
      site.archive = archive
    end
    
    before :write do |site|
      site.archive.create_pages.each do |page|
        page.render
        page.write(site.write_path)
      end
    end
    
    include_filters ErbFilter, HamlFilter, MarukuFilter,
                    RedClothFilter, LiquidFilter, :using => Henshin::Page
    
    include_filters CoffeeScriptFilter, SassFilter, ScssFilter
    set :layout_paths, ['layouts/*.*', '**/layouts/*.*']
    ignore '_site/**', '**/_site/**'
    ignore '*.yml', '**/*.yml'
    attr_accessor :tags, :categories, :archive
    
    def posts
      self.files.find_all {|i| i.class.name =~ /Post/}
    end
    
    # Need some way of adding addresses and file references to henshin so that it will render
    # the tag pages correctly.
    #
    # @example Maybe Like?
    #
    #   resolve '/tags/index.html', @tags.render
    #   resolve '/tags/:name/index.html', @tags.find_tag(name)
    #
    # At the moment the block is passed the MatchData object and the site object.
    # This is probably not the best way but we'll see later.
    #
    
    Archive.create self
    
    Labels.define :tag, :tags, self
    Labels.define :category, :categories, self
    
  end
end

Henshin.register 'blog', Henshin::Blog