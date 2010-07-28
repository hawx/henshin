module Henshin
  
  # This should really be a hash which just holds post objects, when #to_hash is
  # called, each post object held is turned has Post#to_hash called and this is
  # returned. It also controls writing of the archive pages.
  #   
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
      year, month, day = date.year, date.month, date.day
      
      self[year] ||= {}
      self[year][month] ||= {}
      self[year][month][day] ||= []
      self[year][month][day] << post
    end
    
    # Converts the archive to a hash suitable for putting in a layout by 
    # calling #to_hash for all of the posts it contains
    #
    # @return [Hash]
    def to_hash
      r = {}
      self.each do |y, i|
        r[y] = {}
        i.each do |m, i|
          r[y][m] = {}
         i.each do |d, i|
           r[y][m][d] = []
           i.each do |j|
             r[y][m][d] << j.to_hash
           end
         end
        end
      end
      
      r
    end
    
    # Writes the archives if the correct layouts are present
    def write
      self.write_years  if @site.layouts.include?('archive_year')
      self.write_months if @site.layouts.include?('archive_month')
      self.write_dates  if @site.layouts.include?('archive_date')
    end
    
    # This writes all the archives for years
    def write_years
      self.to_hash.each do |year, v|
        # need to fake the file loc so that gen automatically creates permalink
        t = @site.root + year.to_s + 'index.html'

        payload = {
          :name => 'archive', 
          :payload => {
            'posts' => self.to_hash,
            'year' => year
          }
        }
        page = Gen.new(t, @site, payload)
        
        page.data['layout'] = 'archive_year'
        page.get_layout
        
        page.render
        page.write
      end
    end
    
    # Writes all of the archives for the months
    def write_months
      self.to_hash.each do |year, v|
        v.each do |month, v|          
          t = @site.root + year.to_s + month.to_s + 'index.html'

          payload = {
            :name => 'archive', 
            :payload => {
              'posts' => self.to_hash,
              'year' => year,
              'month' => month
            }
          }
          page = Gen.new(t, @site, payload)
          
          page.data['layout'] = 'archive_month'
          page.get_layout
          
          page.render
          page.write
        end
      end
    end
    
    # Writes all of the archives for the days
    def write_dates
      self.to_hash.each do |year, v|
        v.each do |month, v|
          v.each do |date, v|
            t = @site.root + year.to_s + month.to_s + date.to_s + 'index.html'
            
            payload = {
              :name => 'archive', 
              :payload => {
                'posts' => self.to_hash,
                'year' => year,
                'month' => month,
                'day' => date
              }
            }
            page = Gen.new(t, @site, payload)
            
            page.data['layout'] = 'archive_date'
            page.get_layout
            
            page.render
            page.write
          end
        end
      end
    end
    
  end
end