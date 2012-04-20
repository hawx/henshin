require 'clive/output'

module Henshin

  module UI
    extend self

    LEFT_MARGIN = 10

    @quiet = false
    @colour = true

    def quiet!
      @quiet = true
    end

    def quiet?
      @quiet
    end

    def no_colour!
      @colour = false
    end

    def colour?
      @colour
    end


    def notify(msg, text)
      return if quiet?

      s = ' ' * (LEFT_MARGIN - msg.clear_colours.size) + msg + '  ' + text.to_s
      s.clear_colours! unless colour?
      puts s
    end

    def wrote(path)
      notify 'wrote'.green.bold, path
    end

    def made(dir)
      notify 'made'.grey, dir
    end

    def fail(msg)
      abort msg.red
    end

  end
end
