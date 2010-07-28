module Henshin

  class Layout
  
    attr_accessor :path, :name, :content, :extension, :site
    
    # Creates a new instance of Layout
    #
    # @param [Pathname] path to the layout
    # @param [Site] the site the layout belongs to
    def initialize(path, site)
      @path = path
      @site = site
      @name = path.file_name
      @extension = path.extension
      @content = path.read
    end
    
    # @return [Boolean] whether this layout is the default
    def default?
      @name == @site.config['layout']
    end
    
    def inspect
      "#<Layout:#{@name}>"
    end
    
  end
end
