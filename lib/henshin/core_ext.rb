class Hash

  # Changes all keys to symbols, works recursively.
  #
  # @example
  #
  #   {"a" => 1, "b" => 2}.symbolise
  #   #=> {:a => 1, :b => 2}
  #
  # @return [Hash]
  def symbolise
    each_with_object({}) do |(k, v), h|
      h[k.to_sym] = (v.respond_to?(:symbolise) ? v.symbolise : v)
    end
  end

  # Merges the hash given with this hash but deeply.
  #
  # @example
  #
  #   a = {:person => {:name => "John", :age => 30}}
  #   b = {:person => {:age => 31, :job => "Dummy"}}
  #
  #   a.merge(b)
  #   #=> {:person => {:age => 31, :job => "Dummy"}}
  #
  #   a.deep_merge(b)
  #   #=> {:person => {:name => "John", :age => 31, :job => "Dummy"}}
  #
  # @param other [Hash]
  # @see http://timelessrepo.com/when-in-doubt
  def deep_merge(other)
    m = proc {|_,o,n| o.respond_to?(:merge) ? o.merge(n, &m) : n }
    merge(other, &m)
  end
end

class Pathname

  # Same as #ascend but works in the opposite direction.
  #
  # @example
  #
  #   Pathname.new('/home/public/blog').descend do |dir|
  #     puts dir
  #   end
  #   #=> #<Pathname:/>
  #   #   #<Pathname:/home>
  #   #   #<Pathname:/home/public>
  #   #   #<Pathname:/home/public/blog>
  #
  def descend
    arr = []
    ascend {|p| arr << p }
    until arr.empty?
      yield arr.pop
    end
  end
end

class String

  # Converts the string to a format suitable for use as a url.
  #
  # @example
  #
  #   "Hey, Wait! I've got this string.".slugify
  #   #=> "hey-wait-ive-got-this-string"
  #
  # @return [String]
  def slugify
    gsub(/[']+/, '').
      gsub(/\W+/, ' ').
      strip.
      downcase.
      gsub(' ', '-')
  end
end
