module Henshin

  class Reader

    RESERVED_DIRS = %w(assets drafts posts templates build)

    def initialize(root)
      @root = root
      @ignore = ['config.yml']
    end

    def ignore(*files)
      @ignore += files
    end

    def ignore?(path)
      path = Pathname.new(path).relative_path_from(@root)
      return true if @ignore.include?(path.to_s)
      path.ascend {|p| return true if p.basename.to_s[0] == "_" }
    end

    def read(*path)
      glob = path.flatten.inject(@root, :+)
      Pathname.glob(glob).reject {|p| p.directory? || ignore?(p) }
    end

    def read_all(*path)
      read(path << '*')
    end

    def all_paths
      read_all '**'
    end

    def safe_paths
      all_paths - read_all("{#{RESERVED_DIRS.join(',')}}", '**')
    end

  end
end
