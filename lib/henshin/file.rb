require 'rack/mime'

module Henshin

  # @abstract
  class File
  
    include Comparable
    
    inheritable_class_attr_accessor :payload_keys => []
    
    def self.attribute(*attrs)
      attrs.each do |i|
        payload_keys << i
      end
    end
    
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
    
    attr_accessor :path, :applies, :uses
    
    
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
      
      @payload_injects = []
      @data_injects    = []
      
      @applies = []
      @uses    = []
      
      if block_given?
        self.instance_eval &Proc.new
      end
    end
    
    attr_accessor :data_injects, :payload_injects
    
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
    
    def <=>(other)
      self.permalink <=> other.permalink
    end
    
  # @group DSL Methods
    
    # Set a property for the file
    #
    # @example
    #  
    #   file.set :url, '/somewhere/else'
    #
    def set(key, value)
      # Allow better looking names without messing other stuff up!
      map = {
        :read   => :readable,
        :layout => :layoutable,
        :render => :renderable,
        :write  => :writeable
      }
      key = map[key] if map.has_key?(key)
    
      if respond_to?("#{key}=")
        send("#{key}=", value)
      else
        warn "Error, #{inspect} did not allow #{key} to be set to #{value}."
        # store in the data hash?
        # data[key] = value
      end
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
      end
    end
    
    # Should store the class in a list to call at a later date but this will be pretty much
    # the implementation, only difference to #apply is the file itself is passed so the class
    # can do anything it wants!
    def use(klass)
      @uses << klass.new
    end
    
    
  # @group Predicates
  
    attr_writer :readable, :renderable, :layoutable, :writeable
    
    # @return [true, false] Whether the file can be read.
    def readable?
      @readable || true
    end
    
    # @return [true, false] Whether the file can be rendered.
    def renderable?
      @renderable || true
    end
    
    # @return [true, false] Whether the file can be applied to a layout file.
    #   Don't layout files without YAML frontmatter, assume they are static!
    def layoutable?
      @layoutable || has_yaml?
    end
    
    # @return [true, false] Whether the file can be written.
    def writeable?
      @writeable || true
    end
    
    # @return [true, false] Whether the file contains YAML frontmatter.
    def has_yaml?
      if readable?
        @path.read(3) == "---"
      else
        false
      end
    end
    
    # @return [true, false] Whether the file has been rendered.
    def rendered?
      @rendered
    end
    
    # @return [true, false] Whether this file is an index file.
    def index?
      path.to_s =~ /\/index\.\w+/ && output == 'html'
    end
    
  # @endgroup
    
    # @return [Pathname]
    #   Relative path to write the file to, this needs to have the 
    #   correct directory prepended to it.
    # 
    def write_path
      Pathname.new(permalink[1..-1])
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
        d = self.data

        if d['layout']
          files.find {|f| f.name == d['layout'] }
        else
          files.find {|f| f.name == "main" }
        end
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
    #   A relative path to the file from the 'read path'.
    #
    # @todo Absolute Paths
    #   Absolute paths or paths not in read directory will _probably_
    #   not work with this method of calculation, which is bad.
    #
    def relative_path
      @path.relative_path_from @site.source
    end
    puts "You have added a fix that needs removing in henshin/file.rb:#{__LINE__}"
    
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
      
      if has_yaml?
        r.merge! self.yaml
      end
    
      @data_injects.each do |i|
        if i.respond_to?(:call)
          r.merge!(i.call(self))
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
      
      r = site_payload.merge({
        singular_key => self.data, # makes it easier to create layouts
        'file'       => self.data  # if all files share the key, "file".
      })
      
      @payload_injects.each do |i|
        if i.respond_to?(:call)
          r.merge!(i.call(self))
        else
          r.merge!(i)
        end
      end

      @payload = r
    end
    
    # @return [String]
    #   The yaml frontmatter of the file.
    #
    def yaml_text
      if readable?
        file = @path.read
        file =~ /^(---\s*\n.*?\n?^---\s*$\n?)/m
        $1 ? file[0..$1.size-1] : ""
      end
    end

    # @return [Hash]
    #   The parsed yaml frontmatter of the file.
    #
    def yaml
      YAML.load(self.yaml_text) || {}
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
    
  
    # NOTES
    # - #url determines #permalink and #write_path
    # - set the key to alter the singular and plural keys which are determined from it
    #
    settable_attribute :url, :title, :content, :output
    
    # @return [String]
    #   The content of the file. If the file has content set, because it
    #   has been rendered, then this is returned. Otherwise returns the
    #   #raw_content.
    #
    def content
      @content || raw_content
    end
    
    # @return [String]
    #   Extension of the original file.
    #
    def extension
      @extension || @path.extname[1..-1]
    end
    
    # @return [String]
    #   The pretty url for the file, eg. +/my_file+ instead of 
    #   +/my_file/index.html+.
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
  
    # These are attributes which can only be read, but not set, though some can be
    # set indirectly by changing some of the settable attributes.
    attribute :raw_content, :extension, :permalink, :plural_key, :singular_key, :mime


    # @return [String] The unrendered file contents.
    def raw_content
      if readable?
        if has_yaml?
          @path.read[yaml_text.size..-1]
        else
          @path.read
        end
      else
        ""
      end
    end
    
    # @return [String] The mime type for the output file.
    def mime
      ::Rack::Mime.mime_type("." + output)
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

  # @group Actions

    # Renders the files contents using the hash, and maybe a layout.
    # Called by Henshin::Render.
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
          @rendered = true
          
          run_applies
          run_uses
        end
      end
      
      self.content
    end
    
    def run_applies
      @applies.each do |engine|
        @content = engine.render(content, payload)
      end
    end
    
    def run_uses
      @uses.each do |klass|
        klass.make(self)
      end
    end
    
    # Render this file within the +layout_file+ passed, if this file is #layoutable?.
    #
    # @param layout_file [Henshin::Layout]
    #
    def layout(other=find_layout)
      if other
        @content = other.render_with(self)
      end
    end
    
    # Writes the files into the directory given. Called by 
    # Henshin::Writer.
    #
    # @param dir [Pathname]
    #   Directory to write into, paths are calculated from this.
    #
    # @return [true, false]
    #   Whether write was successful.
    #
    def write(dir)
      if writeable?
        FileUtils.mkdir_p (dir + write_path).dirname
        f = ::File.new(dir + write_path, 'w')
        f.puts(self.content)
      end
    end
    
  end
end
