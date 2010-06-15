module Henshin
  
  # This is the main class for all pages, posts, sass, etc, that need to be run through a plugin
  class Gen
    
    attr_accessor :path, :extension, :content, :layout, :date, :title
    attr_accessor :site, :config, :renderer, :data, :output
    
    def initialize( path, site, data=nil )
      @path = path
      @site = site
      @config = site.config
      @extension = path.extension
      @data = data
    end
    
    
    ##
    # Processes the file
    def process
      self.read_yaml
    end
    
    # Reads the files yaml frontmatter and uses it to override some settings, then grabs content
    def read_yaml
      file = File.read(self.path)

      if file =~ /^(---\s*\n.*?\n?^---\s*$\n?)/m
        override = YAML.load_file(@path).to_options
        self.override(override)
        @content = file[$1.size..-1]
      else
        @content = file
      end  
    end
    
    # Uses the loaded data to override settings
    #
    # @param [Hash] override data to override settings with
    def override( override )
      @title  = override[:title]                    if override[:title]
      @layout = @site.layouts[ override[:layout] ]  if override[:layout]
      @date   = Time.parse( override[:date].to_s )  if override[:date]
    end
    
    
    ##
    # Renders the files content
    def render
      ignore_layout = false
      
      if config[:plugins][:generators].has_key? @extension
        plugin = config[:plugins][:generators][@extension]
        @content = plugin.generate( @content )
        @output = plugin.extensions[:output]
        ignore_layout = true if plugin.config[:ignore_layouts]
      end

      @layout ||= site.layouts[ site.config[:layout] ]
      unless ignore_layout || @layout.nil?
        config[:plugins][:layout_parsers].each do |plugin|
          @content = plugin.generate( @layout, self.payload )
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
        'site'  => @site.payload['site'],
      }
      hash[ @data[:name] ] = @data[:payload] if @data
      
      hash
    end
    
    # Turns all of the post data into a hash
    #
    # @return [Hash]
    def to_hash
      { 
        'title'      => @title,
        'permalink'  => self.permalink,
        'url'        => self.url,
        'date'       => @date,
        'content'    => @content 
      }
    end
    
    
    ##
    # Writes the file to the correct place
    def write
      write_path = File.join( config[:root], config[:target], @path[config[:root].size..-1] )
      
      # change extension if necessary
      write_path.gsub!(".#{@extension}", ".#{@output}") if @output

      FileUtils.mkdir_p File.join( write_path.directory )
      file = File.new( File.join( write_path ), "w" )
      file.puts( @content )
    end
    
    # Returns the permalink for the gen
    def permalink
      @path[config[:root].size..-1]
    end
    
    # Returns the (pretty) url for the gen
    def url
      if config[:permalink].include? "/index.html"
        self.permalink[0..-11]
      else
        self.permalink
      end
    end
    
    
    # Needed to sort the posts by date, newest first
    def <=>( other )
      if self.date
        s = self.date <=> other.date
        if s == 0
          return self.permalink <=> other.permalink
        else
          return -1 * s
        end
      else
        self.permalink <=> other.permalink
      end
    end
    
    def inspect
      "#<Gen:#{@path}>"
    end
  end
end