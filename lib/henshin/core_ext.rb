# This is where I am going to put the monkey patches. Try to keep them to a minimum!



# +Kernel.autoload+ will not load gems, so I have had to find a way around it.
# The solution below is modified (slightly) from the sources below.
#
# Note the method to call is +autoloads+ with an s, I may change it to +autoload_gem+
# in the future, it's more descriptive of the task it does.
#
# @see http://www.germanforblack.com/articles/ruby-autoload
# @see https://gist.github.com/324367
#

class << Object
  alias_method :_const_missing, :const_missing
  private :_const_missing
  
  def const_missing(const)
    if path = Kernel._autoloads[const]
      require path
      const_get(const)
    else
      _const_missing(const)
    end
  end
end

module Kernel

  def _autoloads
    @@_autoloads || {}
  end

  def autoload_gem(const, path)
    (@@_autoloads ||= {})[const] = path
  end

end


# Make a plain string into a slug, usable on the web.

class String

  # Turns the string to a slug
  #
  # @return [String] the created slug
  #
  def slugify
    slug = self.clone
    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.gsub!(' ', '-')
    slug
  end
  
end