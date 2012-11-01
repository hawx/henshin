module Henshin

  # As most errors will be shown to a user of Henshin, they don't care about
  # large backtraces. Using {.prettify} limits the backtrace and displays the
  # message in an easier to read way.
  class Error

    LIMIT = 3

    # @param msg [String] Message describing the error
    # @param err [Exception] The exception raised
    # @example
    #
    #   begin
    #     # an exception is raised
    #   rescue => err
    #     Error.prettify 'Something went wrong', err
    #   end
    #
    def self.prettify(msg, err)
      puts "\n#{msg}".red.bold
      puts "  #{err.message}"
      puts err.backtrace.take(LIMIT).map {|l| "    #{l}" }.join("\n")
      exit 1
    end

  end
end
