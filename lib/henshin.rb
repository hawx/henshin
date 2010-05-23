$:.unshift File.dirname(__FILE__)

# standard ruby
require 'time'
require 'yaml'
require 'pp'

# library
require 'henshin/site'

require 'henshin/gen'
require 'henshin/post'
require 'henshin/static'

require 'henshin/tags'
require 'henshin/ext'


module Henshin
  
  # Default options for configuration
  Defaults = {:title => 'A site',
              :description => 'No description',
              :time_zone => 'GMT',
              :author => '',
              :layout => '',
              :file_name => '{title-with-dashes}.{extension}',
              :permalink => '/{year}/{month}/{date}/{title}.html',
              :plugins => ['maraku', 'liquid'],
              :root => '.',
              :target => '_site',
              :plugin_options => {} }
  
  
  # Creates the configuration hash by merging defaults, supplied options and options read from the 'options.yaml' file. Then loads the plugins
  #
  # @param [Hash] override to override other set options
  # @return [Hash] the merged configuration hash
  def self.configure( override={} )
    config_file = (override[:root] || Defaults[:root]) + '/options.yaml'
    config = YAML.load_file( config_file ).to_options
    
    settings = Defaults.merge(config).merge(override)
    
    settings.each do |k, v|
      if settings[:plugins].include? k.to_s
        settings[:plugin_options][k] = v.to_options
      end
    end
    
    settings[:plugins] = Henshin.load_plugins( settings[:plugins], settings[:root], settings[:plugin_options] )
    settings[:extensions] = Henshin.extensions( settings[:plugins] )
    settings
  end
  
  
  # Loads the specified plugins
  #
  # @param [Array] plugins list of plugins to load
  # @return [Array] list of loaded plugin instances
  def self.load_plugins( to_load, root, options )
    plugins = []
    to_load.each do |l|
      p 
      begin
        require 'henshin/plugins/' + l
      rescue LoadError
        require File.join(root, 'plugins/', l)
      end
      plugins << eval("#{l.capitalize}Plugin.new( #{options[l.to_sym]} )")
    end
    plugins
  end
  
  
  # Lists the file extensions the currently loaded plugins use
  #
  # @param [Array] plugins array of loaded plugin instances
  # @return [Array] a list of file extensions
  def self.extensions( plugins )
    extensions = []
    plugins.each do |i| 
      extensions << i.extensions
    end
    extensions.flatten!
  end

end
