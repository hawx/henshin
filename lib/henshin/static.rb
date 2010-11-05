module Henshin

  class Static
    
    attr_accessor :path, :site, :content
    include Writeable
    
    def initialize( path, site )
      @path = path
      @site = site
      @content = File.read(path)
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