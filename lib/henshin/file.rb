require 'rack/mime'

module Henshin

  # @abstract
  class File
  
    include Comparable
    
    inheritable_class_attr_accessor :payload_keys => []
    class_attr_accessor :set_values => {}
    
  # @group Class-level DSL Methods
    
    # Creates an attribute for the file. This should correspond to a method 
    # definition with the same name. When #data is called it will add an
    # item to the data hash with the key as the method's name and the value
    # as the return value from the method. The method will be passed no
    # arguments but will obviously have access to all of the instance 
    # variables set (@site being the most important).
    #
    # @param attrs [Array[Symbol]]
    #
    # @example
    #
    #   class MyFile < Henshin::File
    #     attribute :type
    #
    #     def type
    #       if self.extension == "html"
    #         "html"
    #       else
    #         "not html"
    #       end
    #     end
    #   end
    #
    #   f = MyFile.("somewhere.txt", @site)
    #   f.type #=> "not html"
    #   f.data #=> {..., "type" => "not html", ...}
    #
    def self.attribute(*attrs)
      attrs.each do |i|
        payload_keys << i
      end
    end
    
    # Same as .attribute but creates a writer method for the variable allowing
    # it to be set using .set or #set. The reader method (ie. corresponding to
    # the method symbol passed) should make use of the instance variable of the
    # same name to allow the set value to be used.
    #
    # @example
    #
    #   class MyFile < Henshin::File
    #     settable_attribute :type
    #
    #     def type
    #       @type || "Mine"
    #     end
    #   end
    #
    #   f = MyFile.new("somewhere.txt", @site)
    #   f.type #=> "Mine"
    #   f.set :type, "Yours"
    #   f.type #=> "Yours"
    #   f.data #=> {..., "type" => "Yours", ...}
    #
    def self.settable_attribute(*attrs)
      attrs.each do |i|
        payload_keys << i
        
        # don't overwrite existing methods!
        m = "#{i}=".to_sym
        unless instance_methods.include?(m)
          attr_writer i
          # private m
        end
      end
    end
    
    # Set values for all instances of the class. Basically stores the 
    # key-values given and then calls #set with them when a new instance
    # is created.
    # 
    # @param key [Symbol]
    # @param value [Object]
    # @see #set
    #
    # @example Basic example from 'lib/henshin/file/page.rb'
    #
    #   class Page < Henshin::File
    #     set :key,    :page
    #     set :output, 'html'
    #   end
    #
    def self.set(key, value)
      set_values[key] = value
    end
    
  # @endgroup
    
    # @example
    #
    #   Henshin::File.new 'a-text-file.txt', @site
    #
    #   Henshin::File.new 'some-file.md', @site do
    #     set :title, 'Some File'
    #     apply :kramdown
    #     unapply :maruku
    #   end
    #
    def initialize(path, site)
      if path.is_a? Pathname
        @path = path
      elsif path
        @path = Pathname.new(path)
      end
      @site = site
      @rendered = false
      
      @payload_injects = self.class.payload_injects
      @data_injects    = self.class.data_injects
      
      @applies = []
      @uses    = []
      
      set_values.each {|k,v| set(k, v) }
      
      if block_given?
        block = Proc.new
        if block.arity == 0
          self.instance_eval &Proc.new
        else
          block.call(self)
        end
      end
    end
    
    attr_accessor :path, :applies, :data_injects, :payload_injects
    
    def inspect
      "#<#{self.class} #{url}>"
    end
    
    
    # Add a hash into the return value of #payload. If block/proc given it is
    # passed the file as an argument.
    # 
    # @see Base#inject_payload
    # 
    def inject_payload(arg=nil)
      arg = Proc.new if block_given? && arg.nil?
      raise ArgumentError unless arg
      @payload_injects << arg
      
      # If payload exists put new stuff into cached version so it doesn't have
      # to be reset.
      if @payload
        if arg.respond_to?(:call)
          @payload.merge!(arg.call(self))
        else
          @payload.merge!(arg)
        end
      end
    end
    
    class_attr_accessor :payload_injects => []
    
    def self.inject_payload(arg=nil)
      arg = Proc.new if block_given? && arg.nil?
      raise ArgumentError unless arg
      payload_injects << arg
    end
    
    # Add a hash into the return value of #data. If block/proc given it is
    # passed the file as an argument.
    #
    # @see Base#inject_payload
    #
    def inject_data(arg=nil)
      arg = Proc.new if block_given? && arg.nil?
      raise ArgumentError unless arg
      @data_injects << arg
      
      # If data exists put new data into cached hash so it doesn't totally
      # have to be reset.
      if @data
        if arg.respond_to?(:call)
          @data.merge!(arg.call(self))
        else
          @data.merge!(arg)
        end
      end
    end
    
    class_attr_accessor :data_injects => []
    
    def self.inject_data(arg=nil)
      arg = Proc.new if block_given? && arg.nil?
      raise ArgumentError unless arg
      data_injects << arg
    end
    
    def <=>(other)
      self.permalink <=> other.permalink
    end
    
  # @group DSL Methods
  
    SET_MAP = {
      :read   => :readable,
      :layout => :layoutable,
      :render => :renderable,
      :write  => :writeable
    }
    
    # Set a property for the file
    #
    # @example
    #  
    #   file.set :url, '/somewhere/else'
    #
    def set(key, value)
      # Allow better looking names without messing other stuff up!
      key = SET_MAP[key] if SET_MAP.has_key?(key)
    
      if respond_to?("#{key}=")
        send("#{key}=", value)
      else
        warn "Error, #{inspect} did not allow #{key} to be set to #{value}."
        # store in the data hash?
        # data[key] = value
      end
    end
    
    # Unset a property for the file, allowing the default
    def unset(key)
      set(key, nil)
    end
    
    # Use a rendering engine, though shouldn't be used immediately should be stored and
    # executed later.
    #
    # @example
    #
    #     file.apply :maruku
    #
    def apply(engine)
      if engine.respond_to?(:new)
        @applies << engine
      elsif e = Henshin.registered_engines[engine]
        @applies << e
      else
        warn "#{engine.inspect} is not an engine or a registered name for an engine"
      end
    end
    
    # Don't use a previously applied engine.
    def unapply(engine)
      if engine.respond_to?(:new)
        @applies.delete(engine)
      elsif e = Henshin.registered_engines[engine]
        @applies.delete(e)
      else
        warn "#{engine.inspect} is not an engine or a registered name for an engine"
      end
    end
    
  # @group Predicates
  
    attr_writer :readable, :renderable, :layoutable, :writeable
    
    # @return [true, false] Whether the file can be read.
    def readable?
      @readable.nil? ? true : @readable
    end
    
    # @return [true, false] Whether the file can be rendered.
    def renderable?
      @renderable.nil? ? false : @renderable
    end
    
    # @return [true, false] Whether the file can be applied to a layout file.
    #   Don't layout files without YAML frontmatter, assume they are static!
    def layoutable?
      @layoutable.nil? ? false : @layoutable
    end
    
    # @return [true, false] Whether the file can be written.
    def writeable?
      @writeable.nil? ? true : @writeable
    end
    
    # @return [true, false] Whether the file has been rendered.
    def rendered?
      @rendered
    end
    
    # @return [true, false] Whether this file is an index file.
    def index?
      @path.to_s =~ /\/index\.\w+/ && output == 'html'
    end
    
  # @endgroup
    
    # @return [Pathname]
    #   Relative path to write the file to, this needs to have the 
    #   correct directory prepended to it.
    # 
    def write_path
      Pathname.new(permalink[1..-1])
    end
    
    # @return [Array] List of possible names for the layout from best to worst
    def layout_names
      [self.data['layout'], @site.config['layout']]
    end

    # @return [Layout]
    #   The layout to use with this specific file, this is found from the
    #   data of the file or the default set.
    #
    # @todo Use Defaults
    #   At the moment this doesn't get the default layout set in Henshin::Base,
    #   it should.
    #
    def find_layout(files=@site.layouts)
      if layoutable?
        return @layout if @layout
        
        layout_names.compact.uniq.each do |n|
          if @layout = files.find {|f| f.name == n }
            break
          end
        end
        
        @layout
      end
    end
    
    # @example
    #
    #   # site read directory: /test/site
    #   file = Henshin::File.new('/test/site/folder/file.txt', site)
    #   file.path
    #   #=> #<Pathname:/test/site/folder/file.txt>
    #   file.relative_path
    #   #=> #<Pathname:folder/file.txt>
    #
    # @return [Pathname]
    #   A relative path to the file from the source directory.
    #
    def relative_path
      @relative_path ||= @path.relative_path_from @site.source
    rescue # Pathname occasionally messes up so just return the plain path
      @relative_path = @path
    end
    
    # @param force [true, false]
    #   Pass +true+ to force it to rebuild the data but only if absolutely
    #   necessary.
    # 
    # @return [Hash{String=>Object}]
    #   Data taken from the file, usually from the YAML frontmatter
    #   but may also come from the file name, folders, etc.
    #    
    def data(force=false)
      return @data if @data unless force
      
      r = {}
      payload_keys.each do |k|
        o = self.send(k)
        o = o.to_s if o.is_a? Pathname
        r[k.to_s] = o
      end
    
      data_injects.each do |i|
        if i.respond_to?(:call)
          r.merge!(i.call(self))
        elsif i.is_a?(Symbol) && self.respond_to?(i)
          r.merge!(self.send(i))
        else
          r.merge!(i)
        end
      end
      
      @data = r
    end

    # @param force [true, false]
    #   Pass +true+ to force it to rebuild the payload but only if absolutely
    #   necessary.
    #
    # @return [Hash{String=>Object}]
    #   Hash from #data with content. This will be used in the Sites 
    #   list of files.
    #
    def payload(force=false)
      return @payload if @payload unless force
    
      site_payload = @site.payload
      
      r = site_payload.merge({singular_key => self.data})
      # makes it easier to create layouts if all files share the key, "file".
      r.merge!({'file' => self.data}) unless key == :file
      
      payload_injects.each do |i|
        if i.respond_to?(:call)
          r.merge!(i.call(self))
        elsif i.is_a?(Symbol) && self.respond_to?(i)
          r.merge!(self.send(i))
        else
          r.merge!(i)
        end
      end

      @payload = r
    end
    
  # @group Attributes
  
    attr_writer :key
  
    # @return [Symbol]
    #   Key for this file and others built from this class, though can be altered.
    #   This allows you to group certain types of files, for instance posts, by 
    #   setting the key to :post.
    def key
      @key || :file
    end

    # @return [String] Pluralised key for the file
    # @see #key
    def plural_key
      singular_key.pluralize
    end
    
    # @return [String] Singular key for the file
    # @see #key
    def singular_key
      key.to_s
    end
    
    # NOTES
    # - #url determines #permalink and #write_path
    # - set the key to alter the singular and plural keys which are determined from it
    #
    settable_attribute :content, :title, :output, :url
    
    # @return [String] Contents of the file
    def content
      @content || raw_content
    end
    
    # @return [String]
    #   Base name of file, eg. /my_site/somefile/about.liquid -> about
    #
    def title
      @title || @path.basename.to_s.split('.')[0].titlecase
    end
    
    # If the output has been set during rendering return that value otherwise
    # assume the extension has not changed.
    #
    # @return [String]
    #
    def output
      @output || self.extension
    end
    
    # @return [String]
    #   The pretty url for the file, eg. +/my_file+ instead of 
    #   +/my_file/index.html+.
    #
    # @todo Make this less awkward, seems like I'm checking for too many
    #  special cases whereas a better general case would be preferred.
    #
    def url
      @url || if index?
        d = relative_path.dirname.to_s
        if d == "."
          "/"
        else
          "/" + d
        end
      elsif output == 'html'
        "/" + relative_path.to_s.split('.').first
      else
        "/" + relative_path.to_s.gsub(".#{extension}", ".#{output}")
      end
    end
    
    # These are attributes which can only be read, but not set, though some can be
    # set indirectly by changing some of the settable attributes.
    attribute :mime, :extension, :permalink, :raw_content
    
    def raw_content
      @path.read
    end
    
    # @return [String] The mime type for the output file.
    def mime
      ::Rack::Mime.mime_type("." + output)
    end
    
    # @return [String]
    #   Extension of the original file.
    #
    def extension
      @path.extname[1..-1]
    end
    
    # @return [String] Full url to the file itself.
    def permalink
      if url == "/"
        "/index.html"
      elsif url.include?('.')
        url
      else
        url + "/index.html"
      end
    end

  # @group Actions
  #
  # These should not be changed unless totally necessary!

    # Renders the files contents using the engines that have been applied.
    # Always sets #rendered? to true even if the file has not actually been
    # rendered, if for example the file is not renderable.
    #
    # @param block [Proc]
    #   Block to use for rendering, the block expects to be passed
    #   the path of the file and a hash of data to use.
    #
    # @return [String]
    #
    def render(force=false)
      if renderable?
        # Only render when needed
        if !rendered? || force 
          @content = raw_content
          
          @applies.each do |engine|
            @content = engine.render(content, payload)
          end
        end
      end
      
      @rendered = true
      self.content
    end
    
    # Render this file within the +layout_file+ passed, if this file is #layoutable?.
    #
    # @param layout_file [Henshin::Layout]
    #
    def layout(other=find_layout)
      if other && layoutable?
        @content = other.render_with(self)
      end
    end
    
    # @param dir [Pathname]
    #   Directory to write into, paths are calculated from this.
    #
    def write(dir)
      if writeable?
        FileUtils.mkdir_p (dir + write_path).dirname
        ::File.open(dir + write_path, 'w') {|f| f.write(self.content) }
      end
    end
    
  end
end
