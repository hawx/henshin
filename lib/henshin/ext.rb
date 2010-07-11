class Hash

  # stripped straight out of rails
  # converts string keys to symbol keys
  # from http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Hash/Keys.html
  def to_options
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
  
end

class String
  
  # Turns the string to a slug
  def slugify
    slug = self.clone
    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.gsub!(' ', '-')
    slug
  end
  
  # Converts the String to Pathname object
  #  
  # @return [Pathname]
  def to_p
    Pathname.new(self)    
  end
  
  # Checks whether it is a valid number in a string, or not
  #  from http://www.railsforum.com/viewtopic.php?id=19081
  def numeric?
    true if Float(self) rescue false
  end
  
end