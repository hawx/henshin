require 'yaml'
require 'rack/mime'
require 'clive/output'

%w(core_ext reader writer compressor tag ui engine file post template site).each do |file|
  require_relative "henshin/#{file}"
end

module Henshin
  extend self

  # @param root [Pathname]
  # @return [Site, nil]
  def build(root, opts={})
    if (root + 'config.yml').exist?
      s = Site.new(root)
      s.build
      s
    else
      UI.fail "No henshin site found, create one use `henshin new`."
      nil
    end
  end
end
