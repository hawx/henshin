module Henshin

  # Allows files to be written to the local file system.
  class Writer

    # @param root [Pathname] Path to where the Site is being written, individual
    #   file paths are calculated from this root.
    def initialize(root)
      @root = root
    end

    # Writes the +contents+ to the +path+ given.
    #
    # @param path [Pathname] Path of file to write
    # @param contents [String] Contents of file to write
    def write(path, contents)
      return if Henshin.dry_run?

      write_dir @root + path.dirname
      write_file @root + path, contents
    end

    private

    # Creates a directory at +dir+.
    #
    # @param dir [Pathname] Path of directory to create
    def write_dir(dir)
      FileUtils.mkdir_p(dir)
    end

    # Writes the file at +path+ with the +contents+ given.
    #
    # @param path [Pathname] Path to file to be written
    # @param contents [String] Text to write to the file
    def write_file(path, contents)
      ::File.open path.to_s, 'w' do |file|
        file.write contents
      end
    end

  end
end
