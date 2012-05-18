module Henshin

  class Writer

    # @param base [Pathname]
    def initialize(base)
      @base = base
    end

    # @param path [Pathname]
    # @param contents [String]
    def write(path, contents)
      return if Henshin.dry_run?

      write_dir @base + path.dirname
      write_file @base + path, contents
    end

    private

    def write_dir(dir)
      FileUtils.mkdir_p(dir)
    end

    def write_file(path, contents)
      ::File.open path.to_s, 'w' do |file|
        file.write contents
      end
    end

  end
end
