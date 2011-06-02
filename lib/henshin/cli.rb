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
  class CLI
    
    DEFAULTS = {
      'type' => 'blog',
      'serve' => {
        'address' => "0.0.0.0",
        'port'    => 5555,
        'handler' => nil,
        'use'     => false
      }
    }
  
    include Clive::Parser
    option_var :config, DEFAULTS
    
    desc 'Choose the henshin type to use'
    flag :type, :arg => "NAME" do |t|
      config['type'] = t
    end
  
    # SERVE
    desc 'Serve the site'
    command :serve do
    
      config['serve'] ||= {}
      config['serve']['use'] = true      
        
      desc "Use specified port number" 
      flag :p, :port, :arg => "PORT" do |n|
        config['serve']['port'] = n
      end
      
      desc  "Use specified handler"
      flag :H, :handler, :arg => "HANDLER" do |h|
        config['serve']['handler'] = h
      end
    
    end
    
    desc "Display current version"
    switch :version do
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
  rescue LoadError # try load paths
    require name
    const_get(name.to_sym)
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
    args = CLI.parse(argv)
    config = CLI.config

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
    
    # get the henshin builder to use
    builder = require_builder config['type'].downcase
    
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
      
      puts "Serving site using #{builder.name}..."
      handler.run(app)
      
    else # If no server is needed then just build the site.
      start = Time.now
      puts "Building site using #{builder.name}..."
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
