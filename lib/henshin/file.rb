module Henshin

  # This is the basic file class that the other file types inherit, eg
  # Layout, Gen and Static. It may also be used as the base for other
  # types such as Post or Tag, but it may be better to use Gen.
  #
  # @abstract
  #
  # Need to organise this file into
  #
  #  @group DSL
  #    Which has methods for use in subclasses, eg. .attribute
  #
  #  @group Attributes
  #    Which has the properties and attributes
  #
  #  @group Actions
  #    Render, write, etc
  #
  # Also need to decide how path, url, permalink and write_path are determined
  # really the url and permalink should be decided based on the write_path, which
  # itself is determined by the path.
  #
  class File
    
    inheritable_class_attr_accessor :payload_keys => []
    
    def self.attribute(*attrs)
      attrs.each do |i|
        payload_keys << i
      end
    end
    
    attr_accessor :engine, :key, :type, :no_layout, :rendered, :output, :path
    attribute :path
    
    def initialize(path, site)
      if path.respond_to? :extname
        @path = path
      elsif path
        @path = Pathname.new(path)
      end
      @site = site
      @rendered = nil
      @injects = []
    end
    
    def inspect
      "#<#{self.class} #{self.relative_path}>"
    end
    
    def inject_payload(hash)
      @injects << hash
    end
    
    
  # @group Filter Methods
    
    # Set a property for the file
    def set(key, value)
      if respond_to?("#{key}=")
        send("#{key}=", value)
      else
        # store in the data hash
        #
        # Obviously first I need to set up the data hash
      end
    end
    
    attr_accessor :applies, :uses
    
    # Use a rendering engine, though shouldn't be used immediately should be stored and
    # executed later.
    def apply(engine)
      # engine.new.make(content, data)
      (@applies ||= []) << engine
    end
    
    # Should store the class in a list to call at a later date but this will be pretty much
    # the implementation, only difference to #apply is the file itself is passed so the klass
    # can do anything it wants!
    def use(klass)
      # klass.new.make(self)
      (@uses ||= []) << klass
    end
    
    
  # @group Questions
    
    def can_read?
      true
    end
    
    def can_render?
      true
    end
    
    # Don't layout files without yaml frontmatter, assume they are static!
    def can_layout?
      @can_layout || has_yaml?
    end
    
    def can_write?
      true
    end
    
    # @return [true, false]
    #   Whether the file contains YAML frontmatter.
    #
    def has_yaml?
      if can_read?
        @path.read(3) == "---"
      else
        false
      end
    end
    
    def rendered?
      !!@rendered
    end
    
  # @endgroup
    
    # Get the mime type for the output file.
    def mime
      ::Rack::Mime.mime_type("." + output)
    end
    
    # @return [Pathname]
    #   Relative path to write the file to, this needs to have the 
    #   correct directory prepended to it.
    # 
    def write_path
      if output == 'html' && !@path.to_s.include?('index')
        path, ext = relative_path.to_s.split('.')
        Pathname.new(path << "/index.html")
      else
        r = relative_path.to_s.gsub ".#{extension}", ".#{output}"
        Pathname.new(r)
      end
    end

    # @return [Layout]
    #   The layout to use with this specific file, this is found from the
    #   data of the file or the default set.
    #
    # @todo Use Defaults
    #   At the moment this doesn't get the default layout set in Henshin::Base,
    #   it should.
    #
    def find_layout(files)
      if can_layout?
        d = self.data
        
        files = files.find_all {|f| f.class == Layout}
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
      @path.relative_path_from @site.config['source']
    end
    
    # @return [Hash{String=>Object}]
    #   Data taken from the file, usually from the YAML frontmatter
    #   but may also come from the file name, folders, etc.
    #
    def data
      return @override_data if @override_data
          
      r = {}
      
      payload_keys.each do |k|
        o = self.send(k)
        o = o.to_s if o.is_a? Pathname
        r[k.to_s] = o
      end
    
      if has_yaml?
        r.merge YAML.load(self.yaml)
      else
        r
      end
    end

    # @return [Hash{String=>Object}]
    #   Hash from #data with content. This will be used in the Sites 
    #   list of files.
    #
    def payload
      site_payload = @site.payload
      
      # Don't include self in list of files      
      site_payload['files'].reject! {|i| i['url'] == url }
      unless plural_key == "files"
        site_payload[plural_key].reject! {|i| i['url'] == url }
      end
      
      r = site_payload.merge({
        singular_key => self.data, # makes it easier to create layouts
        'file'   => self.data      # if all files share the key, "file".
      })
      
      @injects.each do |i|
        r.merge!(i)
      end
      
      r
    end

    # @return [String]
    #   The yaml frontmatter of the file.
    #
    def yaml
      if can_read?
        file = @path.read
        file =~ /^(---\s*\n.*?\n?^---\s*$\n?)/m
        file[0..$1.size-1] || ""
      end
    end
    
    

  # @group Overrides
  
    # Override the content with +val+. Note if +@rendered+ is present it 
    # will be preferred over this.
    #
    # @param val [String]
    #
    def content=(val)
      @override_content = val
    end
    
    # Override the data loading if necessary
    
    # Override the data with +val+. This will be preferred over any other 
    # value so will prevent the data from being loaded.
    #
    # @param val [Hash]
    #
    def data=(val)
      @override_data = val
    end

    
  # @group Attributes
  
    # These are the attributes a basic file has access to in layouts.
    attribute :content, :raw_content, :extension, :url, :permalink, :title, :output, 
              :plural_key, :singular_key
              
              
    # @return [String]
    #   The content of the file, this may just be the files contents
    #   or in a Gens case it will be the content minus the YAML 
    #   frontmatter. If rendering has taken place should return the
    #   rendered content.
    #
    def content
      if rendered?
        @rendered
      elsif @override_content
        @override_content
      else
        raw_content
      end
    end

    # This is kind of like #content, but will never return rendered content
    # under any circumstances.
    def raw_content
      if @override_content
        @override_content
      elsif can_read?
        if has_yaml?
          @path.read[yaml.size..-1]
        else
          @path.read
        end
      end
    end
  
    # @return [String]
    #   Extension of the original file.
    #
    def extension
      @path.extname[1..-1]
    end

    # @return [String]
    #   The pretty url for the file, eg. +/my_file+ instead of 
    #   +/my_file/index.html+.
    #
    def url
      if output == "html"
        permalink.split('/')[0..-2].join('/')
      else
        permalink
      end
    end
    
    # @return [String]
    #   Full url to the file itself.
    #
    def permalink
      "/" + write_path.to_s
    end
    
    # @return [String]
    #   Base name of file, eg. /my_site/somefile/about.liquid -> about
    #
    def title
      @path.basename.to_s.split('.')[0].titlecase
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
      singular_key.pluralize || 'files'
    end
    
    def singular_key
      @key ? @key.to_s : 'file'
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
      if can_render?
        @rendered = raw_content
        
        if @applies
          @applies.each do |engine|
            @rendered = engine.new.make(content, payload)
          end
        end
        
        if @uses
          @uses.each do |klass|
            klass.new.make(self)
          end
        end
      
        #if engine && can_render?
        #  # Only render when needed otherwise it is a waste of resources
        #  if !rendered? || force
        #    @rendered = engine.call(raw_content, payload)
        #  end
        #end
      end
    end
    
    # @overload layout(bool)
    #   Change whether this file can have a layout or not, ie. it effects
    #   the return value of #can_layout?
    #   @param bool [true, false]
    #
    # @overload layout(layout_file)
    #   Render this file within the +layout_file+ passed, if this file #can_layout?.
    #   @param layout_file [Henshin::Layout]
    #
    def layout(other)
      if other.is_a? Henshin::Layout
        other.render_with(self)
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
      if can_write?
        FileUtils.mkdir_p (dir + write_path).dirname
        f = ::File.new(dir + write_path, 'w')
        f.puts(self.content)
      end
    end
    
  end
end
