module Henshin

  # I'm honestly not duplicating Forwardable because I want to. I attempted to
  # use it but it broke the @__autoloads array for some reason (monkeypatching FML).
  #
  # @example
  #
  #   class Whatever
  #     extend Delegator
  #
  #     def initialize(stuff=[])
  #       @array = stuff
  #     end
  #
  #     delegates :@array, :<<, :[], :push, :shift, :pop, :unshift
  #
  #     def self.hello(name)
  #       puts "Hello, #{name}!"
  #     end
  #     delegate :class, :hello, :hey
  #   end
  #   
  #   Whatever.new.hey("World") #=> "Hello, World!"
  #
  module Delegator
    def delegates(sym, *methods)
      methods.each do |method|
        delegate(sym, method, method)
      end
    end
    
    def delegate(sym, to, from=nil)
      from = to unless from
      if sym.to_s[0] == "@"
        define_method(from) do |*args, &block|
          instance_variable_get(sym).send(to, *args, &block)
        end
      else
        define_method(from) do |*args, &block|
          send(sym).send(to, *args, &block)
        end
      end
    end
  end
end
