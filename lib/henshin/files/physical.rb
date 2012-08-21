module Henshin

  class File

    # A file physically located on the file system. A subclass of file will
    # have a @path variable with it's location.
    class Physical < Abstract

      # Regular expression to match the text of the file, contains two match
      # groups; the first matches the yaml part, the second any text.
      YAML_REGEX = /\A---\n^(.*?)\n^---\n?(.*)\z/m

      # @param site [Site] Site the file is in.
      # @param path [Pathname] Path to the file.
      def initialize(site, path)
        @site = site
        @path = path
      end

      # Allow yaml attributes to be accessed in templates.
      def method_missing(sym, *args, &block)
        if yaml.key?(sym)
          yaml[sym]
        else
          nil
        end
      end

      # Allow template to be set, needed for Template to work properly.
      def template
        @template || yaml[:template]
      end

      def yield
        text
      end

      # @return [String] Text of the file.
      def raw_text
        read[1]
      end

      # @return [Path] If a permalink has been set in the yaml frontmatter uses
      #   that, otherwise uses the path to the file.
      def path
        if yaml.key?(:permalink)
          Path @site.root, yaml[:permalink]

        else
          rel = @path

          if @path.same_type?(@site.source)
            rel = @path.relative_path_from(@site.source)
          end

          if @path.basename.to_s.count('.') == 1
            Path @site.root, rel
          else
            ext  = @path.extname
            file = rel.to_s[0..-ext.size-1]
            Path @site.root, file
          end
        end
      end

      private

      # Reads the file, splitting it in to two parts; the yaml and the text.
      #
      # @example
      #
      #   file = File.new(site, "hello-world.md")
      #   file.read
      #   #=> ["title: Hello World\ndate:  2012-02-03",
      #   #    "Hello, world!"]
      #
      # @return [Array<String>] An array of two parts. The first is the yaml part
      #   of the file, the second is the text part.
      def read
        contents = @path.read || ""
        if match = contents.match(YAML_REGEX)
          match.to_a[1..2]
        else
          ['', contents]
        end
      end

      # @return [Hash{Symbol=>Object}] Returns the data loaded from the file's
      #   yaml frontmatter.
      def yaml
        loaded = Henshin.load_yaml read[0]

        singleton_class.ancestors.find_all {|klass|
          klass.singleton_class.include?(Attributes)

        }.map {|klass|
          klass.required.to_a

        }.flatten.reject {|key|
        respond_to?(key) || loaded.key?(key)

        }.each {|key|
          UI.fail(inspect + " requires #{key}.")
        }

        loaded
      end

    end
  end
end
