require 'henshin/plugin'

class TestPlugin < Henshin::StandardPlugin

  def initialize
    # p 'Test plugin loaded'
    @extensions = []
    @config = {}
  end

end