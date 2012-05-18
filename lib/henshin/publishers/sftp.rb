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

    def initialize(opts={})
      opts[:pass] = get_password(opts, :pass)
      requires_keys(opts, [:host, :base, :user, :pass])
      opts[:base] = Pathname.new(opts[:base])

      @opts = opts
    end

    def start(files)
      unless Henshin.dry_run?
        @sftp = Net::SFTP.start(@opts[:host], @opts[:user], password: @opts[:pass])
      end

      files.each do |file|
        next unless file.writeable?
        write(file.write_path(@opts[:base]), file.text)
        UI.uploaded file.permalink[1..-1]
      end
    end

    private

    def write(path, contents)
      return if Henshin.dry_run?

      write_dir  path.dirname
      write_file path.to_s, contents
    end

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
    rescue => err
      Error.prettify "Error writing directory: #{sub}", err
    end

    def write_file(path, contents)
      @sftp.file.open(path, 'w') do |file|
        file.puts contents.force_encoding('binary')
      end
    rescue => err
      Error.prettify "Error writing file: #{path}", err
    end

  end
end
