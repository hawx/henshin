require 'net/sftp'

module Henshin

  class Publisher

    # Publishes the site using sftp. Writes files directly to the server. Requires
    # the following configuration in config.yml:
    #
    #   publish:
    #     host: sftp.example.com
    #     base: /path/to/public
    #     user: your_username
    #     pass: your_password
    #
    # It's a bad idea writing down your password in plain text so you can set
    # pass to be a shell command which returns your password, for example:
    #
    #   publish:
    #     pass: $sh get-sftp-password
    #
    # would run +sh -c 'get-sftp-password'+.
    #
    class Sftp < Publisher

      def self.create(opts={})
        opts[:pass] = get_password(opts, :pass)
        requires_keys(opts, [:host, :base, :user, :pass])
        opts[:base] = Pathname.new(opts[:base])

        sftp = nil
        unless Henshin.dry_run?
          sftp = Net::SFTP.start(opts[:host], opts[:user], password: opts[:pass])
        end

        new(sftp, opts[:base])
      end

      # @param sftp [Net::SFTP::Session] Connected session to use for transfers
      # @param root [Pathname] Directory to write Site into
      def initialize(sftp, root)
        @sftp = sftp
        @root = root
      end

      private

      # @param path [Pathname] Path to check
      # @return Whether +path+ exists
      def exist?(path)
        @sftp.lstat!(path.to_s)
        true
      rescue Net::SFTP::StatusException
        false
      end

      # Creates a directory at +dir+.
      #
      # @param dir [Pathname] Path of directory to create
      def write_dir(dir)
        dir.descend do |sub|
          @sftp.mkdir!(sub) unless exist?(sub)
        end
      end

      # Writes the file at +path+ with the +contents+ given.
      #
      # @param path [Pathname] Path to file to be written
      # @param contents [String] Text to write to the file
      def write_file(path, contents)
        file = @sftp.file
        file.open(path.to_s, 'w') do |file|
          file.puts contents.force_encoding('binary')
        end
      end

    end
  end
end
