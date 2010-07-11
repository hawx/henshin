require 'liquid'

module Henshin
  class LiquidPlugin < LayoutParser
    
    def initialize(site)
      @config = {}
      
      if site.config['liquid']
        @config = site.config['liquid']
        @config['include_dir'] = File.join(site.root, @config['include_dir'])
      end
    end
    
    def generate( content, data )
      reg = {:include_dir => @config['include_dir']}
      Liquid::Template.parse(content).render(data, :registers => reg)
    end
    
    module Filters
      def date_to_string(dt)
        dt.strftime "%d %b %Y"
      end
      
      def date_to_long(dt)
        dt.strftime "%d %B %Y at %H:%M"
      end
    
      def time_to_string(dt)
        dt.strtime "%H:%M"
      end
      
      def titlecase(str)
        str.upcase
      end
      
      def escape(str)
        CGI::escape str
      end
      
      def escape_html(str)
        CGI::escapeHTML str
      end
    end
    Liquid::Template.register_filter(Filters)
    
    class Include < Liquid::Tag
      def initialize(tag_name, file, tokens)
        super
        @file = file.strip
      end
      
      def render(context)
        include = File.join(context.registers[:include_dir], @file)
        File.open(include, 'r') {|f| f.read}
      end
    end
    Liquid::Template.register_tag('include', Include)
    
  end
end
