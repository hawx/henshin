require 'net/sftp'

module Henshin

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
  class SftpPublisher < Publisher

    def self.create(opts={})
      opts[:pass] = get_password(opts, :pass)
      requires_keys(opts, [:host, :base, :user, :pass])
      opts[:base] = Pathname.new(opts[:base])

      sftp = nil
      unless Henshin.dry_run?
        sftp = Net::SFTP.start(@opts[:host], @opts[:user], password: @opts[:pass])
      end

      SftpPublisher::Writer.new(sftp, @opts[:base])
    end

    class Writer
      def initialize(sftp, root)
        @sftp = sftp
        @root = root
      end

      def write(path, contents)
        return if Henshin.dry_run?

        write_dir @root + path.dirname
        write_file @root + path, contents
      end

      private

      def exist?(path)
        @sftp.lstat!(path.to_s)
        true
      rescue Net::SFTP::StatusException
        false
      end

      def write_dir(dir)
        dir.descend do |sub|
          @sftp.mkdir!(sub) unless exist?(sub)
        end
      end

      def write_file(path, contents)
        @sftp.file.open(path.to_s, 'w') do |file|
          file.puts contents.force_encoding('binary')
        end
      end
    end

  end
end
