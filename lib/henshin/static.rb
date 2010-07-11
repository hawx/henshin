module Henshin

  class Static
    
    attr_accessor :path, :site, :config, :content
    
    def initialize( path, site )
      @path = path
      @site = site
      @config = site.config
      @content = File.read( path )
    end
    
    ##
    # Writes the file to the correct place
    def write
      t = @site.target + self.permalink
      FileUtils.mkdir_p(t.dirname)
      file = File.new(t, "w")
      file.puts(@content)
    end
    
    
    # Returns the permalink for the gen
    def permalink
      @path.relative_path_from(@site.root)
    end
    
    
    def inspect
      "#<Static:#{@path}>"
    end
    
  end
  
end