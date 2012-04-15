class Hash
  def symbolise
    each_with_object({}) do |(k, v), h|
      h[k.to_sym] = (v.respond_to?(:symbolise) ? v.symbolise : v)
    end
  end
end

class String
  def slugify
    gsub(/[']+/, '').
      gsub(/\W+/, ' ').
      strip.
      downcase.
      gsub(' ', '-')
  end
end
