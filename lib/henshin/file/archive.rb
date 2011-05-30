module Henshin
  
  # Create an Archive (that is chronological lists of files mapped to keys
  # which correspond to year, month and date of the file) by adding this
  # to a subclass of Henshin::Base.
  #
  #   class MySite < Henshin::Base
  #     Henshin::Archive.create(self)
  #   end
  #
  # Then add the following to your layouts folder; 'archive', 'archive_year',
  # 'archive_month', 'archive_date'. See the examples folder for ideas on
  # setting them up.
  #
  # @todo Make it possible to just have yearly/monthly/dately archives or a
  #  combination depending on which layouts are present, instead of the all
  #  or nothing action currently taken.
  class Archive < Henshin::File
       
    def self.create(site)
    
      if site.methods.include? :archive
        warn "An Archive has already been created for #{site.name}"
      else
        site.send(:attr_accessor, :archive)
      end
    
      site.before(:render) do |site|
        return false unless Archive.possible?(site)
        
        archive = Archive.new(site.source + 'archive.html', site)
        site.posts.each do |post|
          archive << post
        end
        site.archive = archive
      end
    
      site.before(:write) do |site|
        return false unless Archive.possible?(site)
      
        site.archive.pages.each do |page|
          page.render
          page.write(site.dest)
        end
      end
      
      site.resolve(/(\d{4})\/(\d{2})\/(\d{2})\/index.html/) do |m, site|
        site.archive.page_for m
      end
      
      site.resolve(/(\d{4})\/(\d{2})\/index.html/) do |m, site|
        site.archive.page_for m
      end
      
      site.resolve(/(\d{4})\/index.html/) do |m, site|
        site.archive.page_for m
      end
      
      site.resolve(/\/archive\/index\.html/) do |site|
        site.archive.main_page
      end
      
    end
    
    # Should only be possible to create an archive if the correct layouts exist
    # so check that they do before building all the pages.
    def self.possible?(site)
      layouts = %w(archive archive_year archive_month archive_date)
      
      r = true
      
      layouts.each do |layout|
        unless site.layouts.find {|i| i.name == layout }
          r = false
          break
        end
      end
      
      r
    end
       
       
    def initialize(*args)
      @hash = {}
      super
    end
    
    def <<(post)
      return nil unless post.respond_to?(:date)
      date = post.date
      year, month, day = date.year, date.month, date.day
      
      @hash[year] ||= {}
      @hash[year][month] ||= {}
      (@hash[year][month][day] ||= []) << post
    end
  
    # @return [Hash] 
    #   The hash of data containing the posts' data under the correct keys
    #   going [year][month][date]. eg.
    #
    #     {2011 => {1 => {1 => [#<Henshin::Post @title="Happy New Year!">]}}}
    #
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
    
    # @param [Array] d
    #   for example ['2009', '12', '25'] 
    #   or ['2009', '12']
    #   or ['2009']
    #
    # @return [ArchivePage]
    #
    def page_for(d)
      pages.find {|i| i.url == "/#{d.join("/")}" }
    end
    
    # The main ArchivePage which is like the index page for labels. Usually
    # mapped to the url +/archive+
    def main_page
      t = @site.source + 'archive' + 'index.html'
      
      payload = {
        'archive' => {
          'posts' => self.to_h
        }
      }
      
      page = ArchivePage.new(t, @site)
      page.inject_payload(payload)
      page
    end
    
    # @return [Array[ArchivePage]]
    #
    def pages
      r = []
      
      r << main_page
      
      @to_h = self.to_h
      
      self.to_h.each do |y, i|
        t = @site.source + y.to_s + 'index.html'
        
        payload = {
          'archive' => {
            'posts' => @to_h,
            'year'  => y
          }
        }
        
        page = YearPage.new(t, @site)
        page.inject_payload(payload)
        r << page
      
        i.each do |m, i|
          t = @site.source + y.to_s + m.to_s + 'index.html'
          
          payload = {
            'archive' => {
              'posts' => @to_h,
              'year'  => y,
              'month' => m
            }
          }
          
          page = MonthPage.new(t, @site)
          page.inject_payload(payload)
          r << page
        
          i.each do |d, i|
            t = @site.source + y.to_s + m.to_s + d.to_s + 'index.html'
            
            payload = {
              'archive' => {
                'posts' => @to_h,
                'year'  => y,
                'month' => m,
                'day'   => d
              }
            }
            
            page = DatePage.new(t, @site)
            page.inject_payload(payload)
            r << @site.pre_render_file(page)
          end
        end
      end
      
      r
    end
    
    # Holds archives
    class ArchivePage < Henshin::File
      set :read,   false
      set :layout, true
      set :render, true
      set :write,  true
      
      def layout_names
        ['archive']
      end
    end
    
    # Holds the archives in a specific year
    class YearPage < ArchivePage
      def layout_names
        ['archive_year']
      end
    end
    
    # Holds the archives in a specific month (of a year)
    class MonthPage < ArchivePage
      def layout_names
        ['archive_month']
      end
    end
    
    # Holds the archives for a specific date (of a month, of a year)
    class DatePage < ArchivePage
      def layout_names
        ['archive_date']
      end
    end
    
  end
end