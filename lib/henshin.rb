$:.unshift File.dirname(__FILE__)

# standard ruby
require 'time'
require 'yaml'
require 'pp'

# 3rd party
require 'titlecase'

# library
require 'henshin/site'

require 'henshin/gen'
require 'henshin/post'
require 'henshin/static'

require 'henshin/tags'
require 'henshin/categories'
require 'henshin/archive'
require 'henshin/ext'


module Henshin
  
  # Default options for configuration
  Defaults = {:title => 'A site',
              :description => 'No description',
              :time_zone => 'GMT',
              :author => '',
              :layout => '',
              :file_name => '<{category}/>{title-with-dashes}.{extension}',
              :permalink => '/{year}/{month}/{date}/{title}.html',
              :plugins => ['maruku', 'liquid'],
              :root => '.',
              :target => '_site',
              :plugin_options => {},
              :exclude => [] }
  
  
  # Creates the configuration hash by merging defaults, supplied options and options 
  # read from the 'options.yaml' file. Then loads the plugins and sorts them
  #
  # @param [Hash] override to override other set options
  # @return [Hash] the merged configuration hash
  def self.configure( override={} )  
    config_file = File.join((override[:root] || Defaults[:root]), '/options.yaml')
    
    begin
      config = YAML.load_file(config_file).to_options
      settings = Defaults.merge(config).merge(override)
    rescue => e
      $stderr.puts "\nCould not read configuration, falling back to defaults..."
      $stderr.puts "-> #{e.to_s}"
      settings = Defaults.merge(override)
    end
    
    settings[:exclude] << '/_site' << '/plugins'
    settings[:plugins] = Henshin.sort_plugins( Henshin.load_plugins(settings) )
    settings
  end
  
  # Organises the plugins into generators and layout parses,
  # then turns the generators into a hash with a key for each extension.
  #
  # @param [Array] plugins
  # @return [Hash] 
  def self.sort_plugins(plugins)
    r = {:generators => {}, :layout_parsers => []}
    plugins.each do |plugin|
      if plugin.is_a? Generator
        plugin.extensions[:input].each do |ext|
          r[:generators][ext] = plugin
        end
      elsif plugin.is_a? LayoutParser
        r[:layout_parsers] << plugin
      end
    end
    r
  end
  
  # Loads the plugins, each plugin then calls Henshin.register!, and then we loop through
  # the options and pass the options for the plugin to it.
  #
  # @param [Hash] settings of loaded so far
  # @return [Array] list of loaded plugin instances
  def self.load_plugins(opts)  
    plugins = []
    opts[:plugins].each do |l|
      begin
        require 'henshin/plugins/' + l
      rescue LoadError
        require File.join(opts[:root], 'plugins/', l)
      end
    end
    
    @registered_plugins.each do |plugin|
      if plugin[:opts]
        opts[plugin[:opts]].each do |k, v|
          if k.to_s.include? 'dir'
            opts[plugin[:opts]][k] = File.join(opts[:root], v)
          end
        end
        plugin[:plugin].configure opts[plugin[:opts]]
      end
      plugins << plugin[:plugin]
    end
    
    plugins
  end
  
  # Each plugin will call this method when loaded from #load_plugins, these plugins then
  # populate @registered_plugins, which is returned from #load_plugins.
  #
  # @param [Class] plugin to load
  # @param [Symbol] options symbol to look up in settings hash
  # @return [Array] plugins and options symbol in hashes
  def self.register!( plug, opts=nil )
    @registered_plugins ||= []
    @registered_plugins << {:plugin => plug.new, :opts => opts}
  end
  

  # @return [String] current version
  def self.version
    File.read( File.join(File.dirname(__FILE__), '..', 'VERSION') )
  end

end
