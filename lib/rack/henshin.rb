require 'rack'
require 'rack/request'
require 'rack/response'

module Rack

  # Using this assumes you have loaded the correct files. Eg. If you want to
  # use Henshin::Blog it assumes you have already put +require 'henshin/blog'+.
  class Henshin
    attr_accessor :site
  
    def initialize(app, opts={})
      case opts[:builder]
      when 'Henshin::Base'
        @site ||= ::Henshin::Base.new('source' => opts[:root])
      when 'Henshin::Site'
        @site ||= ::Henshin::Site.new('source' => opts[:root])
      when 'Henshin::Blog'
        @site ||= ::Henshin::Blog.new('source' => opts[:root])
      end
    end
    
    def call(env)
      file = env["REQUEST_PATH"]
      if file.to_s.split('.').size < 2
        file = ::File.join(file, "index.html")
      end
    
      @site.render_file(file)
    end
  
  end
end
