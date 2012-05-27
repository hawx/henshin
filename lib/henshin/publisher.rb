require 'highline/import'

module Henshin

  # Publishes a site to your server.
  class Publisher

    # @return [#write]
    def self.create(opts={})

    end

    # Checks that +hash+ contains all keys in +list+, raises error if not.
    #
    # @param hash [Hash]
    # @param list [Array]
    def self.requires_keys(hash, list)
      list.each do |key|
        unless hash.key?(key)
          UI.fail "Publish hash must contain :#{name} key."
        end
      end
      true
    end

    def self.get_required_opt(hsh, name)
      hsh[name] || UI.fail("Must give :#{name} option to publish.")
    end

    def self.get_password(hsh, name)
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
