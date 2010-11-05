module Henshin
  
  # Include this module for anything that needs to be read.
  # It assumes +@site+, +@path+, +@data+ and +@content+ exist.
  module Readable
    
    # Reads the filename and extracts information from it.
    # Assumes +@path+, +@site+ and +@data+ exist.
    def read_name
      result = Parsey.parse(@path.to_s[(@site.root + 'posts').to_s.size..-1], @site.config['file_name'], Partials)

      result.each do |k, v|
        unless v.nil?
          case k
          when 'title-with-dashes'
            @data['title'] = v.gsub(/-/, ' ').titlecase
          when 'title'
            @data['title'] = v.titlecase
          else
            @data[k] = v
          end
        end
      end
    end
    
    # Opens the file and reads the yaml frontmatter if any exists, and
    # also gets the contents of the file.
    # Assumes +@path+, +@data+ and +@data+ exist.
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
    
  end

  # Include this module for anything that needs to be rendered with 
  # plugins and a layout.
  # It assumes +@site+, +@data+, +@layout+ and +@content+ exist.
  module Renderable
  
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
    
    # Renders the files content using the generators from #get_generators and 
    # all layout parsers. Passed through layout parser twice so that markup 
    # in the gen is processed.
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
  
  end

  # Include this module to anything that needs to be written.
  # It assumes #write_path and +@content+ exists
  module Writeable
    
    # Writes a file at #write_path with +@content+
    def write
      FileUtils.mkdir_p(self.write_path.dirname)
      file = File.new(self.write_path, 'w')
      file.puts(@content)
    end
    
  end
  
end