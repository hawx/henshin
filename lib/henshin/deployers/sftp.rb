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
      @sftp = Net::SFTP.start(@host, @username, password: @password)

      @site.all_files.each do |file|
        write file.write_path(@base), file.text
        UI.notify 'uploaded'.green.bold, file.permalink[1..-1]
      end
    end

    private

    def write(path, contents)
      write_dir path.dirname.to_s
      write_file path.to_s, contents
    end

    def exist?(path)
      @sftp.lstat!(path)
      true
    rescue Net::SFTP::StatusException
      false
    end

    def directory?(dir)
      @sftp.lstat!(dir).directory?
    rescue Net::SFTP::StatusException
      false
    end

    def write_dir(dir)
      @sftp.mkdir!(dir) unless directory?(dir)
    end

    def write_file(path, contents)
      @sftp.file.open(path, 'w') do |f|
        f.puts contents.force_encoding('binary')
      end
    end

  end
end
