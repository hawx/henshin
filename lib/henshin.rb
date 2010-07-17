$:.unshift File.dirname(__FILE__)

require 'time'
require 'yaml'
require 'pp'
require 'pathname'

require 'titlecase'
require 'parsey'

require 'henshin/site'
require 'henshin/plugin'

require 'henshin/gen'
require 'henshin/post'
require 'henshin/static'

require 'henshin/labels'
require 'henshin/archive'
require 'henshin/ext'


module Henshin
  
  # Default options for configuration
  Defaults = {'title' => 'A site',
              'file_name' => '<{category}/>{title-with-dashes}.{extension}',
              'permalink' => '/{year}/{month}/{date}/{title}.html',
              'plugins' => ['maruku', 'liquid'],
              'root' => './',
              'target' => '_site',
              'exclude' => []}.freeze
              
  # Partial regexs for use in parsing file names
  Partials = {'title' => '([a-zA-Z0-9_ -]+)',
              'title-with-dashes' => '([a-zA-Z0-9-]+)',
              'date' => '(\d{4}-\d{2}-\d{2})',
              'date-time' => '(\d{4}-\d{2}-\d{2} at \d{2}:\d{2})',
              'xml-date-time' => '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?((\+|-)\d{2}:\d{2})?)',
              'category' => '([a-zA-Z0-9_ -]+)',
              'extension' => "([a-zA-Z0-9_-]+)"}.freeze
  
  # Reads the current version from VERSION
  #
  # @return [String] current version
  def self.version
    File.read( File.join(File.dirname(__FILE__), '..', 'VERSION') )
  end

end
