# stdlib
require 'pathname'
begin
  require 'pysch' 
rescue LoadError 
  require 'yaml'
end
require 'fileutils'

# 3rd party
require 'titlecase'
require 'linguistics'; Linguistics.use :en
require 'clive/output'
require 'attr_plus'

# 1st party
require 'henshin/core_ext'
require 'henshin/delegator'
require 'henshin/engine'
require 'henshin/matcher'

require 'henshin/file'
require 'henshin/file/text'
require 'henshin/file/binary'
require 'henshin/file/layout'

module Henshin

  # A generic error, allowing you to pass a list of arguments for later use.
  class HenshinError < StandardError
    def initialize(*args)
      @args = args
    end
  end

  # Description of DEFAULTS
  #
  # - +dest_prefix+ - directory (relative) to build sites to
  # - +source+ - source location
  # - +dest+ - build location
  # - +root+ - prefix for urls
  # - +ignore+ - array of files to ignore
  # - +load+ - array of files to load (then ignore)
  # - +layout+ - default layout to use
  #
  DEFAULTS = {
    'dest_suffix'  => '_site',
    'source'       => Pathname.pwd,
    'dest'         => Pathname.pwd + '_site',
    'root'         => '',
    'ignore'       => [],
    'load'         => [],
    'layout'       => 'main'
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
  
  # Register a symbol to be used when applying engines. The class name can
  # always be used but it is usually nicer to write +apply :sass+ instead of
  # +apply Henshin::Engine::Sass+, it also allows you to dynamically assign
  # a specific engine to a key. For example you can vary the markdown 
  # library used depending on settings provided in config.yml.
  #
  # @param sym [Symbol] Symbol shortcut to use engine
  # @param klass [Class] The engine
  #
  def self.register_engine(sym, klass)
    registered_engines[sym] = klass
  end
  
  module_attr_accessor :registered_engines => {}
  
  # @abstract
  #
  # This class is the base of Henshin, it implements everything necessary
  # but nothing more so that it can be subclassed and modified easily.
  #
  class Base
  
    @config = {}
    attr_accessor :files, :config, :injects, :lazy_injects
    #hash_attr_reader :@config, 'source', 'dest' this seems to be broken!?!
    def source; @config['source']; end
    def dest;   @config['dest']; end
    
    attr_writer :server
    # Whether a server is running or not
    def server?; @server || false; end
    
    # This is the recommended way of building a site. It creates the configuration 
    # hash from the options provided, then reads, renders and writes the site.
    #
    # @overload build(source)
    #   Creates a site using the source directory as the base and +source/_site+
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
      # config > pre_config > DEFAULTS
      begin
        @config = DEFAULTS.merge pre_config.merge config
      rescue
        @config = DEFAULTS
      end      
      @config.merge! load_config
      
      load_files
      
      @files   = []
      @injects = []
    end
    
    # Check each of the +load_dirs+ for a config.yml file. When found use
    # this to override configuration.
    #
    # @param load_dirs [Array[Pathname]]
    # @return [Hash{String=>Object}]
    #
    def self.load_config(load_dirs=[Pathname.pwd])
      loaded = {}

      load_dirs.uniq.compact.each do |d|
        file = d + 'config.yml'
        
        if file.exist?
          begin
            loaded = YAML.load_file(file)
          rescue => e
            warn "Could not read configuration, using defaults..."
            puts "-> #{e.to_s}"
          end
          break
        end
      end
      
      # Need to map certain config options to specific classes, this
      # describes what goes to what class.
      {
        'dest'   => Pathname,
        'source' => Pathname
      }.each do |k,v|
        if loaded.has_key?(k)
          loaded[k] = v.new(loaded[k])
        end
      end
      
      loaded
    end
    
    # Load +config.yml+ from the directories given
    #
    # @param load_dirs [Array[Pathname]]
    # @return [Hash{String=>Object}]
    #
    def load_config(load_dirs=[self.source, Pathname.pwd])
      self.class.load_config(load_dirs)
    end
      
    # Loads files that have been set to be loaded in config.yml. These
    # are then evaluated in the class's context so have access to the 
    # usual methods for defining rules and actions.
    def load_files
      if @config['load']
        [@config['load']].flatten.each do |i|
          if ::File.exist?(i)
            self.class.class_eval ::File.read(i), i
            ignore i
          elsif (source + i).exist?
            self.class.class_eval (source + i).read, (source + i)
            ignore (source + i)
          end
        end
      end
    end
    
    # @param path [Pathname] Path to the file to be tested.
    # @return [true, false] Whether this site ignores the path that is passed.
    def ignores?(path)
      r = false
      ignores.each do |m|
        if m.matches?(path.to_s) || m.matches?((path.relative_path_from(self.source)).to_s)
          r = true
          break
        end
      end
      return true if r == true # quick return
      
      [@config['ignore']].flatten.each do |m|
        if path.fnmatch?(m) || path.fnmatch?((source + m).to_s)
          r = true
          break
        end
      end
      r
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
      found.reject! {|f| ignores?(f) }

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
        else # fallback to Henshin::File::
          if ::File.binary?(f)
            @files << Henshin::File::Binary.new(f, self)
          else # otherwise assume it's text
            @files << Henshin::File::Text.new(f, self)
          end
        end
      end

      run :after, :read, self
      @files
    end    
    
    # @return [Array[Henshin::Layout]]
    #   Returns all layout files.
    def layouts
      @layouts ||= (@files.find_all {|i| i.class == Henshin::File::Layout } || [])
    end

    # @see #pre_render_file
    # @param files [Array[Henshin::File]]
    # @return [Array[Henshin::File]]
    def pre_render(files=@files)
      run :before, :pre_render, self
    
      files.each do |f|
        pre_render_file(f)
      end
      
      run :after, :pre_render, self
      files
    end
    
    # Runs the file given through the matching rule blocks that have been defined.
    #
    # Methods relating to the matches are defined within the file's class. The
    # block is then run within this class, and is also passed the correct arguments.
    # This allows the block to call +splat+ instead of using a block parameter.
    #
    # @param file [Henshin::File]
    # @return [Henshin::File]
    #
    def pre_render_file(file)
      run :before_each, :pre_render, file
      rules.each do |(m,b)|
        if vals = m.matches(file.relative_path.to_s)
          if vals['splat']
            file.class.send(:define_method, :splat) { vals['splat'] }
          end
          
          if res = vals.select {|k,v| k != 'splat'}
            file.class.send(:define_method, :keys) { res }
          end
          
          file.instance_exec(*vals.values.flatten, &b)
        end
      end

      file.class.send(:remove_method, :splat) if file.respond_to? :splat      
      file.class.send(:remove_method, :keys) if file.respond_to? :keys
      
      run :after_each, :pre_render, file
      file
    end
    
    
    # @see #render_file
    # @param files [Array[Henshin::File]]
    # @param force [true, false]
    # @return [Array[Henshin::File]]
    def render(files=@files, force=false)
      run :before, :render, self

      files.each do |f|
        render_file(f, force)
      end
      
      run :after, :render, self
      files
    end
    
    # Renders the file using the engines that were added during #pre_render, then
    # finds the corresponding layout and renders the file within that, if it exists.
    #
    # @param file [Henshin::File]
    # @param force [true, false] Force the file to be rendered again.
    def render_file(file, force=false)
      run :before_each, :render, file
      
      file.render(force)
      file.layout
      
      run :after_each, :render, file
      file
    end
    
    # @see #write_file
    # @param [Array[Henshin::File]]
    def write(files=@files)
      run :before, :write, self
            
      files.each do |f|
        write_file(f)
      end
      
      run :after, :write, self
      self
    end
    
    # Writes the file to .dest.
    # 
    # @param file [Henshin::File]
    #
    def write_file(file)
      run :before_each, :write, file
      file.write(self.dest)
      run :after_each, :write, file
    end
    
    # Time the site was created at, this is then cached in a variable so that
    # it doesn't change if the site takes a few seconds to build.
    def created_at
      @_created_at ||= Time.now
    end
    
    # The site-wide payload hash, this is mixed in to the payloads of every 
    # other file and contains the data of every file created along with 
    # some convenient values such as the time created and the config.
    #
    # @return [Hash{String=>Object}]
    # 
    def payload
      files_hash = Hash.new {|h, k| h[k] = [] }
      
      @files.each do |file|
        if file.key
          files_hash[file.plural_key] << file.data
        end
      end

      r = {
        'files' => @files.map(&:data),
        'site' => {
          'created_at' => created_at
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
  # I've delegated these methods so they are available for classes and instances
  # though remember that affecting one instance of a class will affect all
  # others.
  #
  # @todo Allow different instances to have different methods
  #   ie. you make that last sentence false!!
  #

    class_attr_accessor :rules, :filter_blocks, :ignores, :default => []
    class_attr_accessor :pre_config, :constant, :routes, :default => {}
    class_attr_accessor :actions => {
      :before =>      { :read => [], :pre_render => [], :render => [], :write => [] },
      :after =>       { :read => [], :pre_render => [], :render => [], :write => [] },
      :before_each => { :read => [], :pre_render => [], :render => [], :write => [] },
      :after_each =>  { :read => [], :pre_render => [], :render => [], :write => [] }
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
    # For more detail on how the rules are used see #pre_render_file.
    #
    # @example
    #
    #   rule '**/:title.md' do
    #     apply Maruku
    #     set :title, keys[:title]
    #   end
    #
    # @param match [String, Regexp]
    #   This string will be used to create a new instance of Henshin::Matcher, see
    #   it's documentation for more information.
    #
    def self.rule(match, &block)
      rules << [Matcher.new(match), block]
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
    # above the value in Henshin::DEFAULT but below any user set value. This
    # means everything set in this way _can_ be overriden by the user. If you
    # want to set a constant value for the class use CONSTANTS!
    #
    # @example
    #
    #   set :dest, '~/dest'
    #
    def self.set(key, value)
      pre_config[key.to_s] = value
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
    
    extend Delegator
    
    # base.set(:k, 'v'), becomes, base.class.set(:k, 'v')
    delegates :class, 
                :after_each, :before_each, :after, :before, :rule,
                :resolve, :const, :set, :ignore, :filter
              
    
  end
end
