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
      write_path = File.join( config[:root], config[:target], @path[ config[:root].size..-1 ] )
      
      FileUtils.mkdir_p File.join( write_path.directory )
      file = File.new( File.join( write_path ), "w" )
      file.puts( @content )
    end
    
    
    def inspect
      "#<Static:#{@path}>"
    end
    
  end
  
end