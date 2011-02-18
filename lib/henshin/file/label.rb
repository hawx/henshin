module Henshin
  
  # Labels is an abstraction of Tags or Categories (it serves as both). In the 
  # site you can use Labels.define to create new Labels. There you pass a singular
  # and a plural name along with the site it will be attached to:
  #
  #   Labels.define(:tag, :tags, self)
  #
  # This will then generate some hooks using Base#before and Base#after to allow it
  # to render and write pages, for tags in this example. For it to work the files it
  # is expected to work on will have to implement the correct attribute, so taking the
  # same example in Post I add:
  #
  #   attribute :tags
  #
  # This will then be passed the correct data before rendering, and that will then be
  # passed to the layout engine. (You could use #attr_accessor but wouldn't be able to
  # access the data in your layouts!)
  #
  class Labels < Henshin::File
    attr_accessor :list
    attr_accessor :single, :plural
    
    def initialize(*args)
      @list = []
      super
    end
    
    def self.create(single, plural, site)
      labels = new(site.source + "#{plural.to_s}/index.html", site)
      labels.single = single
      labels.plural = plural
      
      labels
    end
    
    # This basic method will hook in the label to render and write.
    # It basically generates the correct blocks and adds them to the 
    # correct places.
    #
    # Generates:
    #  - #before :render hooks
    #  - #before :write hooks
    #  - #resolve hooks
    #
    def self.define(single, plural, site)
      unless site.methods.include? :labels
        site.send(:attr_accessor, :labels)
      end
    
      site.before(:render) do |site|
        site.labels ||= {}
        labels = Labels.create(single, plural, site)
        labels = site.pre_render([labels]).first
        
        site.files.each do |file|
          if label_name = file.data[single.to_s]
            labels.add_for(label_name, file)
          elsif label_names = file.data[plural.to_s]
            label_names.each do |label_name|
              labels.add_for(label_name, file)
            end
          end
        end
        
        labels.inject_payload({ plural => labels.map {|i| i.to_h } })
        
        labels.each do |label|
          label = site.pre_render([label]).first
          label.inject_payload({ single => label.data })
        end
        
        unless site.respond_to? :labels
          class << site; attr_accessor :labels; end
          site.labels = {}
        end
        site.labels[plural] = labels
        site.inject_payload({ plural => labels.data })
        
        site.files.each do |file|
          ls = labels.items_for(file).map {|i| i.to_h }
          unless ls.empty?
            file.send("#{plural}=", ls)
          end
        end
      end
      
      site.before(:write) do |site|
        site.labels[plural].render
        site.labels[plural].write(site.write_path)
        
        site.labels[plural].each do |label|
          label.render
          label.write(site.write_path)
        end
      end
      
      site.resolve(/\/(#{plural})\/index.html/) do |m, site|
        (site.labels ||= {})[m[1].to_sym]
      end
      
      site.resolve(/\/(#{plural})\/(.+)\/index.html/) do |m, site|
        site.labels ? site.labels[m[1].to_sym].find {|i| i.permalink == m[0] } : nil
      end
    end
    
    def <<(item)
      unless include?(item)
        @list << item
      end
    end
    
    def find_item(item_name)
      find {|i| i.name == item_name }
    end
    
    # Finds the +label+ then adds +item+ to it. If +label+ doesn't exist a
    # new one will be created.
    #
    # @param label [String]
    # @param item [Object]
    #
    def add_for(label, item)
      if l = find_item(label)
        l.list << item
      else
        l = Label.define(@single, @plural, label, @site)
        @list << l
        l.list << item
        l
      end
    end
    
    def create_or_find(item_name)
      if item = find_item(item_name)
        item
      else
        new_item = Label.define(@single, @plural, item_name, @site)
        @list << new_item
        new_item
      end
    end
    
    def path
      @site.source + "#{@plural}/index.#{layout.extension}"
    rescue
      @site.source + "#{@plural}/index.html"
    end
    
    def items_for(post)
      find_all do |item|
        item.posts.include?(post.data)
      end
    end
    
    def has_yaml?; false; end
    def raw_content; layout.path.read; end
    attr_writer :layout
    # Need to swallow all arguments up as it really expects to be given an array,
    def layout(*args)
      l_file = Dir.glob(@site.source + "layouts/#{single}_index.*")[0]
      Henshin::Layout.new(l_file, @site)
    end
  
    def method_missing(sym, *args, &block)
      case sym.to_s
      when "#{single}"
        @list
      when "#{single}="
        @list = args
      when "#{plural}_for"
        items_for(*args)
      when 'each', 'map', 'find', 'find_all', 'include?'
        @list.send(sym, *args, &block)
      else
        super # Raise the correct error!
      end
    end
  
  end
  
  class Label < Henshin::File
    attr_accessor :single, :plural
    attr_accessor :name, :list
    
    def initialize(*args)
      @list = []
      super
    end
    
    def self.define(single, plural, name, site)
      label = new(site.source + "#{plural}/#{name.slugify}/index.html", site)
      label.single = single
      label.plural = plural
      label.name   = name
      label
    end
    
    attribute :name
    
    def path
      @site.source + "tags/#{@name.slugify}.#{layout.extension}"
    rescue
      @site.source + "tags/#{@name.slugify}/index.html"
    end
    
    def safe_to_h
      {
        'name'      => @name,
        'url'       => url,
        'permalink' => permalink
      }
    end
    
    def to_h
      safe_to_h.merge({'posts' => posts})
    end
    
    def posts
      @list.map {|i| i.data }
    end
    attribute :posts
    
    def url
      "/#{@plural}/#{@name.slugify}"
    end
    
    def permalink
      "/#{plural}/#{@name.slugify}/index.html"
    end
    
    def write_path
      Pathname.new permalink[1..-1]
    end
    
    def raw_content
      layout.path.read
    rescue
      ""
    end
    
    def has_yaml?; false; end
    # @see Labels#layout
    def layout(*args)
      return @layout if @layout
      l_file = Dir.glob(@site.source + "layouts/#{single}_page.*")[0]
      @layout = Henshin::Layout.new(Pathname.new(l_file), @site)
    end
    
    def inspect
      "#<Henshin::Blog::Tags #{@name}, #{@posts.size} posts>"
    end
  end

end