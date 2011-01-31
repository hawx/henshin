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
      date = Time.parse(y['date'])
      "/#{date.year}/#{date.month}/#{date.day}/#{y['title'].slugify}"
    end
    
    def permalink
      url << "/index.html"
    end
  
    def write_path
      Pathname.new self.permalink[1..-1]
    end
  end
end