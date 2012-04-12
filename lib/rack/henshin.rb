require 'rack'
require 'rack/request'
require 'rack/response'

module Rack

  class Henshin

    def initialize(app, opts={})
      @site = ::Henshin::PreviewSite.new(opts[:root])
    end

    def call(env)
      @site.serve env['REQUEST_PATH']
    end

  end
end


module Henshin

  # Drafts won't have a published date as they haven't been published so make it
  # tomorrow.
  class Draft < Post
    def date
      Date.today + 1
    end

    def data
      super.merge(date: date)
    end
  end

  class File
    def serve
      [200, {"Content-Type" => mime}, text]
    end
  end

  class MissingFile
    def serve
      [400, {}, "404 file not found"]
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
      all_files.find {|file| file.url == path } || MissingFile.new
    end

    # Serves the file at the path given.
    def serve(path)
      find_file(path).serve
    end

  end
end
