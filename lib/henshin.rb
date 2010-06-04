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
require 'henshin/categories'
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
  
  
  # Creates the configuration hash by merging defaults, supplied options and options read from the 'options.yaml' file. Then loads the plugins
  #
  # @param [Hash] override to override other set options
  # @return [Hash] the merged configuration hash
  def self.configure( override={} )  
    config_file = (override[:root] || Defaults[:root]) + '/options.yaml'
    
    begin
      config = YAML.load_file( config_file ).to_options
      settings = Defaults.merge(config).merge(override)
    rescue => e
      $stderr.puts "\nCould not read configuration, falling back to defaults..."
      $stderr.puts "-> #{e.to_s}"
      settings = Defaults.merge(override)
    end
    

    settings.each do |k, v|
      if settings[:plugins].include? k.to_s
        settings[:plugin_options][k] = v.to_options
      end
    end
    
    loaded_plugins = Henshin.load_plugins( settings[:plugins], settings[:root], settings[:plugin_options] )
    
    settings[:plugins] = {:generators => {}, :layout_parsers => []}
    loaded_plugins.each do |plugin|
      if plugin.is_a? Generator
        plugin.extensions[:input].each do |ext|
          settings[:plugins][:generators][ext] = plugin
        end
      end
      if plugin.is_a? LayoutParser
        settings[:plugins][:layout_parsers] << plugin
      end
    end
    
    settings
  end
  
  
  # Loads the specified plugins
  #
  # @param [Array] plugins list of plugins to load
  # @return [Array] list of loaded plugin instances
  # @todo Make sure that options are passed to the plugin
  def self.load_plugins( to_load, root, opts )  
    plugins = []
    to_load.each do |l|
      begin
        require 'henshin/plugins/' + l
      rescue LoadError
        require File.join(root, 'plugins/', l)
      end
    end
    @registered_plugins
  end
  
  # Each plugin will call this method when loaded from #load_plugins, these plugins then populate @registered_plugins, which is returned from #load_plugins. Complicated? Maybe, but it works!
  def self.register!( plug )
    @registered_plugins ||= []
    @registered_plugins << plug.new
  end
  

  # @return [String] current version
  def self.version
    File.read( File.join(File.dirname(__FILE__), *%w[.. VERSION]) )
  end

end
