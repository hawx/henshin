require 'highline/import'

module Henshin

  # Publishes a site to your server.
  class Publisher

    # @param site [Site]
    # @param opts [Hash]
    def self.publish(site, opts={})
      new(opts).start(site.all_files)
    end

    # @param site [Site]
    # @param opts [Hash]
    def initialize(site, opts={})
      @site = site
    end

    def start
      # ...
    end

    # Checks that +hash+ contains all keys in +list+, raises error if not.
    #
    # @param hash [Hash]
    # @param list [Array]
    def requires_keys(hash, list)
      list.each do |key|
        unless hash.key?(key)
          UI.fail "Publish hash must contain :#{name} key."
        end
      end
    end

    def get_required_opt(hsh, name)
      hsh[name] || UI.fail("Must give :#{name} option to publish.")
    end

    def get_password(hsh, name)
      if hsh.key?(name)
        val = hsh[name]
        if val =~ /^\$(\w+)\s+(.*)$/
          `#{$1} -c '#{$2}'`.chomp
        else
          val
        end
      else
        ask("Enter password: ") {|q| q.echo = false }
      end
    end

  end
end
