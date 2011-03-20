require 'pathname'
require 'yaml'
require 'ostruct'
require 'titlecase'
require 'fileutils'
require 'active_support/inflector'
require 'chronic'

require 'attr_plus'
require 'clive/output'

require 'henshin/core_ext'

require 'henshin/matcher'
require 'henshin/file'
require 'henshin/file/layout'


module Henshin

  # Description of DEFAULTS
  #
  #  'dest_prefix' directory (relative) to build sites to
  #  'source' source location
  #  'dest' build location
  #  'root' prefix for urls
  #  'layout_paths' paths to find layouts
  #  'ignore' array of files to ignore
  #  'load' array of files to load (then ignore)
  #
  DEFAULTS = {
    'dest_suffix'  => '_site',
    'source'       => Pathname.pwd,
    'dest'         => Pathname.pwd + '_site',
    'root'         => '',
    'layout_paths' => ['layouts/*.*', '**/layouts/*.*'],
    'ignore'       => [],
    'load'         => []
  }
  
  # module_attr_accessor :registered => {'base' => Henshin::Base}
  
  # Register a subclass of Henshin::Base that can be used for building sites
  # it should implement all the necessary protocols.
  #
  # @param key [String]
  #   Identifier used when loading with the command line interface, this is
  #   the argument that should be supplied to build using the klass.
  #
  # @param klass [Class]
  #
  def self.register(key, klass)
    # registered[key] = klass
  end
  
  # @abstract
  #
  # This class will eventually be the base of Henshin, when 
  # it is run normally. It will also serve as a base for any
  # other static site generator you could possibly imagine!
  #
  # Base itself will only have two types of files it deals
  # with in its mind: Gens and Statics. There is no post in
  # Base. It obviously also deals with layouts as well.
  #
  class Base
  
    @config = {}
    attr_accessor :files, :config, :write_path, :injects, :lazy_injects
    
    def source;       @config['source'];       end # Just a couple of basic helpers
    def dest;         @config['dest'];         end # for common config stuff
    def layout_paths; @config['layout_paths']; end
    
    # This is the recommended way of building a site, it can easily be
    # a one-liner. It creates the configuration hash from the options 
    # provided, then reads, renders and writes the site.
    #
    # @overload build(source)
    #   Creates a site using the source directory as the base and source/_site
    #   as the directory to write to, uses default options.
    #   @param source [String, Pathname] directory to read from
    #
    #   @example
    #
    #     Henshin::Base.build 'my_site/'
    #
    # @overload build(source, dest)
    #   Creates a site reading from the source directory and writing to the
    #   destination given, uses defaults for everything else.
    #   @param source [String, Pathname] directory to read from
    #   @param dest [String, Pathname] directory to write to
    #
    #   @example
    #
    #     Henshin::Base.build 'my_site/', 'built_site/'
    #
    # @overload build(source, dest, opts)
    #   Creates a site reading from +source+ and writing to +dest+, merges
    #   +opts+ with the defaults to create a configuration hash.
    #   @param source [String, Pathname] directory to read from
    #   @param dest [String, Pathname] directory to write to
    #   @param opts [Hash] options for the site (see Readme)
    #
    #   @example
    #
    #     Henshin::Base.build(
    #       'my_site', {'dest' => 'built_site/', 'root' => '~josh/'}
    #     )
    #
    # @return [Henshin::Base]
    #   The newly created and used instance of Henshin::Base.
    #
    def self.build(*args)
      config = {}
      args.each do |i|
        case i
        when Hash
          config.merge!(i)
        when Pathname
          if config['source']
            config['dest'] = i
          else
            config['source'] = i
          end
        when String
          if config['source']
            config['dest'] = Pathname.new(i)
          else
            config['source'] = Pathname.new(i)
          end
        end
      end
      if config['source'] && !config['dest']
        config['dest'] = config['source'] + DEFAULTS['dest_prefix']
      end
      site = new(config)
      site.read
      site.pre_render
      site.render
      site.write
    end
    
    # Creates a new instance of Henshin::Base.
    # 
    # @see .build
    # @param config [Hash] configuration for new site
    #
    def initialize(config={})
      # Precedence:
      # @@const > +config+ > @@pre_config > DEFAULTS
      begin
        @config = DEFAULTS.merge pre_config.merge config.merge constant
      rescue
        @config = DEFAULTS
      end
      load_config
      @files   = []
      @injects = []
    end
    
    # Check each of the +load_dirs+ for a config.yml file. When found use
    # this to override configuration.
    #
    # @param load_dirs [Array[Pathname]]
    # @return [Hash{String=>Object}]
    #
    def load_config(load_dirs=nil, load=true)
      load_dirs ||= [self.source, Pathname.pwd]
      
      load_dirs.each do |d|
        file = d + 'config.yml'
        if file.exist?
          begin
            loaded = YAML.load_file(file)
            @config.merge!(loaded)
          rescue => e
            warn "Could not read configuration, using defaults..."
            puts "-> #{e.to_s}"
          end
          break
        end
      end
      
      # If any requires require them, do that before loading!
      if @config['require'] && load
        [@config['require']].flatten.each do |i|
          require (source + i).realpath
          @config['ignore'] << (source + i).realpath
        end
      end
      
      # If any loads have been set load the files
      if @config['load'] && load
        [@config['load']].flatten.each do |i|
          self.class.class_eval (source + i).realpath.read
          @config['ignore'] << (source + i).realpath
        end
      end
      
      @config
    end
    
    def self.load_config(load_dirs=nil, load=true)
      new.load_config(load_dirs, load)
    end


    # Reads files from a set of directories, defaults to source directory. Removes all
    # directories, then removes files that have been set to ignore either in the class
    # or in the config. Then uses the filters to find the correct class to create 
    # instances of. These are then added to +@files+.
    #
    # @param dirs [Array[String]]
    # @return [Array[Henshin::File]]
    #
    def read(dirs = [self.source.to_s]) 
      run :before, :read, self
      
      glob_dir = Pathname.new("{"+dirs.join(',')+"}") + '**' + '*'
      
      found = Pathname.glob(glob_dir)
      found.reject! {|i| i.directory? }
      
      found.reject! do |f|
        r = false
        ignores.each do |m|
          if m.matches?(f.to_s) || m.matches?((f.relative_path_from(self.source)).to_s)
            r = true
            break
          end
        end
        
        @config['ignore'].each do |m|
          if f.realpath == m
            r = true
            break
          end
        end
        r
      end
           
      found.each do |f|
        _k = nil
        # Sort highest priority to lowest so as soon as a match is found we can break
        # and continue.
        filter_blocks.sort_by {|b| b.last }.reverse.each do |(m,k,p)|
          if m.matches?(f.relative_path_from(source).to_s)
            _k = k
            break
          end
        end
        if _k
          @files << _k.new(f, self)
        else # fallback to Henshin::File
          @files << Henshin::File.new(f, self)
        end
      end
      
      run :after, :read, self
      @files
    end
    
    # @return [Array[Henshin::Layout]]
    def layouts
      @layouts ||= (@files.find_all {|i| i.class == Henshin::Layout } || [])
    end


    # Runs the files given through the matching renders, that is blocks that were defined
    # using +Henshin::Base.render+. 
    #
    # Methods relating to the matches are defined within the file's class.
    # The block is then ran within this class, and is also passed the correct arguments.
    # This allows the block to call +splat+, instead of using a block parameter.
    #
    # @param files [Array[Henshin::File]]
    # @return [Array[Henshin::File]]
    #
    def pre_render(files=@files)
      files.each do |f|
        pre_render_file(f)
      end
      files
    end
    
    def pre_render_file(file)
      render_blocks.each do |(m,b)|
        if vals = m.matches(file.relative_path.to_s)
          if vals['splat']
            file.class.send(:define_method, :splat) { v }
          end
          
          if res = vals.select {|k,v| k != 'splat'}
            file.class.send(:define_method, :keys) { res }
          end
          
          file.instance_exec(*vals.values.flatten, &b)
        end
      end
      
      file
    end
    
    
    # Renders the file using the engines that were added when #pre_render ran. Then
    # finds the correct layout and renders the file within that.
    #
    # @param files [Array[Henshin::File]]
    # @param layouts [Array[Henshin::Layout]]
    # @param force [true, false]
    #
    # @return [Array[Henshin::File]]
    # 
    def render(files=@files, layouts=self.layouts, force=false)
      run :before, :render, self

      files.each do |f|
        render_file f, layouts, force
      end
      
      run :after, :render, self
      files
    end
    
    def render_file(file, layouts=self.layouts, force=false)
      run :before_each, :render, file
      file.render
      
      layout = file.find_layout(layouts)
      if layout
        file.rendered = layout.render_with(file)
      end
      
      run :after_each, :render, file
      file
    end
    
    def write_path
      self.dest # || others...
    end
     
    # Writes the site to the correct directory, by calling the write 
    # methods of all files with the directory to write into.
    def write(files=@files)
      run :before, :write, self
            
      files.each do |f|
        write_file(f)
      end
      
      run :after, :write, self
      self
    end
    
    def write_file(file)
      run :before_each, :write, file
      file.write(write_path)
      run :after_each, :write, file
    end
    
    
    # The main hash which will be mixed in with specific page hashes.
    #
    # @return [Hash]
    # 
    def payload
      files_hash = Hash.new {|h, k| h[k] = [] }
      
      @files.each do |file|
        if file.key
          files_hash[file.plural_key] << file.data
        end
      end

      r = {
        'files' => @files.map(&:data).uniq,
        'site' => {
          'created_at' => Time.now
        }.merge(@config)
      }.merge(files_hash)
      
      @injects.each do |i|
        if i.respond_to?(:call)
          r.merge!(i.call(self))
        else
          r.merge!(i)
        end
      end
      
      r
    end
    
    # Inject a hash into the payload method, this will be available to all files
    # that are rendered, and as such care must be taken when naming so as not to
    # cause conflicts with existing labels, see #payload for used names.
    #
    # @example
    #
    #   inject_payload {'test' => {'one' => 1}}
    #   # Allows you to use {{ test.one }} in all files
    #   inject_payload {'site' => {'one' => 1}}
    #   # Add to the main site hash, eg. {{ site.one }}
    #
    # @param arg [Hash, #call]
    #   If passed a hash, that is merged normally; if passed an object that 
    #   responds to #call ie. a proc (or block) then that is passed the site
    #   object and is expected to return a hash to be merged in.
    #  
    def inject_payload(arg=nil)
      arg = Proc.new if block_given? && arg.nil?
      raise ArgumentError unless arg
      @injects << arg
    end


  # @group DSL
  # 
  # These methods are all for use when building subclasses of Henshin::Base.
  #

    class_attr_accessor :render_blocks, :filter_blocks, :ignores, :default => []
    class_attr_accessor :pre_config, :constant, :routes, :default => {}
    class_attr_accessor :actions => {
      :before =>      { :read => [], :render => [], :write => [] },
      :after =>       { :read => [], :render => [], :write => [] },
      :before_each => { :read => [], :render => [], :write => [] },
      :after_each =>  { :read => [], :render => [], :write => [] }
    }
    
    FILTER_PRIORITIES = {
      :low => 0,
      :medium => 1,
      :high => 2,
      :internal => 3 # for internal use only, ie. make sure layouts work
    }
    
    # Define a block to be run when a match to the pattern given is made. The
    # block will be run within the context of the file givin access to the file's
    # instance methods. See Henshin::File#set, Henshin::File#apply and 
    # Henshin::File#use for more information.
    #
    # @example
    #
    #   render '**/:title.md' do
    #     apply Maruku
    #     set :title, keys[:title]
    #   end
    #
    # @param match [String, Regexp]
    #   This string will be used to create a new instance of Henshin::Matcher, see
    #   it's documentation for more information.
    #
    def self.render(match, &block)
      render_blocks << [Matcher.new(match), block]
    end

    # Set a specific class for matches to the pattern given. All files matching
    # this, depending on the priority of other matches, will become instances
    # of the class given. The priority can be set as :low, :medium or :high.
    #
    # @param match [String, Regexp]
    #   This string will be used to create a new instance of Henshin::Matcher, see
    #   it's documentation for more information.
    #
    # @param klass [Class]
    #   Class to create instances of.
    #
    # @param priority [Symbol]
    #   Either +:low+, +:medium+ or +:high+.
    #
    def self.filter(match, klass, priority=:low)
      filter_blocks << [Matcher.new(match), klass, FILTER_PRIORITIES[priority]]
    end
    
    # Set the default layouts path!
    filter 'layouts/*.*', Layout, :internal
       
    # Specify a Matcher pattern to ignore when reading, and then obviously writing
    # files.
    #
    # @param args [String, Regexp]
    #   See Henshin::Matcher.
    #
    # @example
    #
    #   ignore '_site/**'
    #   # ignores:
    #   #   _site/this-file.txt
    #   # but not:
    #   #   my_site/a-file.txt
    #
    def self.ignore(*args)
      ignores.concat args.map {|i| Matcher.new(i) }
    end
    
    # Set a specific value for a configuration variable. This will then be used 
    # above the value in Henshin::DEFAULT but below any user set value, for that 
    # use +.const+.
    #
    # @see .const
    # @example
    #
    #   set :write_path, '~/dest'
    #
    def self.set(key, value)
      pre_config[key.to_s] = value
    end
    
    # Set a specific value for a configuration variable. This will be the value
    # that is used, it will not be overridden by a users value.
    #
    # @see .set
    # @example
    #
    #   const :write_path, '~/dest'
    #
    def self.const(key, value)
      constant[key.to_s] = value
    end
    
    # Set up a file to be rendered when a particular path is hit when serving.
    # If a file is passed it will be rendered and served to the browser, but if
    # a block is given it will be passed the match object from the pattern and
    # will have to return a File.
    #
    # @param pattern [String, Regexp]
    #   @see Henshin::Matcher
    #
    # @param file [Henshin::File]
    #   File to be rendered when the pattern is matched.
    #
    def self.resolve(pattern, file=nil, &block)
      routes[Matcher.new(pattern)] = file || block
    end

    def self.before(a, &block)
      actions[:before][a] << block
    end
    
    def self.after(a, &block)
      actions[:after][a] << block
    end
    
    def self.before_each(a, &block)
      actions[:before_each][a] << block
    end
    
    def self.after_each(a, &block)
      actions[:after_each][a] << block
    end
    
    # Runs the appropriate blocks, if set.
    #
    # @param time [Symbol]
    #   Either :before, :after, :before_each or :after_each.
    #
    # @param a [Symbol]
    #   Either :all or :each, whether to run before/after all 
    #   tasks have been done, or to run before/after each task
    #   is done.
    #
    def run(time, a, *args)
      actions[time][a].each do |proc|
        proc.call(*args)
      end
    end
    
  end
end
