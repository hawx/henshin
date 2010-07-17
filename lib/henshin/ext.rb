class String
  
  # Turns the string to a slug
  #
  # @return [String] the created slug
  def slugify
    slug = self.clone
    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.gsub!(' ', '-')
    slug
  end
  
  # Converts the String to a Pathname object
  #  
  # @return [Pathname]
  def to_p
    Pathname.new(self)    
  end
  
  # Checks whether it is a valid number in a string, or not
  # @see http://www.railsforum.com/viewtopic.php?id=19081
  def numeric?
    true if Float(self) rescue false
  end
  
end

class Hash

  # Converts string hash keys to symbol keys
  #
  # @see http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Hash/Keys.html
  #   stolen from rails
  def to_options
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end

end

class Pathname
  
  # Gets just the extension of the pathname
  #
  # @return [String] the extension of the path, without the '.'
  def extension
    self.extname[1..-1]
  end

end