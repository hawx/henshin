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
      
      path.ascend do |part| 
        return true if part.basename.to_s[0] == "_" 
        return true if @ignore.include?(part.to_s)
      end
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

    alias_method :all, :read_all

    # Reads all paths under the root this Reader was initialised with, but
    # ignores all those under "reserved directories". These are directories used
    # by henshin for posts, templates, etc.
    #
    # @return [Array<Pathname>]
    def safe_paths
      read_all('**') - read_all("{#{RESERVED_DIRS.join(',')}}", '**')
    end

  end
end
