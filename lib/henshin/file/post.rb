module Henshin
  class Post < Henshin::File
    def initialize(*args)
      @key = :post
      @output = 'html'
      super
    end
    
    attr_accessor :tags, :categories
    attribute :tags, :categories
    
    def url
      y = YAML.load(self.yaml)
      begin
        date = Chronic.parse(y['date'])
        "/#{date.year}/#{date.month}/#{date.day}/#{y['title'].slugify}"
      rescue
        "/posts/#{y['title'].slugify}"
      end
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