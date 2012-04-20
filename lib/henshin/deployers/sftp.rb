require 'net/sftp'

module Henshin

  # Deploys the site using sftp. Writes files directly to the server. Requires
  # the following configuration in config.yml:
  #
  #   deploy:
  #     host: sftp.example.com
  #     base: /path/to/public
  #     user: your_username
  #     pass: your_password
  #
  # It's a bad idea writing down your password in plain text so you can set
  # pass to be a shell command which returns your password, for example:
  #
  #   deploy:
  #     pass: $sh get-sftp-password
  #
  # would run +sh -c 'get-sftp-password'+.
  #
  class SftpDeployer < Deployer

    def initialize(site, opts={})
      @site = site

      @host = get_required_opt(opts, :host)
      @base = Pathname.new(get_required_opt(opts, :base))
      @username = get_required_opt(opts, :user)
      @password = get_password(opts, :pass)
    end

    def start
      unless Henshin.dry_run?
        @sftp = Net::SFTP.start(@host, @username, password: @password)
      end

      @site.all_files.each do |file|
        write file.write_path(@base), file.text
        UI.notify 'uploaded'.green.bold, file.permalink[1..-1]
      end
    end

    private

    def write(path, contents)
      return if Henshin.dry_run?

      write_dir path.dirname
      write_file path.to_s, contents
    end

    def exist?(path)
      @sftp.lstat!(path.to_s)
      true
    rescue Net::SFTP::StatusException
      false
    end

    def directory?(dir)
      @sftp.lstat!(dir.to_s).directory?
    rescue Net::SFTP::StatusException
      false
    end

    def write_dir(dir)
      dir.descend do |sub|
        @sftp.mkdir!(sub) unless exist?(sub)
      end
    rescue => e
      Error.prettify("Error writing directory: #{sub}", e)
    end

    def write_file(path, contents)
      @sftp.file.open(path, 'w') do |f|
        f.puts contents.force_encoding('binary')
      end
    rescue => e
      Error.prettify("Error writing file: #{path}", e)
    end

  end
end
