module BmcTools
  class Runnable
    class << self

      def runcmd parts
        puts "# #{parts.join(' ')}" 
        stdout, stderr, status = IO.popen parts

        # Show stderr errors if any
        stderr.read.lines.each do |line|
          puts "  STDERR: #{line.strip}" 
        end if (stderr)

        # Retourn stdout
        return stdout.read.lines.map(&:strip)
      end

    end
  end
end