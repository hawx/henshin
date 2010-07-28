module Henshin

  class Layouts < Array
    
    # @param [String] val name of layout to find
    # @return [Layout] the layout with the name +val+
    def [](val)
      self.select {|i| i.name == val}
    end
    
    # @return [Layout] the default layout
    def default
      self.select {|i| i.default?}[0]
    end
    
    # @param [String] name of layout to check for
    # @return [Boolean] whether Layouts contains a Layout called +val+
    def include?(val)
      self.map{|i| i.name }.include?(val)
    end
    
  end

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
