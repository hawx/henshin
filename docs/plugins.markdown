Plugins are loaded from two possible places, the first `henshin/plugins/[plugin name]` which is where the default plugins are stored, (or you could create a gem with this kind of folder structure). The second being a folder in your project called `plugins`.

### Making Your Own Plugin

There are two types of plugins:
- Generators: These take content [string], and return a string.
- LayoutParsers: These take content [string] and a payload [hash], and return a string.

Your plugin must inherit `Henshin::Generator` or `Henshin::LayoutParser`. They must also contain a hash `extensions`, which shows the file types the plugin can read and what is output. Finally the plugin must call `Henshin.register! self` so that it can be loaded. When the plugin is first initialised it will be passed some options if any have been set in `options.yaml`, so this must be allowed for.

This is what the maruku plugin looks like as an example, it’s probably a good idea to check out the other plugins as well.

    require 'henshin/plugin'
    require 'maruku'
    
    class MarukuPlugin < Henshin::Generator
      
      attr_accessor :extensions, :config
      
      Defaults = {}
      
      def initialize( override={} )
        `extensions = {:input => ['markdown', 'mkdwn', 'md'],
                       :output => 'html'}
        `config = Defaults.merge(override)
      end
      
      def generate( content )
        Maruku.new(content).to_html
      end
      
      Henshin.register! self
    end