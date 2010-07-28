module Henshin
  
  # This is the main class for files which need to be rendered with plugins
  class Gen
    
    attr_accessor :path, :data, :content, :site, :to_inject, :layout
    
    # Creates a new instance of Gen
    #
    # @param [Pathname] path to the file
    # @param [Site] the site the gen belongs to
    # @param [Hash] an optional payload to add when rendered
    def initialize(path, site, to_inject=nil)
      @path = path
      @site = site
      @data = {}
      @content = ''
      @to_inject = to_inject
      @generators = []
      @layoutors = []
      
      @data['input'] = @data['output'] = @path.extension
    end
    
    
    ##
    # Reads the file if it exists, and gets the layout
    def read
      self.read_file if @path.exist?
      self.get_layout
      
      self
    end
    
    # Opens the file and reads the yaml frontmatter if any exists, and
    # also gets the contents of the file.
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
    
    # Finds the generators for this gen and sets output
    def generators
      r = []
      @site.plugins[:generators].each do |k, v|
        if k == @data['input'] || k == '*'
          r << v
          @data['output'] = v.extensions[:output] if v.extensions[:output]
          @data['ignore_layout'] ||= (v.config['ignore_layouts'] ? true : false)
        end
      end
      r.sort!
    end
    
    # Finds the Layoutors for this gen
    def layoutors
      r = []
      @site.plugins[:layoutors].each do |k, v|
        if k == @data['input'] || k == '*'
          r << v
        end
        if @layout
          if k == @layout.extension
            r << v
          end
        end
      end
      r.sort!
    end
    
    # Gets the correct layout for the gen, or the default if none exists.
    def get_layout
      if @data['layout']
        @layout = site.layouts[@data['layout']]
      else
        # get default layout
        @layout = site.layouts.default
      end
    end
    
    ##
    # Renders the files content using the generators from #get_generators and all layout parsers. 
    # Passed through layout parser twice so that markup in the gen is processed.
    def render
      self.generators.each do |plugin|
        @content = plugin.generate(@content)
      end
      
      unless @data['ignore_layout']
        self.layoutors.each do |plugin|
          @content = plugin.generate(@layout.content, self.payload) if @layout
          @content = plugin.generate(@content, self.payload)
        end
      end
      
    end
    
    # Creates the data to be sent to the layout engine. Adds optional data if available.
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
    
    # Turns all of the gens data into a hash.
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
    
    # Sorts gens based on permalink only
    def <=>( other )
      self.permalink <=> other.permalink
    end
    
    def inspect
      "#<Gen:#{@path}>"
    end
  end
end