require 'rack'
require 'rack/request'
require 'rack/response'

module Rack

  class Henshin

    def initialize(app, opts={})
      @site = ::Henshin::PreviewSite.new(opts[:root])
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

  # A draft post. As drafts do not have a published date, this sets the date to
  # be tomorrow.
  class Draft < Post
    def date
      Date.today + 1
    end

    def data
      super.merge(date: date)
    end
  end

  class File
    # @return [String] The mime type for the file to be written.
    def mime
      Rack::Mime.mime_type extension
    end

    def serve
      [200, {"Content-Type" => mime}, [text]]
    end
  end

  class MissingFile
    def serve
      [400, {}, ["404 file not found"]]
    end
  end


  # Don't compress files when serving as it can be quite slow.

  class CssCompressor
    def compress
      super
    end
  end

  class JsCompressor
    def compress
      super
    end
  end

  class PreviewSite < Site

    # Reads all drafts in.
    def drafts
      @reader.read('drafts', '*').map {|p| Draft.new(self, p) }
    end

    # Adds the drafts to the Site data hash.
    def data
      super.merge drafts: drafts.map {|i| i.data }
    end

    def all_files
      files + posts + drafts + [style, script]
    end

    # Finds the file at the path given, failing returns an instance of
    # MissingFile.
    def find_file(path)
      all_files.find {|file| file.url == path || file.permalink == path } || MissingFile.new
    end

    # Serves the file at the path given.
    def serve(path)
      find_file(path).serve
    end

  end
end
