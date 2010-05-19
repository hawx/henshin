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
  
  # Gets the extension from a string
  def extension
    self.split('.')[1]
  end
  
  # Gets the directory from a string
  def directory
    self =~ /((\/?[a-zA-Z0-9 _-]+\/)+)/
    $1
  end
  
  # Gets the filename from a string
  def file_name
    self.dup.gsub(/([a-zA-Z0-9_-]+\/)/, '')
  end
  
end