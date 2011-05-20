module Henshin

  # I'm honestly not duplicating Forwardable because I want to. I attempted to
  # use it but it broke the +@__autoloads+ array for some reason (monkeypatching FML).
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
  #
  #     delegate :class, :hello, :hey
  #
  #   end
  #   
  #   Whatever.new.hey("World") #=> "Hello, World!"
  #
  module Delegator
  
    # Set up multiple methods to be delegated to another object.
    #
    # @param sym [Symbol]
    #   Symbol of method to call, instance variable to get or class variable to
    #   get which must respond to #send. This will be called with the method.
    #
    # @param methods [Array[Symbol]]
    #   Array of method names to define as being delegated to +sym+.
    #
    def delegates(sym, *methods)
      methods.each do |method|
        delegate(sym, method, method)
      end
    end
    
    # Set up a method to be delegated to another object, you can also specify
    # a different method to be called on the receiving object.
    #
    # @param sym [Symbol]
    #   Symbol of method to call, instance variable to get or class variable to
    #   get which must respond to #send. This will be called with the method.
    #
    # @param to [Symbol]
    #   Method that will be called on +sym+.
    #
    # @param from [Symbol]
    #   Method that will be defined on the object which will then call +to+ on
    #   +sym+. Defaults to the same as +to+ if not given.
    #
    def delegate(sym, to, from=nil)
      from = to unless from
      if sym.to_s[0..1] == "@@"
        define_method(from) do |*args, &block|
          self.class.class_variable_get(sym).send(to, *args, &block)
        end
      elsif sym.to_s[0] == "@"
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
