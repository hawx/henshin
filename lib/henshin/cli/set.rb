# Extends the command line to include a 'set' flag, allowing
# you to set convifuration without editing the config.yml file.
# This is mainly added as an example of what can be done with the
# command line tool by adding commands, flags, etc.
#
#   henshin --set <key> <value>
#

module Henshin
  class CLI
  
    desc 'Set a value in config.yml'
    flag :set, :args => "key value" do |k, v|
      if ::File.exist?('config.yml')
        ::File.open('config.yml', 'a+') {|f| f.write("\n#{k}: #{v}") }
      else
        puts "config.yml could not be found in current directory.".red
      end
      exit
    end
    
  end
end
    