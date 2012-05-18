require 'clive/output'

module Henshin

  module UI
    extend self

    LEFT_MARGIN = 10

    def notify(msg, text)
      return if Henshin.quiet?

      s = ' ' * (LEFT_MARGIN - msg.clear_colours.size) + msg + '  ' + text.to_s
      s.clear_colours! unless Henshin.colour?
      puts s
    end

    def uploaded(path)
      notify 'uploaded'.green.bold, path
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
