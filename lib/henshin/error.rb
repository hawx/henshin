module Henshin

  class Error

    LIMIT = 3

    def self.prettify(msg, err)
      puts "\n#{msg}".red.bold
      puts "  #{err.message}"
      puts err.backtrace.take(LIMIT).map {|l| "    #{l}" }.join("\n")
      exit 1
    end

  end
end
