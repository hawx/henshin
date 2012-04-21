module Henshin

  class Reader

    RESERVED_DIRS = %w(assets drafts posts templates build)

    # @param root [Pathname] Path to read under.
    def initialize(root)
      @root = root
      @ignore = ['config.yml', 'init.rb']
    end

    # Adds the list of files given to the list to be ignored.
    #
    # @param files [Array<String>]
    def ignore(*files)
      @ignore += files
    end

    # @param path [String]
    # @return Whether the path given is to be ignored. Returns true if the path
    #   is to be ignored, see #ignore; or if the path, or any directory above,
    #   begins with an underscore.
    def ignore?(path)
      path = Pathname.new(path).relative_path_from(@root)
      return true if @ignore.include?(path.to_s)
      path.ascend {|p| return true if p.basename.to_s[0] == "_" }
    end

    # Reads the files using the glob pattern given. Ignores files matching
    # {#ignore?}.
    #
    # @example
    #
    #   reader.read('assets', '**', '*')
    #   #=> [#<Pathname:assets/styles/screen.sass>, ...]
    #
    # @param path [Array<String>]
    # @return [Array<Pathname>]
    def read(*path)
      glob = path.flatten.inject(@root, :+)
      Pathname.glob(glob).reject {|p| p.directory? || ignore?(p) }
    end

    # Reads all files under the path given.
    #
    # @param path [Array<String>]
    # @return [Array<Pathname>]
    def read_all(*path)
      read(path << '*')
    end

    # Reads all paths under the root this Reader was initialised with.
    #
    # @return [Array<Pathname>]
    def all_paths
      read_all '**'
    end

    # Reads all paths under the root this Reader was initialised with, but
    # ignores all those under "reserved directories". These are directories used
    # by henshin for posts, templates, etc.
    #
    # @return [Array<Pathname>]
    def safe_paths
      all_paths - read_all("{#{RESERVED_DIRS.join(',')}}", '**')
    end

  end
end
