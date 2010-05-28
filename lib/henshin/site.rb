module Henshin

  class Site
  
    attr_accessor :posts, :gens, :statics, :archive, :tags, :categories, :plugins
    attr_accessor :layouts, :config
    
    def initialize( config )
      self.reset
      @config = config
    end
    
    # Resets everything
    def reset
      @posts = []
      @gens = []
      @statics = []
      @archive = {}
      @tags = Hash.new { |h, k| h[k] = Tag.new(k) }
      @categories = Hash.new { |h, k| h[k] = Category.new(k) }
      @layouts = {}
    end
    
    
    ##
    # Reads all necessary files and puts them into the necessary arrays
    #
    def read
      self.read_layouts
      self.read_posts
      self.read_others
    end
    
    # Adds all items in 'layouts' to the layouts array
    def read_layouts
      path = File.join(config[:root], 'layouts')
      Dir.glob(path + '/*.*').each do |layout|
        layout =~ /([a-zA-Z0-9 _-]+)\.([a-zA-Z0-9-]+)/
        @layouts[$1] = layout
      end
    end
    
    # Adds all items in 'posts' to the posts array
    def read_posts
      path = File.join(config[:root], 'posts')
      Dir.glob(path + '/**/*.*').each do |post|
        @posts << Post.new(post, self)
      end
    end
    
    # Gets all other items, and determines whether it's static or needs to be converted
    def read_others
      path = File.join(config[:root], '**', '*.*')
      items = Dir.glob(path)
      
      ['/_site', '/plugins'].each do |r|
        items = items.select {|i| !i.include?( File.join(config[:root], r) )}
      end
      
      ignored = ['/options.yaml'] + config[:exclude]
      ignored.each do |r|
        items -= [File.join(config[:root], r)]
        items -= items.select {|i| i.include?( File.join(config[:root], r) )}
      end
      
      items -= @posts.collect {|i| i.path}
      items -= @layouts.collect {|k, v| v}
      
      gens = items.select {|i| config[:extensions].include?(i.extension) }
      gens += items.select {|i| File.open(i, "r").read(3) == "---" }
      
      gens.each do |g|
        @gens << Gen.new(g, self)
      end
      
      
      static = items - @gens.collect {|i| i.path}
      static.each do |s|
        @statics << Static.new(s, self)
      end
    end
    
    
    ## 
    # Processes all of the necessary files
    def process
      @posts.each_parallel {|p| p.process}
      @gens.each_parallel {|g| g.process}
      
      self.build_tags
      self.build_categories
      self.build_archive
    end
    
    # @return [Hash] the payload for the layout engine
    def payload
      {
        'site' => {
          'author' => @config[:author],
          'title' => @config[:title],
          'description' => @config[:description],
          'time_zone' => @config[:time_zone],
          'created_at' => Time.now,
          'posts' => @posts.collect {|i| i.to_hash},
          'tags' => @tags.collect {|k, t| t.to_hash},
          'categories' => @categories.collect {|k, t| t.to_hash},
          'archive' => @archive
        } 
      }
    end
    
    # Creates tags from posts and adds them to @tags
    def build_tags
      @posts.each do |p|
        p.tags.each do |t|
          @tags[t].posts << p
        end
      end
    end
    
    # Create categories from posts and add to @categories
    def build_categories
      @posts.each do |p|
        @categories[p.category].posts << p unless p.category.nil?
      end
    end
    
    # @return [Hash] archive hash
    def build_archive
      {
        '2010' => {
          '01' => [
            {'post' => 'hash'},
            {'post' => 'hash'}
          ]
        }
      }
    end
    
    ##
    # Renders the files
    def render
      @posts.each_parallel {|p| p.render}
      @gens.each_parallel {|g| g.render}
    end
    
    
    ##
    # Writes the files
    def write
      @posts.each_parallel {|p| p.write}
      @gens.each_parallel {|g| g.write}
      @statics.each_parallel {|s| s.write}
      
      self.write_tags
      self.write_categories
    end
    
    
    def write_tags
      if @layouts['tag_index']
        write_path = File.join( config[:root], 'tags', 'index.html' )
      
        tag_index = Gen.new(write_path, self)
        tag_index.layout = @layouts['tag_index']
        
        tag_index.render
        tag_index.write
      end
    end
    
    def write_categories
      if @layouts['category_index']
        write_path = File.join( config[:root], 'categories', 'index.html' )
        
        category_index = Gen.new(write_path, self)
        category_index.layout = @layouts['category_index']
        
        category_index.render
        category_index.write
      end
    end
  
  end

end