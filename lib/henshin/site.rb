require 'attr_plus/class'

module Henshin

  DEFAULT_TEMPLATE = 'default'

  class Site

    class_attr_accessor :files_list, :file_list, :default => []

    def self.file(name)
      file_list << name
    end

    # @example
    #
    #   files :posts, 'posts'
    #
    def self.files(name, folder=nil)
      files_list << name

      if folder
        define_method name do
          read :all, folder
        end
      end
    end


    attr_reader :root

    def initialize(root='.')
      @reader = Reader.new(root)
      @root   = Pathname.new(root)
    end

    # Destination folder to build into. Uses destination set in config if
    # available, which can be either a relative path or absolute.
    #
    # @return [Pathname]
    def dest
      @root + (config[:dest] || 'build')
    end

    # Root url, this is guaranteed to begin and end with a forward-slash.
    #
    # @return [Pathname]
    def url_root
      u = config[:root] || '/'
      u = '/' + u if u[0] != '/'
      u = u + '/' if u[-1] != '/'
      Pathname.new(u)
    end

    def defaults
      {
        sass: {
          load_paths: [@root + 'assets' + 'styles']
        },
        redcarpet: {
          no_intra_emphasis:  true,
          fenced_code_blocks: true,
          strikethrough:      true,
          superscript:        true
        }
      }
    end

    def config
      defaults.merge Henshin.load_yaml (@root + 'config.yml').read
    end

    def basic_data
      {
        root: url_root
      }
    end

    def data
      list = Hash[(files_list + file_list).map {|file| [file, send(file)] }]

      {
        site:   config.merge(basic_data)
      }.merge(list)
    end

    class Scope
      def initialize(hash)
        meta = (class << self; self; end)

        hash.each do |name, val|
          case val
          when ::Hash
            meta.send(:define_method, name) { Scope.new(val) }
          when ::Array
            meta.send(:define_method, name) {
              val.map {|i|
                i.is_a?(::Hash) ? Scope.new(i) : i
              }
            }
          else
            meta.send(:define_method, name) { val }
          end
        end
      end

      def method_missing(sym, *args)
        nil
      end
    end

    def data_for(file)
      obj = file.dup

      data.each do |key, val|
        (class << obj; self; end).send(:define_method, key) {
          val.is_a?(Hash) ? Scope.new(val) : val
        }
      end

      obj
    end

    def style
      StylePackage.new self, @reader.read_all('assets', 'styles')
    end

    file :style

    def script
      ScriptPackage.new self, @reader.read_all('assets', 'scripts')
    end

    file :script

    def read(sym, *args)
      @reader.send(sym, *args).map {|p| File.create(self, p) }.sort
    end

    private :read

    def posts
      posts = read(:all, 'posts').sort

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

    files :posts

    def templates
      read :all, 'templates'
    end

    def files
      read :safe_paths
    end

    files :files

    def all_files
      files_list.map {|fs| send(fs) }.reduce(:+) + file_list.map {|f| send(f) }
    end

    def template(name, data)
      find_template(name, true).template(data)
    end

    def has_template?(name)
      templates.any? {|t| t.name == name }
    end

    # @return [Template, nil]
    def find_template(name, default=false)
      template = templates.find {|t| t.name == name }
      return template if template

      if default
        template = templates.find {|t| t.name == DEFAULT_TEMPLATE }
        return template if template
      end

      EmptyTemplate.new
    end

    def write(writer)
      all_files.each do |file|
        file.write writer
      end
      self
    end

  end
end
