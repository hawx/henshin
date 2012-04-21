module Henshin

  class Site

    attr_reader :root

    def initialize(root='.')
      @root = Pathname.new(root)
      @reader = Reader.new(root)

      CoffeeScriptEngine.setup
      RedcarpetEngine.setup
      SassEngine.setup load_paths: [@root + 'assets' + 'styles']
      SlimEngine.setup
    end

    # Root url, this is guaranteed to begin and end with a forward-slash.
    def url_root
      u = config[:root] || '/'
      u = '/' + u if u[0] != '/'
      u = u + '/' if u[-1] != '/'
      u
    end

    def config
      Henshin.load_yaml (@root + 'config.yml').read
    end

    def data
      data = {
        style: url_root + 'style.css',
        script: url_root + 'script.js',
        posts: posts.map(&:data),
        tags: tags.data,
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

    def posts
      @reader.read_all('posts').map {|p| Post.new(self, p) }.sort
    end

    def files
      @reader.safe_paths.map do |path|
        File.create(self, path)
      end
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
        path = @reader.read('templates', "#{name}.*").first
        return Template.new(self, path) if path
      end
      nil
    end

    def write(dir)
      all_files.each do |file|
        file.write(dir)
      end
    end

  end
end
