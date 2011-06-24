module Henshin
  
  # Labels is an abstraction of Tags or Categories (it serves as both). In the 
  # site you can use Labels.define to create new Labels. There you pass a singular
  # and a plural name along with the site it will be attached to:
  #
  #   Labels.define(:tag, :tags, self)
  #
  # This will then generate some hooks using Base#before and Base#after to allow it
  # to render and write pages, for tags in this example.
  #
  class Labels < File::Text
    attr_accessor :list
    attr_accessor :single, :plural
    
    def initialize(*args)
      @list = []
      super
    end
    
    # If the layout for the specified label type is not found then it is not possible
    # to create so just save resources and ignore it! Both the index and single page
    # layouts should exist.
    #
    # @param single [Symbol] Name of label being created
    # @param site [Base] Site it will belong to
    def self.possible?(single, site)
      layouts_path = "#{single}_index"
      layout_path  = "#{single}_page"
      files = site.layouts
      if files.find {|i| i.name == layouts_path} && files.find {|i| i.name == layout_path }
        true
      else
        false
      end
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
      
      site.after :pre_render do |site|
        if Labels.possible?(single, site)
        
          unless site.respond_to? :labels
            class << site; attr_accessor :labels; end
          end
          site.labels ||= {}
          
          labels = Labels.create(single, plural, site)
          labels = site.pre_render_file(labels)
          
          site.files.each do |file|
            if label_name = file.yaml[single.to_s]
              labels.add_for(label_name, file)
            elsif label_names = file.yaml[plural.to_s]
              label_names.each do |label_name|
                labels.add_for(label_name, file)
              end
            end
          end
          
          labels.inject_payload do |file|
            { plural.to_s => site.labels[plural].map {|i| i.data} }
          end
          
          labels.map {|label| site.pre_render_file(label) }
          
          site.labels[plural] = labels
          site.inject_payload do |site|
            { plural.to_s => site.labels[plural].map {|i| i.data }}
          end
          
          site.files.each do |file|
            ls = labels.items_for(file)
            file.inject_data do |file|
              { plural.to_s => ls.map {|i| i.data} }
            end
          end
          
        end
      end
      
      site.after :render do |site|
        if Labels.possible?(single, site)
      
          site.labels[plural].layout
          site.labels[plural].each {|label| label.layout }
          
        end
      end
      
      site.before :write do |site|
        if Labels.possible?(single, site)
      
          site.labels[plural].render
          site.labels[plural].write(site.dest)
          
          site.labels[plural].each do |label|
            label.render
            label.write(site.dest)
          end
        
        end
      end

      site.resolve(/\/(#{plural})\/index.html/) do |m, site|      
        (site.labels ||= {})[m[0].to_sym]
      end
      
      site.resolve(/\/(#{plural})\/(.+)\/index.html/) do |m, site|
        if site.labels
          site.labels[m[0].to_sym].find {|i| i.url == "/#{m[0]}/#{m[1]}" }
        else
          nil
        end
      end

    end
    
    def <<(item)
      unless include?(item)
        @list << item
      end
    end
    
    def [](item_name)
      find {|i| i.name == item_name }
    end
    
    # Finds the +label+ then adds +item+ to it. If +label+ doesn't exist a
    # new one will be created.
    #
    # @param label [String]
    # @param item [Object]
    #
    def add_for(label, item)
      label_obj = create_or_find(label)
      label_obj.list << item
    end
    
    def create_or_find(item_name)
      if item = self[item_name]
        item
      else
        new_item = Label.define(@single, @plural, item_name, @site)
        @list << new_item
        new_item
      end
    end
    
    def items_for(post)
      find_all do |item|
        item.posts.include?(post.data)
      end
    end
    
    set :read,   false
    set :render, true
    set :layout, true
    set :write,  true
    
    def layout_names
      ["#{single}_index"]
    end
    
    def key
      @plural
    end
  
    def method_missing(sym, *args, &block)
      case sym.to_s
      when "#{@single}"
        @list
      when "#{@single}="
        @list = args
      when "#{@plural}_for"
        items_for(*args)
      when 'each', 'map', 'find', 'find_all', 'include?', 'first', 'last'
        @list.send(sym, *args, &block)
      else
        super # Raise the correct error!
      end
    end
  
  end
  
  
  class Label < File::Text
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
      @site.source + "#{@plural}/#{@name.slugify}.#{layout.extension}"
    rescue
      @site.source + "#{@plural}/#{@name.slugify}.html"
    end
    
    def posts
      @list.map {|i| i.data }
    end
    attribute :posts
    
    def url
      "/#{plural}/#{@name.slugify}"
    end
    
    def key
      @single
    end
    
    set :read,   false
    set :render, true
    set :layout, true
    set :write,  true
    
    def layout_names
      ["#{single}_page"]
    end
    
    def inspect
      "#<Henshin::Blog::Tags #{@name}, #{@list.size} posts>"
    end
  end

end