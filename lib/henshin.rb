$: << File.dirname(__FILE__)

require 'yaml'

require 'henshin/error'

require 'henshin/compressor'
require 'henshin/compressors/css'
require 'henshin/compressors/js'

require 'henshin/core_ext'
require 'henshin/path'

require 'henshin/publisher'
require 'henshin/publishers/sftp'

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
require 'henshin/files/tag'
require 'henshin/files/tags'
require 'henshin/files/empty_template'
require 'henshin/files/roles/post'
require 'henshin/files/roles/template'

require 'henshin/package'
require 'henshin/packages/script'
require 'henshin/packages/style'

require 'henshin/reader'
require 'henshin/site'
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

  def colour?
    $COLOUR != false
  end

  def quiet?
    $QUIET == true
  end

  def site?(path)
    (path + 'config.yml').exist?
  end

  def eval_init(root)
    if (root + 'init.rb').exist?
      eval (root + 'init.rb').read
    end
  end

  # @param root [Pathname]
  # @return [Site, nil]
  def build(root, opts={})
    time = Time.now if profile?

    if site?(root)
      site   = Site.new(root)
      writer = Writer.new(root + 'build')
      site.write(writer)
    else
      UI.fail "No henshin site found, to create one use `henshin new`."
    end

    puts "#{Time.now - time}s to build site." if profile?
  end

  def publish(root, opts={})
    time = Time.now if profile?

    if site?(root)
      site = Site.new(root)

      unless site.config.has_key?(:publish)
        UI.fail "No publish configuration in config.yml."
      end

      writer = SftpPublisher.create(site.config[:publish])
      site.write(writer)
    else
      UI.fail "No henshin site found, to create one use `henshin new`."
    end

    puts "#{Time.now - time}s to publish site." if profile?
  end

end
