module Henshin
  
  # This is the main class for files which need to be rendered with plugins
  class Gen
    
    attr_accessor :path, :data, :content, :site, :to_inject, :layout
    
    include Readable
    include Renderable
    include Writeable
    
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