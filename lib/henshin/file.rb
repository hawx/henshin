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
  
    # Open the singleton class of this class to add accessors for payload_keys
    # which aren't tied to class variables
    class << self; attr_accessor :payload_keys; end
    @payload_keys = []
  
    # Use this for file type attributes, they are slightly different 
    # as the value will be automatically added to the #data and #payload
    # hashes.
    #
    # Note: Not all values should be made as attribute some may require
    # the use of attr_accessor, for example "engine", as the user doesn't
    # want to find an "engine" key in the payload to the rendering engine! 
    
    # Adds a key to the payload hash with the name of the method passed and
    # the value the method returns. This is then available when templating.
    #
    # @example
    #
    #   def url
    #     "/page/#{@path.basename}"
    #   end
    #   attribute :url
    #   # adds {'url' => #url} to data hash
    #   # which is available with '{{ file.url }}' in liquid, for example
    #
    # @param attrs [Symbol]
    #
    def self.attribute(*attrs)
      if self.name == "Henshin::File"
        @payload_keys ||= []
      else
        # the #dup call is _very_ important
        @payload_keys ||= superclass.payload_keys.dup
      end
      
      @payload_keys += attrs
    end
    
    attr_accessor :engine, :key, :type, :no_layout, :rendered
    attr_accessor :path, :output
    attribute :path, :output
    
    def initialize(path, site)
      @payload_keys = self.class.payload_keys || []
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
    
    def can_render?
      true
    end
    
    def can_layout?
      if @no_layout || @engine.nil?
        false
      else
        true
      end
    end
    
    def can_write?
      true
    end
    
    # @return [true, false]
    #   Whether the file contains YAML frontmatter.
    #
    def has_yaml?
      @path.read(3) == "---"
    end
    
    def rendered?
      !!@rendered
    end
    
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
    #   At the moment this doesn't get the default set in Henshin::Base
    #   it should.
    #
    def layout(files)
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
      
      @payload_keys.each do |k|
        o = self.send(k)
        o = o.to_s if o.is_a? Pathname
        r[k.to_s] = o
      end
    
      if !@override_content && has_yaml?
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
        'file'   => self.data      # if all files share a key, "file".
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
      file = @path.read
      file =~ /^(---\s*\n.*?\n?^---\s*$\n?)/m
      file[0..$1.size-1] || ""
    end
    
    

  # @group Overrides
  
    def content=(val)
      @override_content = val
    end
    
    # Override the data loading if necessary
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
    attribute :content

    # This is kind of like #content, but will never return rendered content
    # under any circumstances.
    def raw_content
      if @override_content
        @override_content
      elsif has_yaml?
        @path.read[yaml.size..-1]
      else
        @path.read
      end
    end
    attribute :raw_content
  
    # @return [String]
    #   Extension of the original file.
    #
    def extension
      @path.extname[1..-1]
    end
    attribute :extension

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
    attribute :url
    
    # @return [String]
    #   Full url to the file itself.
    #
    def permalink
      "/" + write_path.to_s
    end
    attribute :permalink
    
    # @return [String]
    #   Base name of file, eg. /my_site/somefile/about.liquid -> about
    #
    def title
      @path.basename.to_s.split('.')[0].titlecase
    end
    attribute :title

    # If the output has been set during rendering return that value otherwise
    # assume the extension has not changed.
    #
    # @return [String]
    #
    def output
      @output || self.extension
    end
    attribute :output

    # @todo Get this working properly
    def plural_key
      singular_key.pluralize || 'files'
    end
    attribute :plural_key
    
    def singular_key
      @key ? @key.to_s : 'file'
    end
    attribute :singular_key
    

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
      if engine && can_render?
        # Only render when needed otherwise it is a waste of resources
        if !rendered? || force
          @rendered = engine.call(raw_content, payload)
        end
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
        puts "  #{'->'.green} #{dir.to_s.grey}/#{write_path}"
      end
    end
    
  end
end
