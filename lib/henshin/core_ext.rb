class Hash
  def symbolise
    each_with_object({}) {|(k, v), h| h[k.to_sym] = v }
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
