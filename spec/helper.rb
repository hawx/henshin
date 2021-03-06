$: << File.dirname(__FILE__) + '/..'

begin
  # require 'duvet'
  # Duvet.start :filter => 'lib/henshin'
rescue LoadError => e
  # Doesn't matter if duvet doesn't run
  # warn 'Problem with duvet?'
  # raise e
end

gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'

require 'mocha'

require 'lib/henshin'

Henshin.set :dry_run

def with_writing!
  Henshin.unset :dry_run
  yield
  Henshin.set :dry_run
end

def with_profiling!
  Henshin.set :profile
  yield
  Henshin.unset :profile
end


class DummySite < Henshin::Site
  def config
    {}
  end
end

def test_path
  Pathname.new(__FILE__).dirname + '..' + 'site'
end

def test_site
  Henshin::Site.new test_path
end


# For some reason, must_be and wont_be don't work properly using MiniTest 3.0.0.
module MiniTest::Expectations

  alias_method :_must_be, :must_be
  alias_method :_wont_be, :wont_be

  def must_be(*args)
    if args.size == 1
      self.send(args.first).must_equal true
    else
      _must_be *args
    end
  end

  def wont_be(*args)
    if args.size == 1
      self.send(args.first).must_equal false
    else
      _wont_be *args
    end
  end

end
