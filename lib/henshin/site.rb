module Henshin

  class Site
  
    attr_accessor :posts, :gens, :statics, :archives, :tags, :categories, :plugins
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
      @archives = {}
      @tags = {}
      @categories = {}
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
      Dir.glob(path + '/*.*').each do |post|
        # should really create a new post object but I haven't made one yet
        @posts << Post.new(post, self)
      end
    end
    
    # Gets all other items, and determines whether it's static or needs to be converted
    def read_others
      path = File.join(config[:root], '**', '*.*')
      items = Dir.glob(path)
      items = items.select {|i| !i.include?(config[:root] + '/_site')}
      
      items -= ["#{config[:root]}/options.yaml"]
      items -= @posts.collect {|i| i.path}
      items -= @layouts.collect {|k, v| v}
      
      gens = items.select {|i| config[:extensions].include?(i.extension) }
      gens = gens.select do |i|
        if i.extension == "html"
          File.open(i, "r").read(3) == "---"
        else
          true
        end
      end

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
      @posts.each {|p| p.process}
      @gens.each {|g| g.process}
    end
    
    # Creates the data to be sent to the layout engine
    #
    # @return [Hash] the payload for the layout engine
    def payload
      {'site' => {'author' => self.config[:author],
                  'title' => self.config[:title],
                  'description' => self.config[:description],
                  'time_zone' => self.config[:time_zone],
                  'created_at' => Time.now} }
    end
    
    
    ##
    # Renders the files
    def render
      @posts.each {|p| p.render}
      @gens.each {|g| g.render}
    end
    
    
    ##
    # Writes the files
    def write
      @posts.each {|p| p.write}
      @gens.each {|g| g.write}
      @statics.each {|s| s.write}
    end
  
  end

end