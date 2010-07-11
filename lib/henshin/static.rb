module Henshin

  class Static
    
    attr_accessor :path, :site, :content
    
    def initialize( path, site )
      @path = path
      @site = site
      @content = File.read(path)
    end
    
    ##
    # Writes the file to the correct place
    def write
      FileUtils.mkdir_p(self.write_path.dirname)
      file = File.new(self.write_path, "w")
      file.puts(@content)
    end
    
    # @return [Pathname] path to write the file
    def write_path
      rel = @path.relative_path_from(@site.root)
      @site.target + File.join(@site.base, rel)[1..-1]
    end
    
    def inspect
      "#<Static:#{@path}>"
    end
    
  end
  
end