module Henshin

  class Site
    
    # @return [Hash] the configuration made up of the override, options.yaml and Henshin::Defaults
    attr_accessor :config
    
    # @return [Pathname] the path to the site to generate from where the command is executed
    attr_accessor :root
    
    # @return [Pathname] the path to where the finished site should be written
    attr_accessor :target
    
    # @return [String] a path which should be prepended to all urls
    attr_accessor :base
    
    # @return [Array]
    attr_accessor :gens, :posts, :statics
    
    # @return [Hash{String => String}]
    attr_accessor :layouts
    
    # @return [Tags]
    attr_accessor :tags
    
    # @return [Categories]
    attr_accessor :categories
    
    # @return [Archive]
    attr_accessor :archive
    
    # @return [Hash{String => Plugin}]
    attr_accessor :plugins
    
    # A new instance of site
    #
    # @param [Hash{String => Object}] override data to override loaded options
    # @return [self]
    def initialize(override={})
      self.reset
      self.configure(override)
      self.load_plugins
      self
    end
    
    # Resets all instance variables
    #
    # @return [self]
    def reset
      @config = {}
      @root = nil
      @target = nil
      @base = ''
      
      @gens    = []
      @posts   = []
      @statics = []
      @layouts = {}
      
      @archive    = Archive.new(self)
      @tags       = Tags.new(self)
      @categories = Categories.new(self)
      @plugins    = {:generators => {}, :layoutors => []}
      self
    end
    
    # Creates the configuration hash by merging defaults, supplied options and options 
    # read from the 'options.yaml' file. Then sets root, target, base and appends 
    # special directories to @config['exclude']
    #
    # @param [Hash] override to override other set options
    def configure(override)  
      config_file = File.join((override['root'] || Defaults['root']), '/options.yaml')
      
      # change target to represent given root, only if root given
      if override['root'] && !override['target']
        override['target'] = File.join(override['root'], Defaults['target'])
      end
      
      begin
        config = YAML.load_file(config_file)
        @config = Defaults.merge(config).merge(override)
      rescue => e
        $stderr.puts "\nCould not read configuration, falling back to defaults..."
        $stderr.puts "-> #{e.to_s}"
        @config = Defaults.merge(override)
      end
      @root = @config['root'].to_p
      @target = @config['target'].to_p
      
      @base = @config['base'] || "/"
      @base = '/' + @base unless @base[0] == '/' # need to make sure it starts with slash
      
      @config['exclude'] << '/_site' << '/plugins'
    end
    
    # Requires each plugin in @config['plugins'], then loads and sorts them into
    # @plugins by type
    def load_plugins
      @config['plugins'].each do |plugin|
        begin
          require File.join('henshin', 'plugins', plugin)
        rescue LoadError
          require File.join(@root, 'plugins', plugin)
        end
      end
      
      Henshin::Generator.subclasses.each do |plugin|
        plugin = plugin.new(self)
        plugin.extensions[:input].each do |ext|
          @plugins[:generators][ext] = plugin
        end
      end
      
      @plugins[:layoutors] = Henshin::Layoutor.subclasses.map {|l| l.new(self)}.sort
    end
    
    ##
    # Read, process, render and write
    def build
      self.read
      self.process
      self.render
      self.write
    end
    
    
    ##
    # Reads all necessary files and puts them into the necessary arrays
    #
    # @return [self]
    def read
      self.read_layouts
      self.read_posts
      self.read_gens
      self.read_statics
      self
    end
    
    # Adds all items in '/layouts' to the layouts array
    def read_layouts
      path = File.join(@root, 'layouts')
      Dir.glob(path + '/*.*').each do |layout|
        layout =~ /([a-zA-Z0-9 _-]+)\.([a-zA-Z0-9-]+)/
        @layouts[$1] = File.open(layout, 'r') {|f| f.read}
      end
    end
    
    # Adds all items in '/posts' to the posts array
    def read_posts
      path = File.join(@root, 'posts')
      Dir.glob(path + '/**/*.*').each do |post|
        @posts << Post.new(post.to_p, self).read
      end
    end
    
    # Adds all files that need to be run through a plugin in an array
    def read_gens
      files = Dir.glob( File.join(@root, '**', '*.*') )
      gens = files.select {|i| gen?(i) }
      gens.each do |gen|
        @gens << Gen.new(gen.to_p, self).read
      end
    end
    
    # Adds all static files to an array
    def read_statics
      files = Dir.glob( File.join(@root, '**', '*.*') )
      static = files.select {|i| static?(i) }
      static.each do |static|
        @statics << Static.new(static.to_p, self)
      end
    end

    
    ## 
    # Processes all of the necessary files
    def process
      @posts.sort!
      @gens.sort!
      
      self.build_tags
      self.build_categories
      self.build_archive
      self
    end
    
    # @return [Hash] the payload for the layout engine
    def payload
      r = {'site' => @config}
      r['site']['created_at'] = Time.now
      r['site']['posts'] = @posts.collect{|i| i.to_hash}
      r['site']['tags'] = @tags.to_hash
      r['site']['categories'] = @categories.to_hash
      r['site']['archive'] = @archive.to_hash
      r
    end
    
    # Creates tags from posts and adds them to @tags
    def build_tags
      @posts.each do |post|
        @tags << post
      end
    end
    
    # Create categories from posts and add to @categories
    def build_categories
      @posts.each do |post|
        @categories << post
      end
    end
    
    # @return [Hash] archive hash
    def build_archive
      @posts.each do |post|
        @archive << post
      end
    end
    
    ##
    # Renders the files
    def render
      @posts.each {|post| post.render}
      @gens.each {|gen| gen.render}
      self
    end
    
    
    ##
    # Writes the files
    def write
      @posts.each {|post| post.write}
      @gens.each {|gen| gen.write}
      @statics.each {|static| static.write}
      
      @archive.write
      @tags.write
      @categories.write
      self
    end
    
    
    # @param [String] path to test
    # @return [Bool] whether the path points to a static
    def static?( path )
      !( layout?(path) || post?(path) || gen?(path) || ignored?(path) )
    end
    
    # @param [String] path to test
    # @return [Bool] whether the path points to a layout
    def layout?( path )
      path.include?('layouts/') && !ignored?(path)
    end
    
    # @param [String] path to test
    # @return [Bool] whether the path points to a post
    def post?( path )
      path.include?('posts/') && !ignored?(path)
    end
    
    # @param [String] path to test
    # @return [Bool] whether the path points to a gen
    def gen?( path )
      return false if post?(path) || layout?(path) || ignored?(path)
      return true if @plugins[:generators].has_key? path.to_p.extname[1..-1]
      return true if File.open(path, "r").read(3) == "---"
      false
    end
    
    # @param [String] path to test
    # @return [Bool] whether the path points to a file which should be ignored
    def ignored?( path )
      ignored = ['/options.yaml'] + @config['exclude']
      ignored.collect! {|i| File.join(@root, i)}
      ignored.each do |i|
        return true if path.include? i
      end
      false
    end
  
  end
end