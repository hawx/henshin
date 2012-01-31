#!/usr/bin/env ruby

# This will contain the basic clive command set that most of the
# time you will want to inherit. Nothing too specific goes here.
#
# Usage: henshin [command] [options]
#        henshin ... [source] [dest]
#
#   Commands:
#     henshin serve --port 1000 --server Thin --no-reload
#     henshin new {post, layout, ...}
#     # should provide hooks for file types to add themselves here eg. Post
#

require 'clive'
require 'henshin/base'
require 'henshin/version'

module Henshin

  class CLI < Clive

    set :use, 'blog'
    set :serve, :host => '0.0.0.0',
                :port => 3001,
                :handler => nil,
                :use => false

    desc 'Choose the henshin type to use'
    opt :type, :arg => '<name>'

    desc 'Actually get this to work'
    opt :verbose

    command :serve, 'Serve the site' do

      set :use, true

      desc "Use specified port number, defaults to 3001"
      opt :p, :port, :arg => '<port>', :as => Integer

      desc "Host to run on, defaults to 0.0.0.0"
      opt :host, :arg => '<host>'

      desc  "Use specified handler"
      opt :H, :handler, :arg => '<handler>'

    end

    desc "Display current version"
    opt :version do
      puts Henshin::VERSION
      exit
    end

  end

  # Should search for +'henshin/name'+ first, then check load paths,
  # maybe add ability to set load path in config?
  #
  # @return [Henshin::Base]
  #   The subclass of Henshin::Base to build with.
  #
  def self.require_builder(name)
    require "henshin/#{name}"
    c = Henshin.constants.find {|i| i.to_s.downcase == name }
    Henshin.const_get(c)
  rescue LoadError
    begin
      require name
      const_get(name.to_sym)
    rescue LoadError
      warn "Unable to load #{name}"
    end
  end

  # Parse the command line input. Should be called from the executable.
  #
  # @param argv [Array] The command line arguments usually ARGV.
  #
  # @example
  #
  #   Henshin.parse!(ARGV)
  #
  def self.parse!(argv)
    args = CLI.run(argv)
    config = args.to_h

    source, dest = Henshin::DEFAULTS['source'], Henshin::DEFAULTS['dest']

    if args.size == 1
      source = Pathname.new(args[0])
      dest = source + Henshin::DEFAULTS['dest_suffix']
    elsif args.size == 2
      source = Pathname.new(args[0])
      dest = Pathname.new(args[1])
    end

    threads = []

    loaded = Henshin::Base.load_config([source])
    config = config.r_merge(loaded)

    source = Pathname.new(config['source']) if config.has_key?('source')
    dest   = Pathname.new(config['dest'])   if config.has_key?('dest')

    # get the henshin builder to use
    builder = nil
    begin
      if ::File.exist?(config['use'])
        load config['use']
        builder = HENSHIN_CLASS
      elsif ::File.exist?(::File.join(source, config['use']))
        load ::File.join(source, config['use'])
        builder = HENSHIN_CLASS
      else
        builder = require_builder(config['use'].downcase)
      end
    rescue LoadError
      puts "Falling back to default builder..."
      builder = require_builder(CLI::DEFAULTS['use'].downcase)
    end

    if config['serve']['use']
      require 'rack/henshin'

      handler = Rack::Handler.get(config['serve']['handler'])
      unless handler
        begin
          handler = Rack::Handler::Thin
        rescue LoadError
          handler = Rack::Handler::WEBrick
        end
      end

      app = Rack::Builder.new do
       # use Rack::CommonLogger
        use Rack::ShowExceptions
       # use Rack::Lint
        run Rack::Henshin.new(nil, {:root => source, :builder => builder})
      end

      puts "Serving site using #{builder}..."
      handler.run(app, :Host => config['serve']['host'], :Port => config['serve']['port'])

    else # If no server is needed then just build the site.
      start = Time.now
      puts "Building site using #{builder}..."
      site = builder.build(source, dest)
      puts "Site created in #{site.dest} (#{Time.now - start}s)"
    end
  end

end

# Load plugins for the command line interface
to_load = Gem.find_files('henshin/cli/*').map {|i| Pathname.new(i) }
unless to_load.empty?
  # Collect into hash based on file name
  to_load.group_by {|i| i.basename.to_s }.each_value do |v|
    # Require only the highest version if multiple exist
    require v.sort.last
  end
end
