module Henshin
  
  class Archive
    
    attr_accessor :config
    
    def initialize( site )
      @archive = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = []} }}
      @site = site
      @config = site.config
    end
  
    def add_post( post )
      date = post.date
      @archive[date.year.to_s][date.month.to_s][date.day.to_s] << post.to_hash
    end
    
    # Turns the whole archive into a hash. Probably the least efficient thing in the world, but it works
    def to_hash
      if @hashed
        @hashed
      else
        @hashed = Hash.new do |h, k| 
          h[k] = Hash.new do |h, k| # years
            if k == 'posts'
              h[k] = []
            else
              h[k] = Hash.new do |h, k| # months
                if k == 'posts'
                  h[k] = []
                else
                  h[k] = Hash.new do |h, k| # days
                    if k == 'posts'
                      h[k] = []
                    else
                      h[k] = {}
                    end
                  end # /days
                end
              end # /months
            end
          end # /years
        end 
        @archive.each do |y, month|
          month.each do |m, date|
            date.each do |d, p|            
              @hashed[y]['posts'] << p
              @hashed[y][m]['posts'] << p
              @hashed[y][m][d]['posts'] << p
              
              @hashed[y]['posts'].flatten!
              @hashed[y][m]['posts'].flatten!
              @hashed[y][m][d]['posts'].flatten!
            end
          end
        end
        
      end
    end
    
    # Creates a hash with posts separated by year, month then date
    def to_date_hash
      @archive
    end
    
    # Creates a hash with posts separated by year then month
    def to_month_hash
      r = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = []} }
      @archive.each do |year, m|
        m.each do |month, d|
          d.each do |date, p|
            r[year][month] << p
            r[year][month].flatten!
          end
        end
      end
      r
    end
    
    # Creates a hash with posts separated by year
    def to_year_hash
      r = Hash.new {|h, k| h[k] = []}
      @archive.each do |year, m|
        m.each do |month, d|
          d.each do |date, p|
            r[year] << p
            r[year].flatten!
          end
        end
      end
      r
    end
    
    ##
    # Writes the archive pages
    def write
      self.write_years if @site.layouts['archive_year']
      self.write_months if @site.layouts['archive_month']
      self.write_dates if @site.layouts['archive_day']
    end
    
    def write_years
      years = self.to_year_hash
      years.each do |year, posts|
        write_path = File.join( @config[:root], @config[:target], year, 'index.html' )
        page = Gen.new( write_path, @site, years[year] )
        page.layout = @site.layouts['archive_year']
        
        page.render
        page.write
      end
    end
    
    def write_months
      months = self.to_month_hash
      months.each do |year, posts|
        posts.each do |month, posts|
          write_path = File.join( @config[:root], @config[:target], year, month, 'index.html' )
          page = Gen.new( write_path, @site, months[year][month] )
          page.layout = @site.layouts['archive_month']
          
          page.render
          page.write
        end
      end
    end
    
    def write_dates
      dates = self.to_date_hash
      dates.each do |year, posts|
        posts.each do |month, posts|
          posts.each do |date, posts|
            write_path = File.join( @config[:root], @config[:target], year, month, date, 'index.html' )
            page = Gen.new( write_path, @site, dates[year][month][date] )
            page.layout = @site.layouts['archive_date']
            
            page.render
            page.write
          end
        end
      end
    end
    
  end
end