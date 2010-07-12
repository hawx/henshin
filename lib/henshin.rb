$:.unshift File.dirname(__FILE__)

require 'time'
require 'yaml'
require 'pp'
require 'pathname'

require 'titlecase'

require 'henshin/site'
require 'henshin/plugin'

require 'henshin/gen'
require 'henshin/post'
require 'henshin/static'

require 'henshin/tags'
require 'henshin/categories'
require 'henshin/archive'
require 'henshin/ext'


module Henshin
  
  # Default options for configuration
  Defaults = {'title' => 'A site',
              'file_name' => '<{category}/>{title-with-dashes}.{extension}',
              'permalink' => '/{year}/{month}/{date}/{title}.html',
              'plugins' => ['maruku', 'liquid'],
              'root' => '.',
              'target' => '_site',
              'exclude' => []}.freeze
  
  # Reads the current version from VERSION
  #
  # @return [String] current version
  def self.version
    File.read( File.join(File.dirname(__FILE__), '..', 'VERSION') )
  end

end
