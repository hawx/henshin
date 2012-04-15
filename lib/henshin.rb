require 'yaml'
require 'rack/mime'
require 'clive/output'

require 'net/sftp'
require 'highline/import'

%w(core_ext reader writer compressor tag ui engine file post template
site deployer).each do |file|
  require_relative "henshin/#{file}"
end

module Henshin
  extend self

  def profile?
    ENV['HENSHIN_PROFILE'] =~ /true/
  end

  def site?(path)
    (path + 'config.yml').exist?
  end

  # @param root [Pathname]
  # @return [Site, nil]
  def build(root, opts={})
    time = Time.now if profile?
    if site?(root)
      s = Site.new(root)
      s.build
      s
    else
      UI.fail "No henshin site found, to create one use `henshin new`."
    end
    puts "#{Time.now - time}s to build site." if profile?
  end

  def deploy(root, opts={})
    if site?(root)
      s = Site.new(root)
      SftpDeployer.deploy(s, s.config[:deploy].symbolise)
    else
      UI.fail "No henshin site found, to create one use `henshin new`."
    end
  end

end
