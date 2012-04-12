require 'rack/mime'
require 'clive/output'

%w(core_ext reader writer compressor tag ui engine file post template site).each do |file|
  require_relative "henshin/#{file}"
end

module Henshin

end
