module Henshin

  # This is basically a front for tags and categories, because they are so similar
  # it makes sense to condense them into one class!
  #
  class Labels < Array
  
    attr_accessor :base, :site
    
    # Creates a new instance of labels
    #
    # @param [String] base the base part of the urls, eg. category, tag
    # @param [Site] site that the labels belong to
    def initialize(base, site)
      @base = base
      @site = site
    end
    
    # Adds the given post to the correct category object in the array
    # or creates the category and adds the post to that
    #
    # @param [Post] post to be added
    # @param [String, Array] k label(s) to be added to
    #
    # @todo Make it a bit more abstract, actually hard coding stuff in will
    #   lead to problems!
    def <<(post)
      k = nil
      if base == 'tag'
        k = post.data['tags']
      elsif base == 'category'
        k = [post.data['category']]
      end
      
      k.each do |j|
        unless self.map{|i| i.name}.include?(j)
          super Henshin::Label.new(j, @base, @site)
        end
        i = self.find_index {|i| i.name == j}
        self[i].posts << post
      end
    end
    
    # Converts the labels to a hash for use in a layout parser
    def to_hash
      r = []
      self.each do |i|
        r << i.to_hash
      end
      r
    end
    
    # @return [String] permalink for label index
    def permalink
      File.join(@site.base, @base, "index.html")
    end
    
    # @return [String] base url for label
    def url
      File.join(@site.base, @base)
    end
    
    # Need a fake path where the file would have been so as to 
    # trick the gen into constructing the correct paths
    #
    # @return [Pathname] the path for the gen
    def fake_write_path
      @site.root + self.permalink[1..-1]
    end
    
    # Writes the category index, then writes the individual
    # category pages
    def write
      if @site.layouts.include?("#{@base}_index")
        page = Gen.new(self.fake_write_path, @site)
        page.read
        page.data['layout'] = @site.layouts["#{@base}_index"]
                
        page.render
        page.write
      end
      if @site.layouts.include?("#{@base}_page")
        self.each {|label| label.write }
      end
    end
  
  end
  
  class Label
    attr_accessor :name, :posts, :site
    
    # Creates a new instance of label
    #
    # @param [String] name of the label
    # @param [String] base of the url for the label (see Labels#initialize)
    # @param [Site] site that the label belongs to
    def initialize(name, base, site)
      @name = name
      @base = base      
      @site = site
      @posts = []
    end
    
    # Converts the label to a hash
    def to_hash
      hash = {
        'name' => @name,
        'posts' => @posts.sort.collect {|i| i.to_hash},
        'url' => self.url
      }
    end
    
    # @return [String] permalink for the label
    def permalink
      File.join(@site.base, @base, "#{@name.slugify}/index.html")
    end
    
    # @return [String] url for the label
    def url
      File.join(@site.base, @base, "#{@name.slugify}")
    end
    
    # @see Labels#fake_write_path
    def fake_write_path
      @site.root + self.permalink[1..-1]
    end
    
    # Writes the label page
    def write
      payload = {:name => @base, :payload => self.to_hash}
      page = Gen.new(self.fake_write_path, @site, payload)
      page.read
      page.data['layout'] = @site.layouts["#{@base}_page"]
      
      page.render
      page.write
    end
    
    def inspect
      "#<Label:#{@base}/#{@name}>"
    end
  end
  
end