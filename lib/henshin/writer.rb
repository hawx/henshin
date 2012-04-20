module Henshin

  module Writer
    extend self

    # @param path [Pathname]
    # @param contents [String]
    def write(path, contents)
      return if Henshin.dry_run?

      write_dir path.dirname
      write_file path, contents
    end

    private

    def write_dir(dir)
      FileUtils.mkdir_p(dir)
    end

    def write_file(path, contents)
      ::File.open path, 'w' do |file|
        file.write contents
      end
    end

  end
end
