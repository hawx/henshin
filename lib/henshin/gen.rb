module Henshin
  
  # This is the main class for all pages, posts, sass, etc, that need to be run through a plugin
  class Gen
    
    attr_accessor :path, :extension, :content, :layout, :date, :title
    attr_accessor :site, :config, :renderer
    
    def initialize( path, site )
      @path = path
      @site = site
      @config = site.config
      @extension = path.extension
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
      @layout ||= @site.layouts[ override[:layout] ]
      @date ||= Time.parse( override[:date].to_s )
    end
    
    
    ##
    # Renders the files content
    def render
      # render the posts content
      config[:plugins].each do |plugin|
        if plugin.extensions.include?( @extension ) && !plugin.is_a?( LayoutParser )
          @content = plugin.generate( @content )
          @renderer = plugin
        end
      end
      @renderer ||= StandardPlugin.new
      
      @layout ||= site.layouts[ site.config[:layout] ]
      unless @renderer.config[:ignore_layouts]
        # do the layout
        config[:plugins].each do |plugin|
          if plugin.is_a?( LayoutParser )
            @content = plugin.generate( @layout, self.payload )
          end
        end
      end
    end
    
    # Creates the data to be sent to the layout engine
    #
    # @return [Hash] the payload for the layout engine
    def payload
      { 
        'yield' => @content,
        'site' => @site.payload['site']
      }
    end
    
    
    ##
    # Writes the file to the correct place
    def write
    
      write_path = File.join( config[:root], config[:target], @path[config[:root].size..-1] )
    
      render_target = @renderer.config[:target] if @renderer
      if render_target
        # files should be put in a different folder
        write_path.gsub!("/#{@renderer.config[:root]}", "/#{@renderer.config[:target]}")
      end
      
      render_type = @renderer.config[:file_type] if @renderer
      if render_type
        # files should have different extension
        write_path.gsub!(".#{@extension}", ".#{render_type}")
      end

      FileUtils.mkdir_p File.join( write_path.directory )
      file = File.new( File.join( write_path ), "w" )
      file.puts( @content )
      
    end
    
  end
end