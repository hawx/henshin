module Henshin

  # Provides an interface for creating filters that can then be included
  # easily in a new henshin site.
  #
  # @example To Creare
  #
  #   require 'henshin/filter'
  # 
  #   module Henshin
  #     module LiquidFilter
  #       include Henshin::Filter
  #       
  #       type = 'liquid'
  #       
  #       engine = lambda do |content, data|
  #         begin
  #           Liquid::Template.parse(content).render(data)
  #         rescue NameError
  #           require 'liquid'
  #           Liquid::Template.parse(content).render(data)
  #         end
  #       end
  #     end
  #   end
  #
  # @example To Use
  #
  #   class MySite < Henshin::Base
  #     include_filter LiquidFilter
  #     # include_filters LiquidFilter, MarukuFilter, etc.
  #   end
  #
  module Filter
  
    def self.included(mod)
      mod.instance_variable_set("@instance", FilterBody.new)
      mod.extend(self)
    end
    
    def inspect
      @instance.inspect
    end
    
    def method_missing(sym, *args, &block)
      @instance.send(sym, *args, &block)
    end
  
  end
  
  # This is the real filter the module is just a proxy to include.
  # When included it sets up an instance of FilterBody that then stores
  # the settings necessary when running a file through.
  # 
  # Henshin::Base#filter also creates instances of this class.
  #
  class FilterBody
    
    def initialize
      @engine, @type, @output, @no_layout, @klass, @body = nil
      @patterns = []
    end
    attr_writer :klass, :body, :patterns
    
    def self.pretty_attr_accessor(*args)
      args.each do |arg|
        class_eval <<-EOS
          def #{arg}(val=nil)
            if val
              @#{arg} = val
            else
              @#{arg}
            end
          end
        EOS
      end
    end
    
    # Could only really make these pretty_attr_accessor calls, should be able
    # to generalise the method to allow the others as well
    pretty_attr_accessor :type, :output, :no_layout, :klass
    
    # For use with Henshin::Base#filter
    def body(&block)
      if block_given?
        @body = block
      else
        @body
      end
    end
    
    def engine(&block)
      if block_given?
        @engine = block
      else
        @engine
      end
    end
    
    def pattern(val=nil)
      @patterns << val
    end
    
    def patterns(*vals)
      if vals
        @patterns += vals
      else
        @patterns
      end
    end
    
    # Test whether the string given matches any patterns.
    #
    # @param val [Pathname]
    # @return [true, false]
    #
    def matches?(val)
      @patterns.each do |pattern|
        if val.fnmatch(pattern)
          return true
        end
      end
      false
    end
    
    # Execute the filter on +file+.
    #
    # @param file [Henshin::File]
    # @return [Henshin::File]
    #
    def do_filter!(file)
      if @body
        @body.call(file)
        file
      else
        file.engine    = @engine    if @engine
        file.type      = @type      if @type
        file.output    = @output    if @output
        file.no_layout = @no_layout if @no_layout
        file
      end
    end
    
  end
  
  # Extend base so we can add pre-defined filters.
  class Base
  
    # Include a filter into the classes list of filters. Can also set a
    # class for which the filter will build file, this overrides the default
    # if one has been set in the filter.
    #
    # @example
    #
    #   class MySite < Henshin::Base
    #     include_filter LiquidFilter
    #     include_filter SassFilter, MySite::StyleFile
    #   end
    #
    def self.include_filter(mod, as = nil)
      mod.klass = as if as
      filters << mod
    end
    
    # @see .include_filter
    # @example
    #
    #   MySite < Henshin::Base
    #     include_filters MarukuFilter, LiquidFilter
    #     include_filters SassFilter, LessFilter, :using => MySite::StyleFile
    #   end
    #
    def self.include_filters(*mods)
      if mods.last.is_a? Hash
        mods[0..-2].each do |mod|
          include_filter(mod, mods.last[:using])
        end
      else
        mods.each do |mod|
          include_filter(mod)
        end
      end
    end
  
  end
end