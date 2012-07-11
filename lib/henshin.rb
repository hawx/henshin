$: << File.dirname(__FILE__)

require 'fileutils'
require 'highline'
require 'tilt'
require 'yaml'

require 'slim'
require 'redcarpet'
Object.send(:remove_const, :RedcarpetCompat) if defined?(::RedcarpetCompat)

require 'henshin/error'

require 'henshin/compressor'
require 'henshin/compressors/css'
require 'henshin/compressors/js'

require 'henshin/core_ext'
require 'henshin/path'

require 'henshin/publisher'
require 'henshin/publishers/sftp'

require 'henshin/file'
require 'henshin/files/tilt'
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

  SETTINGS = {
    colour:  true,
    dry_run: false,
    klass:   Site,
    local:   false,
    profile: false,
    quiet:   false
  }

  def set(k)
    SETTINGS[k] = true
  end

  def unset(k)
    SETTINGS[k] = false
  end

  def colour?
    SETTINGS[:colour]
  end

  def dry_run?
    SETTINGS[:dry_run]
  end

  def local?
    SETTINGS[:local]
  end

  def profile?
    SETTINGS[:profile]
  end

  def quiet?
    SETTINGS[:quiet]
  end
  
  def use(klass)
    SETTINGS[:klass] = klass
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
      site   = SETTINGS[:klass].new(root)
      writer = Writer.new(site.dest)
      site.write(writer)
    else
      UI.fail "No henshin site found, to create one use `henshin new`."
    end

    puts "#{Time.now - time}s to build site." if profile?
  end

  def publish(root, opts={})
    time = Time.now if profile?

    if site?(root)
      site = SETTINGS[:klass].new(root)

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
