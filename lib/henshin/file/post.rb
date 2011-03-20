module Henshin
  class Post < Henshin::File
    def initialize(*args)
      @key = :post
      @output = 'html'
      super
    end
    
    attr_accessor :tags, :categories
    attribute :tags, :categories
    
    def date
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
  end
end