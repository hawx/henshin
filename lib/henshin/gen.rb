module Henshin
  
  # This is the main class for all pages, posts, sass, etc, that need to be run through a plugin
  class Gen
    
    attr_accessor :path, :data, :content, :site, :to_inject
    
    attr_accessor :path, :extension, :content, :layout, :title
    attr_accessor :site, :config, :renderer, :data, :output
    
    def initialize( path, site, to_inject=nil )
      @path = path
      @site = site
      @data = {}
      @content = ''
      @to_inject = to_inject
    end
    
    
    ##
    # Processes the file
    def process
      self.read_yaml
    end
    
    # Reads the files yaml frontmatter and uses it to override some settings, then grabs content
    def read_yaml
      file = @path.read
    
      if file =~ /^(---\s*\n.*?\n?^---\s*$\n?)/m
        override = YAML.load_file(@path)
        @data = @data.merge(override)
        @content = file[$1.size..-1]
      else
        @content = file
      end 
    end
    
    ##
    # Renders the files content
    def render
      @data['input'] = @path.extname[1..-1]
      
      plugins = []
      @site.plugins[:generators].each do |k, v|
        if k == @data['input'] || k == '*'
          plugins << v
        end
      end
      plugins.sort!
      
      plugins.each do |plugin|
        @content = plugin.generate(@content)
        @data['output'] = plugin.extensions[:output]
        @data['ignore_layout'] = (plugin.config[:ignore_layouts] ? true : false)
      end
      
      if @data['layout']
        @data['layout'] = site.layouts[ @data['layout'] ]
      else
        # get default layout
        @data['layout'] = site.layouts[ site.config['layout'] ]
      end
      
      unless @data['ignore_layout'] || @data['layout'].nil?
        @site.plugins[:layout_parsers].each do |plugin|
          @content = plugin.generate(@data['layout'], self.payload)
          # 2nd pass so that markup in the gen are processed too
          @content = plugin.generate(@content, self.payload)
        end
      end
      
    end
    
    # Creates the data to be sent to the layout engine. Adds optional data if available
    #
    # @return [Hash] the payload for the layout engine
    def payload
      hash = {
        'yield' => @content,
        'gen'   => self.to_hash,
        'site'  => @site.payload['site']
      }
      hash[ @to_inject[:name] ] = @to_inject[:payload] if @to_inject
      hash
    end
    
    # Turns all of the post data into a hash
    #
    # @return [Hash]
    def to_hash
      @data['content'] = @content
      @data
    end
    
    
    ##
    # Writes the file to the correct place
    def write
      t = @site.target + self.permalink
      
      # change extension if necessary, this seems a bit of a hack at the moment
      t = t.to_s.gsub(".#{@data['input']}", ".#{@data['output']}").to_p if @data['output']

      FileUtils.mkdir_p(t.dirname)
      file = File.new(t, "w")
      file.puts(@content)
    end
    
    # Returns the permalink for the gen
    def permalink
      @path.relative_path_from(@site.root)
    end
    
    # Returns the (pretty) url for the gen
    def url
      if @site.config['permalink'].include?("/index.html") && @data['output'] == 'html'
        self.permalink.dirname
      else
        self.permalink
      end
    end
    
    
    # Needed to sort the posts by date, newest first
    def <=>( other )
      self.permalink <=> other.permalink
    end
    
    def inspect
      "#<Gen:#{@path}>"
    end
  end
end