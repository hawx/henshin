module Henshin
  class File::Post < File::Text
  
    class MissingDateError < HenshinError
      def to_s
        "Post '#{@args[0].title}' does not have a date."
      end
    end
  
    attr_accessor :tags, :categories
    attribute :tags, :categories
    
    def date
      return @date if @date
      raise MissingDateError.new(self) unless yaml.has_key?('date')
      
      Time.parse yaml['date']
    end
    settable_attribute :date
    
    def url
      "/#{date.year}/#{date.month}/#{date.day}/#{title.slugify}"
    end
    
    def title
      yaml['title'] || super
    end

    set :key, :post
    set :output, 'html'
    
    def <=>(other)
      (self.date <=> other.date).tap {|c| return super if c == 0 }
    end
    
    attribute :next, :previous
    
    def next
      posts = @site.posts.sort
      pos = posts.index(self)
      
      if pos && pos < posts.size - 1
        posts[pos + 1]
      else
        nil
      end
    end
    
    def previous
      posts = @site.posts.sort
      pos = posts.index(self)
      
      if pos && pos < posts.size - 1
        posts[pos - 1]
      else
        nil
      end
    end
    
  end
end