module Henshin

  # A Factory class which abstracts away the process of creating File (subclass)
  # objects.
  #
  # File types can be registered using {.register} and then the
  # appropriate class will be used when {.create} is used. You can also add
  # functionality that is meant for broader use than a specific file type using
  # modules, these can be registered using the {.apply} method and when
  # {.create} is called the File will be extended with the correct modules.
  #
  # @example
  #
  #   class MyFileType < Henshin::File::Physical
  #     # override some methods...
  #   end
  #
  #   Henshin::File.register /\.abc\Z/, MyFileType
  #
  #   module SomeFileRole
  #     # define some methods...
  #   end
  #
  #   Henshin::File.apply %r{(^|/)special_files/}, SomeFileRole
  #
  #   file = Henshin::File.create(site, Pathname.new('special_files/test.abc')
  #
  #   file.class                                   #=> MyFileType
  #   file.singleton_class.include?(SomeFileRole)  #=> true
  #
  class File

    @types = []
    @applies = []

    # Registers a new file type which can then be used by {.create}.
    #
    # @param match [#match] Regexp path must match to be +klass+ type
    # @param klass [Class] Subclass of File
    def self.register(match, klass)
      @types.unshift [match, klass]
    end

    # Registers a module to be applied to files which have a path matching
    # +match+.
    #
    # @param match [#match] Regexp path must match to extend +mod+
    # @param mod [Module]
    def self.apply(match, mod)
      @applies.unshift [match, mod]
    end

    # Creates a new File, or if possible a subclass of File, depending on the
    # extension of the path given.
    #
    # @param site [Site]
    # @param path [Pathname]
    def self.create(site, path)
      klass = (@types.find {|k,v| k =~ path.to_s } || [nil, File::Physical]).last
      obj = klass.new(site, path)

      @applies.find_all {|k,v| k =~ path.to_s }.each {|_,v| obj.extend(v) }
      obj
    end
  end

end
