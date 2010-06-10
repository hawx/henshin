require 'thread'

module Enumerable
  
  # Like an each loop but runs each task in parallel
  # Which will probably be very useful for writing and rendering
  # from http://t-a-w.blogspot.com/2010/05/very-simple-parallelization-with-ruby.html
  def each_parallel( n=10 )
    todo = Queue.new
    ts = (1..n).map do
      Thread.new do 
        while x = todo.deq
          Exception.ignoring_exceptions { yield(x[0]) }
        end
      end
    end
    each {|x| todo << [x] }
    n.times { todo << nil }
    ts.each {|t| t.join }
  end
  
end

def Exception.ignoring_exceptions
  begin
    yield
  rescue Exception => e
    STDERR.puts e.message
  end
end


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
  
  # Capitalizes the string using Gruber's guidelines
  def titlize
    self
  end
  
  # Gets the extension from a string
  def extension
    parts = self.split('.')
    if parts.size == 2
      return parts[1]
    elsif parts.size == 3
      return parts[2]
    end
  end
  
  # Gets the directory from a string
  def directory
    self =~ /((\.?\/?[a-zA-Z0-9 _-]+\/)+)/
    $1
  end
  
  # Gets the filename from a string
  def file_name
    self.dup.gsub(/([a-zA-Z0-9_-]+\/)/, '')
  end
  
end