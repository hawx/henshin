require 'rack'
require 'rack/request'
require 'rack/response'

module Rack

  class Henshin

    def initialize(app, opts={})
      @site = ::Henshin::SETTINGS[:klass].new(opts[:root])
      @site.extend ::Henshin::Site::Servable
      ::Henshin::AbstractFile.send(:include, ::Henshin::AbstractFile::Servable)
    end

    def call(env)
      time = Time.now if ::Henshin.profile?
      a = @site.serve env['REQUEST_PATH']
      puts "#{Time.now - time}s to serve #{env['REQUEST_PATH']}." if ::Henshin.profile?
      a
    end

  end
end


module Henshin

  class Site
    module Servable
      def find_file(path)
        all_files.find {|file| file.path === path } || MissingFile.new
      end

      def serve(path)
        find_file(path).serve
      end
    end
  end

  class AbstractFile
    module Servable
      # @return [String] The mime type for the file to be written.
      def mime
        Rack::Mime.mime_type ::File.extname(permalink)
      end

      def serve
        [200, {"Content-Type" => mime}, [text]]
      end
    end
  end

  # A draft post. As drafts do not have a published date, this sets the date to
  # be tomorrow.
  module Draft
    include Post

    def date
      Date.today + 1
    end

    def published?
      false
    end
  end

  module Post
    def published?
      true
    end
  end

  File.apply %r{(^|/)drafts/}, Draft

  # Missing file implements #serve so that it shows a 404 error.
  class MissingFile
    def serve
      [404, {}, ["404 file not found"]]
    end
  end

  # Site which adds all drafts to the list of posts.
  class DraftSite < Site
    def defaults
      super.deep_merge compress: {
        scripts: false,
        styles:  false,
        images:  false
      }
    end

    def posts
      weave_posts read(:all, 'drafts').sort + super
    end
  end

  use DraftSite
end
