module Henshin
  class Post < Henshin::File    
    attr_accessor :tags, :categories
    attribute :tags, :categories
    
    def date
      return @date if @date
      Time.parse self.yaml['date']
    rescue
      nil
    end
    attribute :date
    
    def url
      if date
        "/#{date.year}/#{date.month}/#{date.day}/#{title.slugify}"
      else
        "/posts/#{title.slugify}"
      end
    end
    
    def title
      self.yaml['title'] || super
    end
    
    def permalink
      url << "/index.html"
    end
  
    def write_path
      Pathname.new self.permalink[1..-1]
    end
    
    def key
      :post
    end
    
    def output
      'html'
    end
    
    def <=>(other)
      (self.date <=> other.date).tap {|c| return super if c.zero? }
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