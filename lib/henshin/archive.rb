module Henshin
  
  class Archive
    
    attr_accessor :config
    def initialize( config )
      @archive = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = []} }}
      @config = config
    end
  
    def add_post( post )
      date = post.date
      @archive[date.year.to_s][date.month.to_s][date.day.to_s] << post.to_hash
    end
    
    # Turns the whole archive into a hash. Probably the least efficient thing in the world, but it works
    def to_hash
      r = Hash.new do |h, k| 
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
            r[y]['posts'] << p
            r[y][m]['posts'] << p
            r[y][m][d]['posts'] << p
            
            r[y]['posts'].flatten!
            r[y][m]['posts'].flatten!
            r[y][m][d]['posts'].flatten!
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
      self.write_years
      self.write_months
      self.write_dates
    end
    
    def write_years
      years = self.to_year_hash
      years.each do |y, posts|
        write_path = File.join( config[:root], config[:target], y, 'index.html')
      end
    end
    
    def write_months
      #months = self.to_month_hash
      #p months.size
    end
    
    def write_dates
      #dates = self.to_date_hash
      #p dates.size
    end
    
  end
end