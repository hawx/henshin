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
    
      @site.serve_file(file)
    end
  
  end
end

module Henshin
  class Base
  
    # Renders a single file. This is used for the Rack interface. This
    # should only load the files necessary to render the one file, so 
    # instead of loading _every_ layout, we only load the one needed,
    # and we do not load every other none related file.
    #
    # Note(s): #route defintions made will not be passed a match object
    #  from matches with the regex given, instead they will receive an
    #  array of any +()+ matches that were made.
    #
    #    route /[ab]+.html/ do |site| # no match
    #
    #    route /([ab]+).html/ do |m, site| # match, m, for ([ab]+)
    #
    # @param permalink [Pathname]
    #   Permalink of the file to render.
    #
    def serve_file(permalink)
      puts "Request for ".grey + permalink
      
      @files = []
      @files = self.pre_render(self.read)
      file = @files.find {|i| i.permalink == permalink }
      
      run :before, :render, self
      if file
        file = self.render_file(file, self.layouts, true)
        run :after, :render, self
        
        [200, {"Content-Type" => file.mime}, [file.content]]
      else
        # Check the routes that have been set
        routes.each do |pattern, action|
          m = pattern.matches(permalink)
          if m && action

            file = action
            if action.respond_to?(:call)
              file = action.call(*m.values, self)
              p 'passed' if file == :pass
              break unless file # 404 if no file created
            end
            self.render_file(file, self.layouts, true)
            run :after, :render, self
            
            return [200, {"Content-Type" => file.mime}, [file.content]]
          end
        end
      
        [404, {}, ["404 page not found"]]
      end
    end
  end
end