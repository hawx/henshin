require 'rack'
require 'rack/request'
require 'rack/response'

module Rack

  class Henshin

    def initialize(app, opts={})
      @site = opts[:site]
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
        all_files.find {|file| file.path === path } || MissingFile
      end

      # Finds the file which resolves the path given and serves it.
      #
      # @param path [String]
      def serve(path)
        find_file(path).serve
      end
    end
  end

  class File

    # Extend a File instance with this module to allow it to be served using a
    # rack interface.
    module Servable

      # @return [String] The mime type for the file to be written.
      def mime
        Rack::Mime.mime_type ::File.extname(permalink)
      end

      # @return [Array] The files content for serving through Rack.
      def serve
        [200, {"Content-Type" => mime}, [text]]
      end
    end

    # A draft post. As drafts do not have a published date, this sets the date to
    # be tomorrow.
    module Draft
      include Post

      # @return [Date] Returns tomorrows date, since Drafts have no published date
      # yet, but it is useful to have a date for previewing.
      def date
        Date.today + 1
      end

      # @return [false] Drafts have not been published.
      def published?
        false
      end
    end

    apply %r{(^|/)drafts/}, Draft
  end

  # The sole missing file instance.
  MissingFile = Object.new

  # When served the missing file returns a 404 with appropriate message.
  def MissingFile.serve
    [404, {}, ["404 file not found"]]
  end

  # Site which adds all drafts to the list of posts.
  class DraftSite < Site

    # For the draft site speed is preferred over file size, so turn off any
    # compression.
    def defaults
      super.deep_merge compress: {
        scripts: false,
        styles:  false,
        images:  false
      }
    end

    # @return [Array<Draft>] Returns all Draft posts read from the +drafts+
    #   folder.
    def drafts
      read(:all, 'drafts').sort
    end

    # @return [Array<Post, Draft>] Sorted array of Posts and Drafts, making
    #   previewing easier.
    def posts
      weave_posts (drafts + super).sort
    end
  end

  use DraftSite
end
