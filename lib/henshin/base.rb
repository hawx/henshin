require 'pathname'
require 'yaml'
require 'ostruct'
require 'titlecase'
require 'fileutils'
require 'active_support/inflector'

require 'class_attr'

require 'henshin/file'
require 'henshin/file/layout'


module Henshin
  
  # @abstract
  #
  # This class will eventually be the base of Henshin, when 
  # it is run normally. It will also serve as a base for any
  # other static site generator you could possibly imagine!
  #
  # Base itself will only have two types of files it deals
  # with in its mind: Gens and Statics. There is no post in
  # Base. It obviously also deals with layouts aswell.
  #
  #
  # *CONFIG*
  #
  # This is a list of the configuration variables available to use:
  #
  #   dest   #=> [Pathname] The directory to write into
  #   source #=> [Pathname] The directory to read from
  #   root   #=> [String] A prefix to append to all urls
  #
  class Base
    
    DEFAULTS = {
      'dest_prefix'  => '_site',
      'source'       => Pathname.pwd,
      'dest'         => Pathname.pwd + '_site',
      'root'         => '',
      'layout_paths' => ['layouts/*.*', '**/layouts/*.*']
    }
    
    @config = {}
    attr_accessor :files, :config, :write_path
    
    
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
      new(config).read.render.write
    end
    
    # Creates a new instance of Henshin::Base.
    # 
    # @see .build
    # @param config [Hash] configuration for new site
    #
    def initialize(config={})
      # Precedence:
      # @@const > +config+ > @@pre_config > DEFAULTS
      @config = DEFAULTS.merge pre_config.merge config.merge const
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
    def load_config(load_dirs=nil)
      load_dirs ||= [self.source, Pathname.pwd]
      
      load_dirs.each do |d|
        file = d + 'config.yml'
        if file.exist?
          begin
            loaded = YAML.load_file(file)
            @config = @config.merge(loaded)
          rescue => e
            warn "Could not read configuration, using defaults..."
            puts "-> #{e.to_s}"
          end
          break
        end
      end
      
      @config
    end
    
    def self.load_config(load_dirs=nil)
      new.load_config(load_dirs)
    end
    
    # Reads the files 
    def read
      @files = []
      run(:before, :read, self)
      
      glob_dir = self.source + '**' + '*'
      files = Pathname.glob(glob_dir)
      files.reject! {|i| i.directory? }
      
      files.reject! do |f|
        r = false
        ignores.each do |m|
          if f.fnmatch(m)
            r = true
            break
          end
        end
        r
      end
      
      files.each do |file|
        @files <<  run_through_filters(file)
      end
      
      run(:after, :read, self)
      self
    end
    
    # Run a path through @@filters
    #
    # @param [Pathname]
    # @return [Henshin::File]
    #
    def run_through_filters(file)
      found = []
      k = nil
      
      filters.each do |filter|
        if filter.matches?(file)
          found << filter
        end
      end
        
      layout_paths.each do |m|
        if file.fnmatch(m)
          k = Henshin::Layout
        end
      end
      
      if k
        instance = k.new(file, self)
        found.each {|b| b.do_filter!(instance) }
        instance
      elsif found != []
        k = found.map(&:klass).compact.last
        if k
          instance = k.new(file, self)
          found.each {|b| b.do_filter!(instance) }
          instance
        else
          instance = Henshin::File.new(file, self)
          found.each {|b| b.do_filter!(instance) }
          instance
        end
      else
        Henshin::File.new(file, self)
      end
    end
    
    
    # Run a file through @@filters
    #
    # @param [Henshin::File]
    # @return [Henshin::File]
    #
    def run_file_through_filters(file)
      found = []
      
      filters.each do |filter|
        if filter.matches?(file.path)
          found << filter
        end
      end
      
      found.each {|b| b.do_filter!(file)}
      file
    end
    
    def render
      run(:before, :render, self)
      @files.each do |file|
        run(:before_each, :render, file)
        file.render
        
        layout = file.layout(files)
        if layout
          file.rendered = layout.render_with(file)
        end
        run(:after_each, :render, file)
      end
      
      run(:after, :render, self) 
      self
    end
     
    # Writes the site to the correct directory, by calling the write 
    # methods of all files with the directory to write into.
    def write
      @write_path = self.dest # || others...
      run(:before, :write, self)
            
      @files.each do |file|
        run(:before_each, :write, file)
        file.write(@write_path)
        run(:after_each, :write, file)
      end
      
      run(:after, :write, self)
      self
    end
    
    # Renders a single file. This is used for the Rack interface. This
    # should only load the files necessary to render the one file, so 
    # instead of loading _every_ layout, we only load the one needed,
    # and we do not load every other none related file.
    #
    # @param permalink [Pathname]
    #   Permalink of the file to render.
    #
    def render_file(permalink)
      files = self.read.files
      
      file = files.find {|i| i.permalink == permalink }
      
      if file
        run(:before, :render, self)
        file.render(true)
        
        layout = file.layout(files)
        
        if layout
          file.rendered = layout.render_with(file)
        end
        run(:after, :render, self)
        
        [200, {"Content-Type" => file.mime}, [file.content]]
      else
        # Check the routes that have been set
        routes.each do |pattern, action|
          m = pattern.match(permalink)
          if m && action
            run(:before, :render, self)
          
            file = action
            if action.respond_to?(:call)
              file = action.call(m, self)
              break unless file
            end
            
            file.render(true)
            
            layout = file.layout(files)
            
            if layout
              layout = run_file_through_filters(layout)
              file.rendered = layout.render_with(file)
            end
            run(:after, :render, self)
            
            # Force the return!!!
            return [200, {"Content-Type" => file.mime}, [file.content]]
          end
        end
      
        [404, {}, ["404 page not found"]]
      end
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
        r.merge!(i)
      end

      r
    end
    
    
    # These are the class methods to be used when setting up a sub-class of 
    # Henshin::Base.
    
    class_attr_accessor :filters, :ignores, :default => []
    class_attr_accessor :pre_config, :const, :routes, :default => {}

    # Create a new file filter, this controls the main logic behind reading,
    # rendering and writing the actual files. With this you can take a more 
    # generalised class and specify different parameters for the specific file
    # that is being dealt with, instead of placing all of this extra logic 
    # within the actual class itself.
    #
    # @example
    #
    #   class Page < Henshin::File
    #     # general stuff
    #     key = :page
    #     output = 'html'
    #   end
    #
    #   filter '**/*.md' => Page do |f|
    #     # specifiy a engine to render with
    #     f.engine = lambda do |content, data|
    #       begin 
    #         doc = Maruku.new(content)
    #         doc.to_html
    #       rescue NameError
    #         require 'maruku'
    #         retry
    #       end
    #     end
    #   end
    #
    def self.filter(arg, &block)
      patterns = *arg.keys[0]
      klass = arg.values[0]
      
      ins = FilterBody.new
      ins.klass = klass
      ins.patterns = patterns
      ins.body = block
      
      filters << ins
    end
    
    # Inherit all filters from another class. The other class must obviously be a
    # subclass of Henshin::Base as well.
    #
    # @example
    #
    #   class SiteClone < Henshin::Site
    #     inherit_filters Henshin::Site
    #   end
    #
    def self.inherit_filters(klass)
      filters.concat klass.filters
    end
    
    
    # Specify a glob pattern to ignore when reading, and then obviously writing
    # files.
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
      ignores.concat args
    end
    
    # Inherit all ignores from another class.
    # @see .inherit_filters
    #
    def self.inherit_ignores(klass)
      ignores.concat klass.ignores
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
    # that is used, it will not be overriden by a users value.
    #
    # @see .set
    # @example
    #
    #   const :write_path, '~/dest'
    #
    # def self.const(key, value)
    #   @const ||= {}
    #   @const[key] = value
    # end
    
    # Set up a file to be rendered when a particular path is hit when serving.
    # If a file is passed it will be rendered and served to the browser, but if
    # a block is given it will be passed the match object from the pattern and
    # will have to return a File.
    #
    # @param pattern [Regexp]
    #   Regular expression for the permalink that was asked for to match with.
    #
    # @param file [Henshin::File]
    #   File to be rendered when the pattern is matched.
    #
    def self.resolve(pattern, file=nil, &block)
      routes[pattern] = file || block
    end
    
    
    # Instance methods used for configuring a Henshin::Base subclass.
    
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
    def inject_payload(hash)
      @injects << hash
    end
    
    
  # @group Runner
  
    class_attr_accessor :actions => {
      :before => {
        :read   => [],
        :render => [],
        :write  => []
      },
      :after => {
        :read   => [],
        :render => [],
        :write  => []
      },
      :before_each => {
        :read   => [],
        :render => [],
        :write  => []
      },
      :after_each =>{
        :read   => [],
        :render => [],
        :write  => []
      }
    }
    
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
    
    # The basic runner should be called when necessary and will
    # run the tasks that should be run. __Do not__ call every
    # single little method, just the important ones.
    #
    # @example When to call :each
    #   
    #   def read
    #     run :before, :each
    #     # read the file ...
    #     run :after, :each
    #   end
    #
    # @example When to call :before, :all
    #
    #   def initialize(*args)
    #     @args = args
    #     run :before, :all
    #   end
    #
    # @example When to call :after, :all
    #
    #   def clean_up
    #     # clean up ...
    #     run :after, :all
    #   end
    #
    # @param time [Symbol] 
    #   Either :before or :after, whether the block should be
    #   run before any actions are taken or after all actions
    #   have been taken.
    #   Or :before_each, :after_each.
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
  
  # @endgroup
    
  end
  
end


class String

  # Turns the string to a slug
  #
  # @return [String] the created slug
  def slugify
    slug = self.clone
    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.gsub!(' ', '-')
    slug
  end
  
end