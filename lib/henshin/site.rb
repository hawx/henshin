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
      return unless folder

      define_method name do
        read :all, folder
      end
    end


    attr_reader :root

    def initialize(root='.')
      @reader = Reader.new(root)
      @root   = Pathname.new(root)
    end

    # Root url, this is guaranteed to begin and end with a forward-slash.
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

    def data
      data = {
        style: url_root + 'style.css',
        script: url_root + 'script.js',
        tags: tags.map(&:data),
        root: url_root,
        url:  '/'
      }

      list = Hash[files_list.map {|files| [files, send(files).map(&:data)] }]
      data.merge!(list)

      {site: config.merge(data)}
    end

    def tags
      Tags.create(self, posts)
    end

    # TODO: Fix tags, returns wrong thing!
    # files :tags

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

    files :posts, 'posts'

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
