module Henshin

  DEFAULT_TEMPLATE = 'default'

  # The Site represents a site in the filesystem, it is in charge of reading and
  # writing files.
  class Site

    # Error for when a path given to {Site#initialize} does not contain a
    # config.yml file.
    class NotSiteError < StandardError

      # @param place [Pathname, String] Path where site is expected
      def initialize(place)
        @place = place
      end

      def message
        <<EOS
'#{@place}' does not contain a henshin site. No config.yml can be found.
Create one using `henshin new`, or find out more by reading `henshin help`.
EOS
      end

      # @return Empty array as backtrace is unnecessary.
      def backtrace
        []
      end
    end

    class_attr_accessor :files_list, :file_list, :ignore_list, :default => []

    # Adds the methods specified to the file list. These methods must returns
    # a single File object (or subclass). This adds the File to those returned
    # by {#all_files}, and so they will be written and served properly.
    #
    # @param names [Symbol]
    # @see .files
    # @example
    #
    #   class IndexFile < File::Abstract
    #     # ...
    #   end
    #
    #   class IndexedSite < Site
    #     def index
    #       IndexFile.new(self)
    #     end
    #
    #     file :index
    #   end
    #
    def self.file(*names)
      names.each {|n| file_list << n }
    end

    # Adds the methods specified to the files list. These methods must return
    # a list of File objects (or subclasses). This adds the Files to those
    # returned by {#all_files}, and so they will be written and served
    # properly.
    #
    # @param names [Symbol]
    # @see .file
    # @example
    #
    #   class Recipe < File::Physical
    #     # ...
    #   end
    #
    #   class RecipeSite < Site
    #     def recipes
    #       @reader.read_all('recipes').map do |path|
    #         Recipe.new(self, path)
    #       end
    #     end
    #
    #     files :recipes
    #   end
    #
    def self.files(*names)
      names.each {|n| files_list << n }
    end

    # Makes this site ignore the paths given. This has the same effect as
    # setting the ignore option in a site's +config.yml+, but has effect for any
    # site using this specific class, regardless of the config.
    #
    # @param paths [String]
    # @example
    #
    #   class DataSite
    #     ignore 'data'
    #     # ...
    #   end
    #
    def self.ignore(*paths)
      paths.each {|p| ignore_list << p }
    end

    # Creates a new instance of Site.
    #
    # @param root [String, Pathname]
    #   Path to where the site is located.
    #
    # @raise [NotSiteError]
    #   Raised if +root+ does not contain a +config.yml+ file.
    #
    def initialize(root='.')
      @reader = Reader.new(root)
      @source = Pathname.new(root)

      unless (@source + 'config.yml').exist?
        raise NotSiteError, @source
      end

      @reader.ignore *ignore_list
      if config[:ignore]
        @reader.ignore *config[:ignore]
      end
    end

    # @return [Pathname] Path of site being read
    attr_reader :source

    # Destination folder to build into. Uses destination set in config if
    # available which can be either a relative path or absolute. By default uses
    # 'build'.
    #
    # @return [Pathname] Path to build site to
    def dest
      @source.expand_path + (config[:dest] || 'build')
    end

    # Root url, this is guaranteed to begin and end with a forward-slash. All
    # urls and permalinks should begin with this. Uses +:root+ option from
    # config if set, otherwise defaults to using +/+.
    #
    # @return [Pathname] Root url
    def root
      u = config[:root] || '/'
      u = '/' + u if u[0] != '/'
      u = u + '/' if u[-1] != '/'
      Pathname.new(u)
    end

    # @return [Hash] Defaults to for the Site.
    def defaults
      {
        permalink: '/:title/index.html',
        sass: {
          load_paths: [@source + 'assets' + 'styles']
        },
        md: {
          no_intra_emphasis:  true,
          fenced_code_blocks: true,
          strikethrough:      true,
          superscript:        true
        },
        compress: {
          scripts: true,
          styles:  true,
          images:  true
        }
      }
    end

    private :defaults

    # @return [Hashie::Mash] Loaded contents of +config.yml+.
    def yaml
      Hashie::Mash.new Henshin.load_yaml (@source + 'config.yml').read
    end

    private :yaml

    # @return [Hashie::Mash] Returns the configuration for the Site object, this
    #   is the combination of the options loaded from +config.yml+ and the
    #   defaults.
    def config
      Hashie::Mash.new defaults.merge(yaml)
    end

    # @return [Package::Script] The script package file. This is a combined and
    #   minified file containing the contents of the files in +assets/scripts+.
    def script
      Package::Script.new self, @reader.read_all('assets', 'scripts')
    end

    # @return [Package::Style] The style package file. This is a combined and
    #   minified file containing the contents of the files in +assets/styles+.
    def style
      Package::Style.new self, @reader.read_all('assets', 'styles')
    end

    file :script, :style

    # @return [Array<File::Post>] The Posts read from the +posts+ folder.  These
    #   are sorted and all posts have had the next and previous posts set
    #   correctly.
    def posts
      weave_posts read(:all, 'posts')
    end

    # @return [Array<File>] Returns all other files, those which have no special
    #   meaning to Henshin.
    def files
      read :safe_paths
    end

    files :posts, :files

    # @return [Array<File>] Returns a list of all files set using {.files} and
    #   {.file}. These are the files which should be written, served, etc.
    def all_files
      files_list.map {|fs| send(fs) }.reduce(:+) + file_list.map {|f| send(f) }
    end

    # @return [Array<File::Template>] Returns a list of all template files read from
    #   the +templates+ directory.
    def templates
      read :all, 'templates'
    end

    # Reads the paths using the method specified. It returns not a list of
    # Pathname objects but the correct File objects, using {File.create}.
    #
    # @param sym [Symbol] Method to use for reading.
    # @param args Any arguments to pass along with +sym+.
    def read(sym, *args)
      @reader.send(sym, *args).map {|p| File.create(self, p) }.sort
    end

    private :read

    # For the given posts sets the correct previous and next posts.
    #
    # @param posts [Array<#next=,#prev=>] List of Post objects, must be sorted.
    def weave_posts(posts)
      posts.each_index do |i|
        if i < posts.length
          posts[i].prev = posts[i+1]
        end

        if i > 0
          posts[i].next = posts[i-1]
        end
      end

      posts
    end

    private :weave_posts

    # If +sym+ is a key in the loaded +config.yml+ file, the value is returned,
    # otherwise returns +nil+. This is so the Site object itself can be passed
    # to templates.
    def method_missing(sym, *args, &block)
      if yaml.key?(sym)
        yaml[sym]
      else
        nil
      end
    end

    # Writes the site using the given +writer+.
    #
    # @param writer [#write]
    # @example
    #
    #   class MyWriter
    #     def write(path, contents)
    #       # ...
    #     end
    #   end
    #
    #   site.write MyWriter.new
    #
    def write(writer)
      all_files.each do |file|
        file.write writer
      end
      self
    end

    # Finds the template with the name given. Given a list of names it tries to
    # find a template for a single name working down the list, this allows
    # "fallback" options to be given. If none are found it returns an instance
    # of the {File::EmptyTemplate}.
    #
    # @param names [String]
    # @return [File::Template, File::EmptyTemplate]
    # @example
    #
    #   site.template('recipe', Henshin::DEFAULT_TEMPLATE)
    #   #=> #<Henshin::File::Template ...>
    #
    def template(*names)
      names.each do |name|
        if tmp = templates.find {|t| t.name == name }
          return tmp
        end
      end

      File::EmptyTemplate.new
    end

  end
end
