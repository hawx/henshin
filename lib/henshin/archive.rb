module Henshin

  class Archive < Hash
    
    attr_accessor :site
    
    # Create a new instance of Archive
    def initialize(site)
      @site = site
    end
    
    # Adds the post to the correct year array, month array and day array within the archive
    #
    # @param [Post] post to be added to the archive
    def <<(post)
      return nil unless post.data['date']
      date = post.data['date']
      year, month, day = date.year.to_s, date.month.to_s, date.day.to_s
      
      self[year] ||= {}
      self[year]['posts'] ||= []
      self[year]['year'] = year
      self[year]['posts'] << post
      
      self[year][month] ||= {}
      self[year][month]['posts'] ||= []
      self[year][month]['month'] = month
      self[year][month]['posts'] << post
      
      self[year][month][day] ||= {}
      self[year][month][day]['posts'] ||= []
      self[year][month][day]['day'] = day
      self[year][month][day]['posts'] << post
    end
    
    # Converts the archive to a hash suitable for putting in a layout by 
    # calling #to_hash for all of the posts it contains
    #
    # @return [Hash]
    def to_hash
      return @hashed if @hashed
      @hashed = self.dup
      self.each {|y, i|
        @hashed[y]['posts'] = i['posts'].collect {|p| p.to_hash}
        i.each {|m, i|
          if i.is_a? Hash
            @hashed[y][m]['posts'] = i['posts'].collect {|p| p.to_hash}
            i.each {|d, i|
              if i.is_a? Hash
                @hashed[y][m][d]['posts'] = i['posts'].collect {|p| p.to_hash}
              end
            }
          end
        }
      }
    end
    
    # Writes the archives if the correct layouts are present
    def write
      self.write_years if @site.layouts['archive_year']
      self.write_months if @site.layouts['archive_month']
      self.write_dates if @site.layouts['archive_date']
    end
    
    # This writes all the archives for years
    def write_years
      self.to_hash.each do |year, v|
        # need to fake the file loc so that gen automatically creates permalink
        t = @site.root + year + 'index.html'
        time = Time.parse("#{year}/01/01")
        payload = {:name => 'archive', :payload => {'date' => time, 'posts' => self.to_hash} }
        page = Gen.new(t, @site, payload)
        page.read
        page.data['layout'] = @site.layouts['archive_year']
        
        page.render
        page.write
      end
    end
    
    # Writes all of the archives for the months
    def write_months
      self.to_hash.each do |year, v|
        v.each do |month, v|
          if month.numeric?
            t = @site.root + year + month + 'index.html'
            time = Time.parse("#{year}/#{month}/01")
            payload = {:name => 'archive', :payload => {'date' => time, 'posts' => self.to_hash} }
            page = Gen.new(t, @site, payload)
            page.read
            page.data['layout'] = @site.layouts['archive_month']
            
            page.render
            page.write
          end
        end
      end
    end
    
    # Writes all of the archives for the days
    def write_dates
      self.to_hash.each do |year, v|
        v.each do |month, v|
          if month.numeric?
            v.each do |date, v|
              if date.numeric?
                t = @site.root + year + month + date + 'index.html'
                time = Time.parse("#{year}/#{month}/#{date}")
                payload = {:name => 'archive', :payload => {'date' => time, 'posts' => self.to_hash} }
                page = Gen.new(t, @site, payload)
                page.read 
                page.data['layout'] = @site.layouts['archive_date']
                
                page.render
                page.write
              end
            end
          end
        end
      end
    end
    
  end
end