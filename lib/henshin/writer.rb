module Henshin

  module Writer
    extend self

    @dry_run = false

    def dry_run!
      @dry_run = true
    end

    def real!
      @dry_run = false
    end

    def dry_run?
      @dry_run
    end

    # @param path [Pathname]
    # @param contents [String]
    def write(path, contents)
      return if dry_run?

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
