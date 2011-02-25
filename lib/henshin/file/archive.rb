module Henshin
  
  class Archive < Henshin::File
       
    def self.create(site)
    
      if site.methods.include? :archive
        warn "An Archive has already been created for #{site.name}"
      else
        site.send(:attr_accessor, :archive)
      end
    
      site.before(:render) do |site|
        archive = Archive.new(site.source + 'archive.html', site)
        site.posts.each do |post|
          archive << post
        end
        site.archive = archive
      end
    
      site.before(:write) do |site|
        site.archive.create_pages.each do |page|
          page.render
          page.write(site.write_path)
        end
      end
      
      site.resolve(/(\/\d\d\d\d)(\/\d\d){0,2}\/index\.html/) do |m, site|
        site.archive.page_for(m[0])
      end
      
      site.resolve(/\/archive\/index\.html/) do |m, site|
        site.archive.main_page
      end
      
    end
       
       
         
    def initialize(*args)
      @hash = {}
      super
    end
    
    def <<(post)
      return nil unless post.data['date']
      date = Time.parse(post.data['date'])
      year, month, day = date.year, date.month, date.day
      
      @hash[year] ||= {}
      @hash[year][month] ||= {}
      (@hash[year][month][day] ||= []) << post
    end
  
    def to_h
      r = {}
      @hash.each do |y, i|
        r[y] = {}
        i.each do |m, i|
          r[y][m] = {}
          i.each do |d, i|
            r[y][m][d] = []
            i.each do |i|
              r[y][m][d] << i.data
            end
          end
        end
      end
      r
    end
    
    # @param [String]
    #   "/2009/10/05" for example
    #
    # @return [ArchivePage]
    #
    def page_for(date_string)
      pages = create_pages
      pages.find {|i| i.permalink == date_string }
    end
    
    def main_page
      t = @site.source + 'archive' + 'index.html'
      
      payload = {
        'archive' => {
          'posts' => self.to_h
        }
      }
      
      page = ArchivePage.new(t, @site)
      page.layout = 'archive'
      page.inject_payload(payload)
      page
    end
    
    # @return [Array[ArchivePage]]
    #
    def create_pages
      r = []
      
      r << main_page
      
      self.to_h.each do |y, i|
        t = @site.source + y.to_s + 'index.html'
        
        payload = {
          'archive' => {
            'posts' => self.to_h,
            'year'  => y
          }
        }
        
        page = ArchivePage.new(t, @site)
        page.layout = 'archive_year'
        page.inject_payload(payload)
        r << page
      
        i.each do |m, i|
          t = @site.source + y.to_s + m.to_s + 'index.html'
          
          payload = {
            'archive' => {
              'posts' => self.to_h,
              'year'  => y,
              'month' => m
            }
          }
          
          page = ArchivePage.new(t, @site)
          page.layout = 'archive_month'
          page.inject_payload(payload)
          r << page
        
          i.each do |d, i|
            t = @site.source + y.to_s + m.to_s + d.to_s + 'index.html'
            
            payload = {
              'archive' => {
                'posts' => self.to_h,
                'year'  => y,
                'month' => m,
                'day'   => d
              }
            }
            
            page = ArchivePage.new(t, @site)
            page.layout = 'archive_date'
            page.inject_payload(payload)
            r << @site.pre_render([page]).first
          end
        end
      end
      
      r
    end
    
  end
  
  # Holds the archives for a year
  class ArchivePage < Henshin::File
    alias_method :_path, :path
    
    def path
      if layout
        Pathname.new(_path.to_s.gsub(/\..+/, ".#{layout.extension}"))
      else
        _path
      end
    end
    
    def has_yaml?; false; end
    def raw_content; layout.path.read; end
    attr_writer :layout
    # Need to swallow all arguments up as it really expects to be given an array,
    def layout(*args)
      l_file = Dir.glob(@site.source + "layouts/#{@layout}.*")[0]
      Henshin::Layout.new(l_file, @site)
    end
  end

end