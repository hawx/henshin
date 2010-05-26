module Henshin

  class Post < Gen
    
    attr_accessor :title, :author, :tags, :category, :date
    
    def initialize( path, site )
      @path = path
      @site = site
      @config = site.config
      @extension = path.extension
      @layout = site.layouts[ site.config[:layout] ]
      @author = @config[:author]
      @tags = []
      @date = Time.now
    end
    
    
    ##
    # Processes the file
    def process
      self.read_name
      self.read_yaml
    end
    
    # Reads the filename and extracts information from it
    def read_name
      parser = {'title' => '([a-zA-Z0-9 ]+)',
                'title-with-dashes' => '([a-zA-Z0-9-]+)',
                'date' => '(\d{4}-\d{2}-\d{2})',
                'date-time' => '(\d{4}-\d{2}-\d{2} at \d{2}:\d{2})',
                'xml-date-time' => '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?((\+|-)\d{2}:\d{2})?)',
                'extension' => "(#{ site.config[:extensions].join('|') })"}
      
      file_parser = config[:file_name]
      # create string regex and keep order of info
      data_order = []
      m = file_parser.gsub(/\{([a-z-]+)\}/) do
        data_order << $1
        parser[$1]
      end
      # convert string to actual regex
      matcher = Regexp.new(m)
      
      override = {}
      # extract data from filename
      file_data = path.file_name.match( matcher ).captures
      file_data.each_with_index do |data, i|
        if data_order[i].include? 'title'
          if data_order[i].include? 'dashes'
            override[:title] = data.gsub(/-/, ' ').titlize
          else
            override[:title] = data.titlize
          end
        elsif data_order[i].include? 'date'
          override[:date] = data
        elsif data_order[i].include? 'extension'
          override[:extension] = data
        end
      end
      self.override( override )
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
      @title     = override[:title]                   if override[:title]
      @layout    = @site.layouts[ override[:layout] ] if override[:layout]
      @date      = Time.parse( override[:date] )      if override[:date]
      @tags      = override[:tags].split(', ')        if override[:tags]
      @category  = override[:category]                if override[:category]
      @author    = override[:author]                  if override[:author]
      @extension = override[:extension]               if override[:extension]
      @category  = override[:category]                if override[:category]
      
      if override[:tags]
        @tags << override[:tags].split(', ')
        @tags.flatten!
      end
    end
    
    
    # Creates the data to be sent to the layout engine
    #
    # @return [Hash] the payload for the layout engine
    def payload
      { 
        'yield' => @content,
        'site' => @site.payload['site'],
        'post' => self.to_hash
      }
    end
    
    # Turns all of the post data into a hash
    #
    # @return [Hash]
    def to_hash
      { 
        'title'      => @title,
        'author'     => @author,
        'url'        => self.permalink,
        'date'       => @date,
        'category'   => @category,
        'tags'       => @tags,
        'content'    => @content 
      }
    end

    
    ##
    # Writes the file to the correct place
    def write
      write_path = File.join( config[:root], config[:target], permalink )
      FileUtils.mkdir_p File.join( write_path.directory )
      file = File.new( File.join( write_path ), "w" )
      file.puts( @content )
    end
    
    # Creates the permalink for the post
    def permalink
      partials = {'year' => self.date.year,
                  'month' => self.date.month,
                  'date' => self.date.day,
                  'title' => self.title.slugify}
                  
      config[:permalink].gsub(/\{([a-z-]+)\}/) do
        partials[$1]
      end
    end
    
    def inspect
      "#<Post:#{@path}>"
    end
    
  end
  
end