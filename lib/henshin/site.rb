module Henshin

  DEFAULT_TEMPLATE = 'default'

  class Site

    class_attr_accessor :files_list, :file_list, :default => []

    def self.file(*names)
      names.each {|n| file_list << n }
    end

    def self.files(*names)
      names.each {|n| files_list << n }
    end


    attr_reader :source

    def initialize(root='.')
      @reader = Reader.new(root)
      @source = Pathname.new(root)

      if config[:ignore]
        @reader.ignore *config[:ignore]
      end
    end

    # Destination folder to build into. Uses destination set in config if
    # available, which can be either a relative path or absolute.
    #
    # @return [Pathname]
    def dest
      source + (config[:dest] || 'build')
    end

    # Root url, this is guaranteed to begin and end with a forward-slash.
    #
    # @return [Pathname]
    def root
      u = config[:root] || '/'
      u = '/' + u if u[0] != '/'
      u = u + '/' if u[-1] != '/'
      Pathname.new(u)
    end

    def defaults
      {
        sass: {
          load_paths: [source + 'assets' + 'styles']
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

    def yaml
      Hashie::Mash.new Henshin.load_yaml (source + 'config.yml').read
    end

    def config
      Hashie::Mash.new defaults.merge(yaml)
    end


    def script
      ScriptPackage.new self, @reader.read_all('assets', 'scripts')
    end

    def style
      StylePackage.new self, @reader.read_all('assets', 'styles')
    end

    file :script, :style

    def posts
      weave_posts read(:all, 'posts').sort
    end

    def files
      read :safe_paths
    end

    files :posts, :files

    def all_files
      files_list.map {|fs| send(fs) }.reduce(:+) + file_list.map {|f| send(f) }
    end

    def templates
      read :all, 'templates'
    end


    def read(sym, *args)
      @reader.send(sym, *args).map {|p| File.create(self, p) }.sort
    end

    private :read

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


    def method_missing(sym, *args, &block)
      if yaml.key?(sym)
        yaml[sym]
      else
        nil
      end
    end

    def write(writer)
      all_files.each do |file|
        file.write writer
      end
      self
    end

    def template(*names)
      names.each do |name|
        if tmp = templates.find {|t| t.name == name }
          return tmp
        end
      end

      EmptyTemplate.new
    end

  end
end
