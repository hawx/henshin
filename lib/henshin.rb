$: << File.dirname(__FILE__)

require 'attr_plus/class'
require 'fileutils'
require 'hashie/mash'
require 'highline'
require 'tilt'
require 'yaml'

require 'slim'
require 'redcarpet'
Object.send(:remove_const, :RedcarpetCompat) if defined?(::RedcarpetCompat)

require 'henshin/error'
require 'henshin/safety'

require 'henshin/compressor'
require 'henshin/compressors/css'
require 'henshin/compressors/js'

require 'henshin/core_ext'
require 'henshin/path'
require 'henshin/scope'

require 'henshin/writer'
require 'henshin/publisher'
require 'henshin/publishers/sftp'

require 'henshin/file'
require 'henshin/files/attributes'
require 'henshin/files/abstract'
require 'henshin/files/physical'
require 'henshin/files/templatable'

require 'henshin/files/empty_template'
require 'henshin/files/post'
require 'henshin/files/template'
require 'henshin/files/tilt'
require 'henshin/files/tilt_template'

require 'henshin/package'
require 'henshin/packages/script'
require 'henshin/packages/style'

require 'henshin/reader'
require 'henshin/site'
require 'henshin/ui'
require 'henshin/version'

module Henshin
  extend self

  # Loads the yaml text given returning a Hash with symbol keys.
  #
  # @param text [String]
  # @return [Hash{Symbol=>Object}]
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

  # Sets a global Henshin setting.
  #
  # @param key [Symbol]
  # @example
  #
  #   Henshin.set :colour
  #   Henshin.colour? #=> true
  #
  def set(key)
    SETTINGS[key] = true
  end

  # Unsets a global Henshin setting.
  #
  # @param key [Symbol]
  # @example
  #
  #   Henshin.unset :colour
  #   Henshin.colour? #=> false
  #
  def unset(key)
    SETTINGS[key] = false
  end

  # @return Whether to display colourful output.
  def colour?
    SETTINGS[:colour]
  end

  # @return Whether to write files to disk.
  def dry_run?
    SETTINGS[:dry_run]
  end

  # @return Whether to use local referencing urls.
  # @note This is very much work in progress and does break!
  def local?
    SETTINGS[:local]
  end

  # @return Whether to calculate profiling data.
  def profile?
    SETTINGS[:profile]
  end

  # @return Whether to only show vital output.
  def quiet?
    SETTINGS[:quiet]
  end

  # Set the Site class that is used to build the site.
  #
  # @param klass [Class]
  # @example
  #
  #   class MyCoolSite < Henshin::Site
  #     # ...
  #   end
  #
  #   Henshin.use MyCoolSite
  #
  def use(klass)
    SETTINGS[:klass] = klass
  end

  # Evaluates the +init.rb+ file if it exists.
  #
  # @param root [Pathname] Root of the site.
  def eval_init(root)
    if (root + 'init.rb').exist?
      eval (root + 'init.rb').read
    end
  end

  # Builds the site in +root+.
  #
  # @param root [Pathname]
  def build(root, opts={})
    time = Time.now if profile?

    site   = SETTINGS[:klass].new(root)
    writer = Writer.new(site.dest)
    site.write(writer)

    puts "#{Time.now - time}s to build site." if profile?
  end

  # Publishes the site in +root+.
  #
  # @param root [Pathname]
  def publish(root, opts={})
    time = Time.now if profile?

    site = SETTINGS[:klass].new(root)

    unless site.config.has_key?(:publish)
      UI.fail "No publish configuration in config.yml."
    end

    writer = Publisher::Sftp.create(site.config[:publish])
    site.write(writer)

    puts "#{Time.now - time}s to publish site." if profile?
  end

end
