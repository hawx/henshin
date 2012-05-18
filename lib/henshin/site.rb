module Henshin

  class Site

    attr_reader :root

    def initialize(root='.')
      @root = Pathname.new(root)
      @reader = Reader.new(root)

      Engines.setup config
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
        posts: posts.map(&:data),
        tags: tags.files.map(&:data),
        root: url_root,
        url:  '/'
      }

      {site: config.merge(data)}
    end

    def tags
      Tags.create(self, posts)
    end

    def style
      StylePackage.new self, @reader.read_all('assets', 'styles')
    end

    def script
      ScriptPackage.new self, @reader.read_all('assets', 'scripts')
    end

    def read(sym, *args)
      @reader.send(sym, *args).map {|p| File.create(self, p) }.sort
    end

    private :read

    def posts
      read :all, 'posts'
    end

    def templates
      read :all, 'templates'
    end

    def files
      read :safe_paths
    end

    def all_files
      files + posts + tags.files + [tags] + [style, script]
    end

    def template(*names)
      template!(names << 'default')
    end

    # @return [Template, nil]
    def template!(*names)
      names.flatten.compact.each do |name|
        template = templates.find {|t| t.name == name }
        return template unless template.nil?
      end
      EmptyTemplate.new
    end

    def write(dir)
      writer = Writer.new(dir)
      all_files.each do |file|
        file.write writer
      end
    end

  end
end
