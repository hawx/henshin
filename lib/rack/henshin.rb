require 'rack'
require 'rack/request'
require 'rack/response'

module Rack

  class Henshin

    def initialize(app, opts={})
      @site = ::Henshin::DraftSite.new(opts[:root])
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

    def data
      super.merge(date: date)
    end
  end

  File.apply %r{/drafts/}, Draft

  # Missing file implements #serve so that it shows a 404 error.
  class MissingFile
    def serve
      [400, {}, ["404 file not found"]]
    end
  end

  # Reimplement CssCompressor so that it doesn't compress css. This speeds up
  # rendering considerably.
  class CssCompressor
    def compress
      super
    end
  end

  # Reimplement JsCompressor so that it doesn't compress js.
  class JsCompressor
    def compress
      super
    end
  end

  class DraftSite < Site
    files :drafts, 'drafts'
  end
end
