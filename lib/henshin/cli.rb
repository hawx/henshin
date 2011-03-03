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


# I just need to get the "boot" process clear in my mind.
#
# 1) Get command arguments, then parse them
# 2) If given the name of a specific class to use (eg. subclass of Henshin::Base
#     first try to load it if path given, if not try loading 'henshin/#{name}'
#     if these all fail raise exception.
# 3) Require any files that have been added to the config
# 4) Evaluate any files that have been added to load in the config
# 5) continue


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
  
  
  # Merges self with another hash, recursively.
  # 
  # This method doesn’t really belong here, could just be patched on Hash?
  #
  # @see http://www.ruby-doc.org/core/classes/Hash.html#M000759
  #   For more info on passing a block to Hash#merge.
  #
  def self.deep_merge(target, other)
    target.merge(other) do |k, oldval, newval|
      if newval.is_a? Hash
        deep_merge(oldval, newval)
      else
        newval
      end
    end
  end


  # @param argv [Array]
  #   The command line arguments usually ARGV.
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
    
    loaded = Henshin::Base.load_config([source, Pathname.pwd], false)
    config = deep_merge(config, loaded)
    
    # get the henshin builder to use
    builder = nil
    case config['type'].downcase
    when 'site'
      require_relative 'site'
      builder = Henshin::Site
    when 'blog'
      require_relative 'blog'
      builder = Henshin::Blog
    when 'base'
      builder = Henshin::Base
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
        run Rack::Henshin.new(nil, {:root => source, :builder => builder.name})
      end
      
      handler.run(app)
      
    else # If no server is needed then just build the site.
      start = Time.now
      puts "Building site using #{builder.name}..."
      site = builder.build(source, dest)
      puts "Site created in #{site.dest} (#{Time.now - start}s)"
    end
  end

end
