# A slideshow would be interesting to do and possible by the end!

require_relative 'base'
require_relative 'engine/basic'

module Henshin
  class SlideShow < Base
  
    include BasicRules
  
    class Slide < Henshin::File
    
      attr_reader :top
    
      def initialize(top, content, site)
        # remove $$$ from array, then normalise
        @top = top.split(' ')[1..-1].map {|i| i.downcase.to_sym }
        self.content = content.join("\n")
        super('slide.html', site)
      end
      
      def key
        :slide
      end
      
      def readable?; false; end
      def writeable?; false; end
      
      [:bullets, :incremental, :quote, :center, :code].each do |sym|
        define_method(sym) do
          top.include? sym
        end
        attribute sym
      end
      
      def find_layout(files=@site.layouts)
        files.find {|f| f.name == 'slide' }
      end
      
    end
  
    # May contain multiple slides in one file by breaking them up using $$$.
    class Slides < Henshin::File
      def key
        :slides
      end
      
      def slides     
        lines = raw_content.split("\n")
        slides = []
        
        lines.each do |i|
          if i =~ /^\$\$\$/
            slides << [i, []]
            curr = i
          else
            slides.last.last << i
          end
        end
        
        slides.map do |(k, v)| 
          s = Slide.new(k, v, @site) 
          s.apply Engine::Maruku
          s
        end
      end

      def text
        slides.map {|s|
          begin
            s.render
            l = s.find_layout
            s.rendered = l.render_with(s) 
          rescue
            ""
          end
        }.join("\n")
      end
      
      def writeable?; false; end
    end
    
    class SlideHolder < Henshin::File
      def readable?; false; end
      def renderable?; false; end
      
      def initialize(*args)
        @slides = []
        super
      end
      
      attr_accessor :slides
      
      def find_layout(files=@site.layouts)
        files.find {|f| f.name == "main" }
      end
      
      def raw_content
        slides.map {|i| i.text }.join("\n")
      end
    end
    
    # Only support markdown for now!
    rule 'slides/:title.md' do
      @site.slide_file.slides << self
    end
    
    attr_accessor :slide_file
    
    after :read do |site|
      site.slide_file = SlideHolder.new(site.source + 'index.html', site)
    end
    
    after :render do |site|
      site.render_file(site.slide_file, site.layouts)
    end
    
    after :write do |site|
      site.write_file(site.slide_file)
    end
    
    resolve '/index.html' do |site|
      site.slide_file
    end
    
    filter 'slides/*.*',  Slides
    filter 'layouts/*.*', Layout, :internal
    
    set :layout_paths, ['layouts/*.*', '**/layouts/*.*']
    
    ignore '_site/**'
    ignore '*.yml'
  
    after_each :write do |file|
      if file.writeable?
        puts "  #{'->'.green} #{file.write_path.to_s.grey}"
      end
    end
  
  end
end