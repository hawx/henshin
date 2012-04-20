module Henshin

  class Error

    def self.prettify(msg, err)
      puts "\n#{msg}".red.bold
      puts "  #{err.backtrace.shift}"
      puts e.backtrace.take(3).map {|l| "    #{l}" }.join("\n")
      exit 1
    end

  end
end
