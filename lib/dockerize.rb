module BmcTools
  class Dockerize

    def initialize
      #puts "Hello!"
      @options = {}
    end

    # Handle configuration
    def config_from_command_line argv
      # Defaults
      opt_tag       = nil
      opt_latest    = false
      opt_push      = false
      opt_list_tags = false

      # Parse options and check compliance
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $PROGRAM_NAME} [options]"
        opts.on("",   "--tags", "List all available tags")        { |value| @options[:list_tags] = true  }
        opts.on("-t",   "--tag VERSION")                          { |value| @options[:tag] = value.to_s  }
        opts.on("-l",   "--latest", "Tag build with :latest")     { |value| @options[:latest] = true     }
        opts.on("-p",   "--push",   "Push the build(s)")          { |value| @options[:push] = true  }
        opts.on_tail("-h", "--help", "Show this message")  do
          puts opts
          exit
        end

      end
      parser.order!(argv)

    rescue OptionParser::InvalidOption => e
      abort "EXITING: InvalidOption: #{e.message}"
    rescue StandardError => e
      abort "EXITING: StandardError: #{e.message}"
    end

    def check_options_tag
      # Fetch tags availability
      available_tags = Git.git_tags

      # Check tag validiy
      if available_tags.include?(@options[:tag])
        puts "TAG: found #{@options[:tag]}"
        return
      end

      # Otherwise, list tags
      if @options[:list_tags]
      elsif @options[:tag]
        puts "EXITING: the specified tag [#{@options[:tag]}] was not found"
      else
        puts "EXITING: please provide a valid tag"
      end

      # List existing tags
      puts "valid tags: #{git_tags.join(', ')}"
      exit 1
    end

    def archive_tag
      filename = archive_tag_name
      
      log "creating archive for tag [#{@options[:tag]}] into [#{filename}]"
      Git.git_archive filename, @options[:tag]

      filesize = File.size(filename)
      log "archive size is [#{filesize}] bytes"
    end

    def cmd_build temp_archive, release_name
      "docker build -f Dockerfile --build-arg CODE_ARCHIVE=\"#{temp_archive}\" . -t \"#{release_name}\""
    end

    def cmd_tag from, to
      "docker tag \"#{from}\" \"#{to}\""
    end

    private

      # def runcmd parts
      #   output = IO.popen parts
      #   return output_lines output
      # end

      def archive_tag_name
        "dockerize-archive-#{@options[:tag]}.tar"
      end

      def log message
        puts "> #{message}"
      end

  end
end