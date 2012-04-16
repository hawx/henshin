require 'highline/import'

module Henshin

  # Publishes a site to your server.
  class Deployer

    # @param site [Site]
    # @param opts [Hash]
    def self.deploy(site, opts={})
      new(site, opts).start
    end

    # @param site [Site]
    # @param opts [Hash]
    def initialize(site, opts={})
      @site = site
    end

    def start

    end

    def get_required_opt(hsh, name)
      hsh[name] || UI.fail("Must give #{name} option to deploy.")
    end

    def get_password(hsh, name)
      if hsh.key?(name)
        val = hsh[name]
        if val =~ /^\$(\w+)\s+(.*)$/
          `#{$1} -c '#{$2}'`
        else
          val
        end
      else
        ask("Enter password: ") {|q| q.echo = false }
      end
    end

  end
end
