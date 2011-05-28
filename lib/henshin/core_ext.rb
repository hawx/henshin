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
  
  def pluralize
    self.en.plural
  end
  
end

class Hash
  
  # The _why way, I hadn't seen this until here
  # http://timelessrepo.com/when-in-doubt, the most succinct 
  # implementation ever of a recursive hash merge.
  #
  def r_merge(other)
    m = proc {|_,o,n| o.respond_to?(:merge) ? o.merge(n, &m) : n }
    merge(other, &m)
  end
  
end

# @see http://www.ruby-forum.com/topic/112344
def File.binary?(path)
  return true unless File.exist?(path)
  s = read(path, 4096) and
  !s.empty? and 
  (/\0/n =~ s or s.count("\t\n -~").to_f/s.size <= 0.7)
end

class Pathname
  def binary?
    File.binary?(to_s)
  end
end