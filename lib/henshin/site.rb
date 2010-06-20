module Henshin

  class Site
  
    attr_accessor :posts, :gens, :statics, :archive, :tags, :categories
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
      
      @archive = Archive.new( self )
      @tags = Hash.new { |h, k| h[k] = Tag.new(k) }
      @categories = Hash.new { |h, k| h[k] = Category.new(k) }
      
      @layouts = {}
    end
    
    
    ##
    # Read, process, render and write everything
    def build
      self.reset
      self.read
      self.process
      self.render
      self.write
    end
    
    
    ##
    # Reads all necessary files and puts them into the necessary arrays
    def read
      self.read_layouts
      self.read_posts
      self.read_gens
      self.read_statics
    end
    
    # Adds all items in 'layouts' to the layouts array
    def read_layouts
      path = File.join(@config[:root], 'layouts')
      Dir.glob(path + '/*.*').each do |layout|
        layout =~ /([a-zA-Z0-9 _-]+)\.([a-zA-Z0-9-]+)/
        @layouts[$1] = File.open(layout, 'r') {|f| f.read}
      end
    end
    
    # Adds all items in 'posts' to the posts array
    def read_posts
      path = File.join(@config[:root], 'posts')
      Dir.glob(path + '/**/*.*').each do |post|
        @posts << Post.new(post, self)
      end
    end
    
    # Adds all files that need to be run through a plugin in an array
    def read_gens
      files = Dir.glob( File.join(@config[:root], '**', '*.*') )
      gens = files.select {|i| gen?(i) }
      gens.each do |g|
        @gens << Gen.new(g, self)
      end
    end
    
    # Adds all static files to an array
    def read_statics
      files = Dir.glob( File.join(@config[:root], '**', '*.*') )
      static = files.select {|i| static?(i) }
      static.each do |s|
        @statics << Static.new(s, self)
      end
    end

    
    ## 
    # Processes all of the necessary files
    def process
      @posts.each_parallel {|p| p.process}
      @posts.sort!
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
          'posts' => @posts.collect{|i| i.to_hash},
          'tags' => @tags.collect {|k, t| t.to_hash},
          'categories' => @categories.collect {|k, t| t.to_hash},
          'archive' => @archive.to_hash
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
      @posts.each {|p| @archive.add_post(p)}
    end
    
    ##
    # Renders the files
    def render
      @posts.each_parallel {|p| p.render}
      @gens.each {|g| g.render}
    end
    
    
    ##
    # Writes the files
    def write
      @posts.each_parallel {|p| p.write}
      @gens.each_parallel {|g| g.write}
      @statics.each_parallel {|s| s.write}
      
      @archive.write
      self.write_tags
      self.write_categories
    end
    
    # Writes the necessary pages for tags, but only if the correct layouts are present
    def write_tags
      if @layouts['tag_index']
        write_path = File.join( @config[:root], 'tags', 'index.html' )
      
        tag_index = Gen.new(write_path, self)
        tag_index.layout = @layouts['tag_index']
        
        tag_index.render
        tag_index.write
      end
      
      if @layouts['tag_page']
        @tags.each do |n, tag|
          write_path = File.join( @config[:root], 'tags', tag.name, 'index.html' )
          
          payload = {:name => 'tag', :payload => tag.to_hash}
          tag_page = Gen.new(write_path, self, payload)
          tag_page.layout = @layouts['tag_page']
          
          tag_page.render
          tag_page.write
        end
      end
    end
    
    # Writes the necessary pages for categories, but only if the correct layouts are present
    def write_categories
      if @layouts['category_index']
        write_path = File.join( @config[:root], 'categories', 'index.html' )
        
        category_index = Gen.new(write_path, self)
        category_index.layout = @layouts['category_index']
        
        category_index.render
        category_index.write
      end
      
      if @layouts['category_page']
        @categories.each do |n, category|
          write_path = File.join( @config[:root], 'categories', category.name, 'index.html' )
          
          payload = {:name => 'category', :payload => category.to_hash}
          category_page = Gen.new(write_path, self, payload)
          category_page.layout = @layouts['category_page']
          
          category_page.render
          category_page.write
        end
      end
    end
    
    
    # @return [Bool]
    def static?( path )
      !( layout?(path) || post?(path) || gen?(path) || ignored?(path) )
    end
    
    # @return [Bool]
    def layout?( path )
      path.include?('layouts/') && !ignored?(path)
    end
    
    # @return [Bool]
    def post?( path )
      path.include?('posts/') && !ignored?(path)
    end
    
    # @return [Bool]
    def gen?( path )
      return false if post?(path) || layout?(path) || ignored?(path)
      return true if @config[:plugins][:generators].has_key? path.extension 
      return true if File.open(path, "r").read(3) == "---"
      false
    end
    
    # @return [Bool]
    def ignored?( path )
      ignored = ['/options.yaml'] + @config[:exclude]
      ignored.collect! {|i| File.join(@config[:root], i)}
      ignored.each do |i|
        return true if path.include? i
      end
      false
    end
  
  end
end