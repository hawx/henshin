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
    
    attr_accessor :engine, :key, :type, :no_layout, :rendered, :path
    
    
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
      @rendered = nil
      
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
      "#<#{self.class} #{self.relative_path}>"
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
    end
    
    # This is the central data hash for the file. It stores all data that is needed
    # for rendering purposes.
    # def data
    #   @data ||= {}
    # end
    
    def <=>(other)
      self.permalink <=> other.permalink
    end
    
  # @group Filter Methods
    
    # Set a property for the file
    def set(key, value)
      if respond_to?("#{key}=")
        send("#{key}=", value)
      else
        # store in the data hash?
        # data[key] = value
      end
    end
    
    attr_accessor :applies, :uses
    
    # Use a rendering engine, though shouldn't be used immediately should be stored and
    # executed later.
    def apply(engine)
      if engine.respond_to?(:new)
        @applies << engine
      elsif e = Henshin.registered_engines[engine]
        @applies << e
      end
    end
    
    # Should store the class in a list to call at a later date but this will be pretty much
    # the implementation, only difference to #apply is the file itself is passed so the klass
    # can do anything it wants!
    def use(klass)
      @uses << klass.new
    end
    
    
  # @group Predicates
    
    def readable?
      true
    end
    
    def renderable?
      true
    end
    
    # Don't layout files without yaml frontmatter, assume they are static!
    def layoutable?
      @can_layout || has_yaml?
    end
    
    def writeable?
      true
    end
    
    # @return [true, false]
    #   Whether the file contains YAML frontmatter.
    #
    def has_yaml?
      if readable?
        @path.read(3) == "---"
      else
        false
      end
    end
    
    def rendered?
      !!@rendered
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
    
    # Override the data with +val+. This will be preferred over any other 
    # value so will prevent the data from being loaded.
    #
    # @param val [Hash]
    #
    attr_writer :data

    # @return [Hash{String=>Object}]
    #   Hash from #data with content. This will be used in the Sites 
    #   list of files.
    #
    def payload
      site_payload = @site.payload
      
      r = site_payload.merge({
        singular_key => self.data(true), # makes it easier to create layouts
        'file'       => self.data(true)  # if all files share the key, "file".
      })
      
      @payload_injects.each do |i|
        if i.respond_to?(:call)
          r.merge!(i.call(self))
        else
          r.merge!(i)
        end
      end

      r
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
  
    # These are the attributes a basic file has access to in layouts.
    attribute :raw_content, :extension, :permalink, :plural_key, :singular_key, :mime
              
    # NOTES
    # - #url determines #permalink and #write_path
    # - @key has an attr_accessor above, use this to set #plural_key and #singular_key
    #
    settable_attribute :url, :title, :content, :output
              
              
    # @return [String]
    #   The content of the file, this may just be the files contents
    #   or in a Gens case it will be the content minus the YAML 
    #   frontmatter. If rendering has taken place should return the
    #   rendered content.
    #
    def content
      if rendered?
        @rendered
      else
        raw_content
      end
    end
    
    # Set the content or rendered, if rendered is set it is used, otherwise
    # falls back to content, and finally just reads the file.
    attr_writer :content, :rendered

    # This is kind of like #content, but will never return rendered content
    # under any circumstances.
    def raw_content
      if @content
        @content
      elsif readable?
        if has_yaml?
          @path.read[yaml_text.size..-1]
        else
          @path.read
        end
      else
        ""
      end
    end
  
    # @return [String]
    #   Extension of the original file.
    #
    def extension
      @extension || @path.extname[1..-1]
    end
    
    # Get the mime type for the output file.
    def mime
      @mime || ::Rack::Mime.mime_type("." + output)
    end

    # @return [String]
    #   The pretty url for the file, eg. +/my_file+ instead of 
    #   +/my_file/index.html+.
    #
    def url
      @url || if output == 'html' && !@path.to_s.include?('index')
        "/" + relative_path.to_s.split('.').first
      else
        "/" + relative_path.to_s.gsub(".#{extension}", ".#{output}")
      end
    end
    
    # @return [String]
    #   Full url to the file itself.
    #
    def permalink
      if output == "html" && !@path.to_s.include?('index')
        url + "/index.html"
      else
        url
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

    # @todo Get this working properly
    def plural_key
      @plural_key || singular_key.pluralize
    end
    
    def singular_key
      @singular_key || key.to_s
    end
    
    def key
      @key || :file
    end
    

  # @group Actions
  
    # Populate the data hash.
    # I may not actually implement this, it's just left here as an idea!
    def read
      
    end

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
          @rendered = raw_content

          run_applies
          run_uses
        end
      end
      self.content
    end
    
    def run_applies
      @applies.each do |engine|
        @rendered = engine.render(content, payload)
      end
    end
    
    def run_uses
      @uses.each do |klass|
        klass.make(self)
      end
    end
    
    # @overload layout(bool)
    #   Change whether this file can have a layout or not, ie. it effects
    #   the return value of #can_layout? For use withing Base.render blocks.
    #   @param bool [true, false]
    #
    # @overload layout(layout_file)
    #   Render this file within the +layout_file+ passed, if this file #can_layout?.
    #   @param layout_file [Henshin::Layout]
    #
    def layout(other=find_layout)
      if other.is_a?(Henshin::Layout)
        @rendered = other.render_with(self)
      else
        @can_layout = other
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
