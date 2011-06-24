class Henshin::Base
  def rules_for(file)
    rules.find_all do |m,b|
      m.matches?(file.relative_path.to_s)
    end
  end
end

class Henshin::File

  # In tests if subject is set to a file use:
  #
  #   it { should have_applied :maruku }
  #   it { should have_applied Henshin::Engine::Haml }
  #
  def has_applied?(engine)
    c = FileContext.new(self)
    rules = @site.rules_for(self)
    rules.each {|i| c.run(i) }
    
    if engine.respond_to?(:new)
      c._applied.include?(engine)
    else
      c._applied.include?(Henshin.registered_engines[engine])
    end
  end

  # In tests if subject is set to a file use:
  #
  #   it { should have_set_title_to 'New iPad' }
  #   it { should have_set_category_to 'tech' }
  #
  def method_missing(sym, *args)
    if sym.to_s =~ /has_set_(\w+)_to?/
      key = $1
      c = FileContext.new(self)
      rules = @site.rules_for(self)
      rules.each {|i| c.run(i) }
      c._set[key.to_sym] == args[0]
    else
      super
    end
  end
end

class FileContext
  def initialize(file)
    @file    = file
    @stuff   = {}
    @set     = {}
    @applied = []
    @site    = file.instance_variable_get(:@site)
  end

  def set(k, v)
    @set[k] = v
  end
  
  def apply(k)
    if k.respond_to?(:new)
      @applied << k
    else
      @applied << Henshin.registered_engines[k]
    end
  end
  
  def _set
    @set
  end
  
  def _applied
    @applied
  end
  
  def run(a)
    @stuff = a[0].matches(@file.relative_path.to_s)
    instance_exec &a[1]
  end
  
  def method_missing(sym, *args)
    if @stuff.has_key?(sym.to_s)
      @stuff[sym.to_s]
    else
      super
    end
  end
end
