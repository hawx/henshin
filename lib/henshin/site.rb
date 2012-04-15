module Henshin

  class Site

    attr_reader :root

    def initialize(root='.')
      @root = Pathname.new(root)
      @reader = Reader.new(root)

      CoffeeScriptEngine.setup
      RedcarpetEngine.setup
      SassEngine.setup
      SlimEngine.setup
    end


    # Root url, this is guaranteed to begin and end with a forward-slash.
    def url_root
      u = config[:root] || '/'
      u = '/' + u if u[0] != '/'
      u = u + '/' if u[-1] != '/'
      u
    end

    def build_path
      @root + ('build' + url_root)
    end

    def build
      write build_path
    end

    def config
      YAML.load_file(@root + 'config.yml').symbolise
    end

    def data
      {
        site:   config.merge(style: url_root + 'style.css',
                             script: url_root + 'script.js'),
        posts:  posts.map(&:data),
        tags:   tags.data,
        root:   url_root
      }
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

    def posts
      @reader.read_all('posts').map {|p| Post.new(self, p) }.sort
    end

    def files
      @reader.safe_paths.map do |path|
        File.create(self, path)
      end
    end

    def all_files
      files + posts + [style, script]
    end

    def template(*names)
      names << 'default'
      names.each do |name|
        path = @root + 'templates' + "#{name}.slim"
        return Template.new(self, path) if path.exist?
      end
    end

    def write(dir)
      (files + posts + [script, style]).each do |file|
        file.write(dir)
      end
    end

  end
end
