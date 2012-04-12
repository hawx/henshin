require 'rack/mime'

%w(core_ext file site).each do |file|
  require_relative "henshin/#{file}"
end

module Henshin

end
