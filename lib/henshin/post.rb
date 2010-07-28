module Henshin

  class Post < Gen
    
    attr_accessor :path, :data, :content, :site, :layout
    
    def initialize( path, site )
      @path = path
      @site = site
      
      @content = ''
      @data = {}
      
      @data['input'] = @path.extension
    end    
    
    ##
    # Reads the file
    def read
      self.read_name
      self.read_file if @path.exist?
      self.get_layout
      
      # now tidy up data
      @data['output'] ||= @data['input']
      @data['date'] = Time.parse(@data['date'])
      @data['tags'] = @data['tags'].flatten.uniq if @data['tags']
      self
    end
    
    # Reads the filename and extracts information from it
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
    
    # Creates the data to be sent to the layout engine
    #
    # @return [Hash] the payload for the layout engine
    def payload
      r = { 
        'yield' => @content,
        'site'  => @site.payload['site'],
        'post'  => self.to_hash
      }
      #r['post']['next'] = self.next.to_hash if self.next
      #r['post']['prev'] = self.prev.to_hash if self.prev
      r
    end
    
    # Turns all of the post data into a hash
    #
    # @return [Hash]
    def to_hash
      r = @data.dup
      r['content'] = @content
      r['url'] = self.url
      r['permalink'] = self.permalink
    
      if @data['tags']
        r['tags'] = []
        @site.tags.select{|t| @data['tags'].include?(t.name)}.each do |tag|
          # can't call Tag#to_hash or it creates an infinite loop!
          r['tags'] << {'name' => tag.name, 'url' => tag.url}
        end
      end
    
      if @data['category']
        @site.categories.each do |cat|
          if cat.name == @data['category']
            r['category'] = {'name' => cat.name, 'url' => cat.url}
          end
        end
      end
      
      r
    end
    
    # Gets the post after this one
    #
    # @return [Post] next post
    def next
      if i = @site.posts.index(self)
        if i < @site.posts.size - 1
          @site.posts[i+1]
        else
          nil
        end
      end
    end
    
    # Gets the post before this one
    #
    # @return [Post] previous post
    def prev
      if i = @site.posts.index(self)
        if i > 0
          @site.posts[i-1]
        else
          nil
        end
      end
    end
    
    # @return [String] the permalink of the post
    def permalink
      partials = {'year' => @data['date'].year,
                  'month' => @data['date'].month,
                  'date' => @data['date'].day,
                  'title' => @data['title'].slugify,
                  'category' => @data['category'] || ''}
                  
      perm = @site.config['permalink'].gsub(/\{([a-z-]+)\}/) { partials[$1] }
      File.join(@site.base, perm)
    end
    
    # Sorts on date first, then permalink if dates are equal
    def <=>(other)
      s = @data['date'] <=> other.data['date']
      if s == 0
        self.permalink <=> other.permalink
      else
        s
      end
    end
    
    def inspect
      "#<Post:#{@path}>"
    end
    
  end
  
end