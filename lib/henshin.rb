$: << File.dirname(__FILE__)

require 'yaml'

require 'henshin/compressor'
require 'henshin/compressors/css'
require 'henshin/compressors/js'

require 'henshin/core_ext'

require 'henshin/deployer'
require 'henshin/deployers/sftp'

require 'henshin/engine'
require 'henshin/engines/coffeescript'
require 'henshin/engines/redcarpet'
require 'henshin/engines/sass'
require 'henshin/engines/slim'

require 'henshin/file'
require 'henshin/files/coffeescript'
require 'henshin/files/redcarpet'
require 'henshin/files/sass'
require 'henshin/files/slim'
require 'henshin/files/post'
require 'henshin/files/template'

require 'henshin/package'
require 'henshin/packages/script'
require 'henshin/packages/style'

require 'henshin/reader'
require 'henshin/site'
require 'henshin/tag'
require 'henshin/ui'
require 'henshin/writer'
require 'henshin/version'

module Henshin
  extend self

  def load_yaml(text)
    (YAML.load(text) || {}).symbolise
  end

  def profile?
    $PROFILE == true
  end

  def dry_run?
    $DRY_RUN == true
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

      unless s.config.has_key?(:deploy)
        UI.fail "No deploy configuration in config.yml."
      end

      SftpDeployer.deploy(s, s.config[:deploy])
    else
      UI.fail "No henshin site found, to create one use `henshin new`."
    end
  end

end
