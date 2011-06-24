module Henshin

  class File::Text < File
  
   # @group Predicates
    
    set :read,   true
    set :render, true
    set :write,  true

    def layoutable?
      @layoutable.nil? ? has_yaml? : @layoutable
    end
  
    # @return [true, false] Whether the file contains YAML frontmatter.
    def has_yaml?
      if readable?
        @path.read(3) == "---"
      else
        false
      end
    rescue
      false
    end
    
    # @return [String]
    #   The yaml frontmatter of the file.
    #
    def yaml_text
      if has_yaml?
        file = @path.read
        file =~ /^(---\s*\n.*?\n?^---\s*$\n?)/m
        $1 ? file[0..$1.size-1] : ""
      else
        ""
      end
    end

    # @return [Hash]
    #   The parsed yaml frontmatter of the file.
    #
    def yaml
      YAML.load(self.yaml_text) || {}
    end
    inject_data :yaml
    
  # @group Attributes
      
    # @return [String]
    #   The content of the file. If the file has content set, because it
    #   has been rendered, then this is returned. Otherwise returns the
    #   #raw_content.
    #
    def content
      @content || raw_content
    end

    attribute :raw_content
  
    # @return [String] The unrendered file contents.
    def raw_content
      if readable?
        if has_yaml?
          @path.read[yaml_text.size..-1]
        else
          @path.read
        end
      else
        ""
      end
    end
  
  end
end