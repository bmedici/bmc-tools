module Helpers
  class Runner
    class << self

      def runcmd parts
        output = IO.popen parts
        return output_lines output
      end

      def runcmd_old command, title
        puts "* #{title}"
        puts command
        system command
        puts
      end

    end
  end
end