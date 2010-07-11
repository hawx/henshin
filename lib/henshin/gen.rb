module Henshin
  
  # This is the main class for all pages, posts, sass, etc, that need to be run through a plugin
  class Gen
    
    attr_accessor :path, :data, :content, :site, :to_inject, :generators
    
    attr_accessor :path, :extension, :content, :layout, :title
    attr_accessor :site, :config, :renderer, :data, :output
    
    def initialize( path, site, to_inject=nil )
      @path = path
      @site = site
      @data = {}
      @content = ''
      @to_inject = to_inject
      @generators = []
      
      @data['input'] = @path.extension
    end
    
    
    ##
    # Reads the file
    def read
      self.read_file
      self.get_generators
      self.get_layout
      @data['output'] ||= @data['input'] # if not different must be same
      self
    end
    
    # Reads the files yaml frontmatter and uses it to override some settings, then grabs content
    def read_file
      file = @path.read
    
      if file =~ /^(---\s*\n.*?\n?^---\s*$\n?)/m
        override = YAML.load_file(@path)
        @data = @data.merge(override)
        @content = file[$1.size..-1]
      else
        @content = file
      end 
    end
    
    # Finds the correct plugins to render this gen
    def get_generators
      @site.plugins[:generators].each do |k, v|
        if k == @data['input'] || k == '*'
          @generators << v
          @data['output'] ||= v.extensions[:output]
          @data['ignore_layout'] ||= (v.config[:ignore_layouts] ? true : false)
        end
      end
      @generators.sort!
    end
    
    # Gets the correct layout for the gen, or the default if none exists
    def get_layout
      if @data['layout']
        @data['layout'] = site.layouts[ @data['layout'] ]
      else
        # get default layout
        @data['layout'] = site.layouts[ site.config['layout'] ]
      end
    end
    
    ##
    # Renders the files content
    def render
      
      @generators.each do |plugin|
        @content = plugin.generate(@content)
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
      @data['url'] = self.url
      @data['permalink'] = self.permalink
      @data
    end
    
    
    ##
    # Writes the file to the correct place
    def write
      FileUtils.mkdir_p(self.write_path.dirname)
      file = File.new(self.write_path, "w")
      file.puts(@content)
    end
    
    # @return [String] the permalink of the gen
    def permalink
      rel = @path.relative_path_from(@site.root).to_s
      rel.gsub!(".#{@data['input']}", ".#{@data['output']}")
      File.join(@site.base, rel)
    end
    
    # @return [String] the pretty url for the gen
    def url
      if @site.config['permalink'].include?("/index.html") && @data['output'] == 'html'
        self.permalink.to_p.dirname.to_s
      else
        self.permalink
      end
    end
    
    # @return [Pathname] path to write the file to
    def write_path
      @site.target + self.permalink[1..-1]
    end
    
    # Sort gens based on permalink only
    def <=>( other )
      self.permalink <=> other.permalink
    end
    
    def inspect
      "#<Gen:#{@path}>"
    end
  end
end