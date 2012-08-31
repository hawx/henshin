module Henshin

  # Allows a class to mark methods as "unsafe", using {.unsafe}. A copy of an
  # object can then ask for a "safe" version with these methods disabled using
  # {#safe}.
  module Safety

    module ClassMethods

      # Mark a list of methods as "unsafe".
      #
      # @param syms [Symbol]
      # @example
      #
      #   unsafe :write
      #
      def unsafe(*syms)
        @unsafe_methods += syms
      end

      # Makes sure that the Safety module, and any unsafe methods that have been
      # marked, infect any class which inherits the original class.
      def inherited(klass)
        super
        klass.send :include, ::Henshin::Safety
        klass.instance_variable_set(:@unsafe_methods, @unsafe_methods)
      end
    end

    # Mixes {ClassMethods} into the including class.
    def self.included(base)
      super
      base.extend ClassMethods
      base.instance_variable_set(:@unsafe_methods, [])
    end

    # @return [Array<Symbol>] List of methods marked unsafe.
    def unsafe_methods
      self.class.instance_variable_get(:@unsafe_methods)
    end

    # @return A cloned version of the object with unsafe methods stubbed to
    #   return +nil+.
    #
    # @example
    #
    #   class Test
    #     include Safety
    #
    #     def unsafe_method; puts "Hello"; end
    #     unsafe :unsafe_method
    #   end
    #
    #   Test.new.unsafe_method       #=> "Hello"
    #   Test.new.safe.unsafe_method  #=> nil
    #
    def safe
      return @safe_clone if @safe_clone

      @safe_clone = self.clone
      unsafe_methods.each do |sym|
        (class << @safe_clone; self; end).send(:define_method, sym) {|*| nil }
      end
      @safe_clone
    end

  end
end
