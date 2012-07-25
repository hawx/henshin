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

  class AbstractFile
    module Servable
      # @return [String] The mime type for the file to be written.
      def mime
        Rack::Mime.mime_type ::File.extname(permalink)
      end

      # Returns the files content for serving through Rack.
      def serve
        [200, {"Content-Type" => mime}, [text]]
      end
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

  module Post

    # @return [true] Posts have been published.
    # @see Draft#published?
    def published?
      true
    end
  end

  File.apply %r{(^|/)drafts/}, Draft

  # The sole missing file instance.
  MissingFile = Object.new

  # When served the missing file returns a 404 with appropriate message.
  def MissingFile.serve
    [404, {}, ["404 file not found"]]
  end

  # Site which adds all drafts to the list of posts.
  class DraftSite < Site

    # For the draft site speed is preferred over "smallness" so turn off any
    # compression.
    def defaults
      super.deep_merge compress: {
        scripts: false,
        styles:  false,
        images:  false
      }
    end

    # @return [Array<Draft>] Returns all draft posts read from the +drafts+
    # folder.
    def drafts
      read(:all, 'drafts').sort
    end

    # @return [Array<Post, Draft>] To make previewing draft posts in a site
    # easier drafts are mixed into the posts.
    def posts
      weave_posts(drafts + super)
    end
  end

  use DraftSite
end
