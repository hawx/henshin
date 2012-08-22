module Henshin

  class File

    # @abstract You will want to implement {#raw_text}, {#path} and maybe
    #   {#text}.
    #
    # This class implements all the functionality that is required to build or
    # serve a file. {Abstract} instances do not relate to a file in the file
    # system, use {Physical} in this case.
    class Abstract

      include  Henshin::Helpers, Comparable
      extend   Attributes

      attr_reader :site

      def initialize(site)
        @site = site
      end

      # Simple version of text. This is raw in that it has not been run through
      # a template. It may still have been passed through an ordinary rendering
      # engine (for instance a Markdown engine).
      #
      # @return [String]
      # @see #text
      def raw_text
        ""
      end

      # @return [String] Text to write to the file.
      def text
        raw_text
      end

      # @return [Path] Path to the file.
      def path

      end

      # @return [String] The absolute url to the file.
      def permalink
        path.permalink
      end

      # @return [Pathname] A pretty url to the file, the permalink with
      #   'index.html' stripped from the end generally.
      def url
        path.url
      end

      # @return [String] Extension for the file to be written.
      def extension
        path.extension
      end

      # Allow template to be set, needed for Template to work properly.
      def template
        @template || nil
      end
      attr_writer :template

      # Writes the file.
      #
      # @param writer [#write] Object which is able to write text to a path.
      def write(writer)
        return unless writeable?
        start = Time.now if Henshin.profile?
        writer.write Pathname.new(permalink.sub(/^\//, '')), text
        if Henshin.profile?
          UI.wrote permalink, (Time.now - start)
        else
          UI.wrote permalink
        end
      rescue => e
        Error.prettify("Error writing #{inspect}", e)
      end

      # Compares the files based on their permalinks.
      #
      # @param other [File]
      def <=>(other)
        permalink <=> other.permalink
      end

      def inspect
        "#<#{self.class} #{permalink}>"
      end

      private

      # @return Whether this file should be written.
      def writeable?
        true
      end

    end
  end
end
