require "optparse"

require_relative "runnable_git"
require_relative "runnable_docker"


module BmcTools
  class Dockerizer

    def initialize
      #puts "Hello!"
      @options = {
        list_tags:  false,
        tag:        nil,
        latest:     false,
        push:       false,
        }
      @prefix = "bmconseil"

      # Read local config
      read_gemspec

      # Config from command line
      config_from_command_line(ARGV)

      # Check options tag
      check_options_tag

      # Compute release
      @release = release_name(@options[:tag])
      @latest = @options[:latest] ? release_name(:latest) : nil

      # Config summary
      puts
      puts "--- DOCKERIZE CONFIG ---"
      puts "Project name       #{@app_name}"
      puts "Git tag            #{@options[:tag]}"
      puts "Docker prefix      #{@prefix}"
      puts "Docker release     #{@release}"
      puts "Docker latest      #{@latest ? @latest : "-"}"
      puts "Docker push        #{@options[:push] ? "YES" : "-"}"
      puts
    end

    # Handle configuration
    def config_from_command_line argv
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $PROGRAM_NAME} [options]"
        opts.on("",   "--tags", "List all available tags")        { |value| @options[:list_tags] = true     }
        opts.on("-t",   "--tag VERSION")                          { |value| @options[:tag] = value.to_s     }
        opts.on("-l",   "--latest", "Tag build with :latest")     { |value| @options[:latest] = true        }
        opts.on("-p",   "--push",   "Push the build(s)")          { |value| @options[:push] = true          }
        opts.on("-p",   "--github",   "From Github repository")   { |value| @options[:github] = value.to_s  }
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
      available_tags = RunnableGit.git_tags

      # Check tag validiy
      return if available_tags.include?(@options[:tag])

      # Otherwise, list tags
      if @options[:list_tags]
      elsif @options[:tag]
        puts "EXITING: the specified tag [#{@options[:tag]}] was not found"
      else
        puts "EXITING: please provide a valid tag"
      end

      # List existing tags
      puts "valid tags: #{available_tags.join(', ')}"
      # available_tags.each do |tag|
      #   puts "- #{tag}"
      # end
      exit 1
    end

    def build
      # Build archive
      archive = temp_file_name()
      log "create archive for tag [#{@options[:tag]}] into [#{File.basename(archive)}]"
      RunnableGit.git_archive archive, @options[:tag]

      # Build image
      log "build Docker release [#{@release}]"
      RunnableDocker.docker_build archive, @release

      # Remove temp file
      log "remove temp archive"
      File.delete archive

      # Skip if no latest release to handle
      return unless @latest

      # Make alias to latest
      log "alias release [#{@release}] to [#{@latest}]"
      RunnableDocker.docker_tag @release, @latest
    end

    def push
      # Push the main release
      return unless @options[:push]
      log "push release [#{@release}]"
      RunnableDocker.docker_push @release

      # Skip if no latest release to handle
      return unless @latest
      log "push latest [#{@latest}]"
      RunnableDocker.docker_push @latest
    end

  private

    def read_gemspec
      # Try to find any gemspec file
      gemspecs   = Dir["./*.gemspec"]

      if gemspecs.size < 1
        abort "GEMSPEC: cannot find any gemspec in current directory"
      elsif gemspecs.size > 1
        abort "GEMSPEC: multiple gemspecs found, cannot continue: #{gemspecs.join(', ')}"
      end

      # Load Gemspec (just the only match)
      first = gemspecs.pop
      gemspec = Gem::Specification::load(first)
      abort "GEMSPEC: cannot read gemsepc [#{first}" unless gemspec

      # Extract useful information from gemspec
      @app_name = gemspec.name.to_s
      @app_ver  = gemspec.version.to_s
      abort "GEMSPEC: cannot get app name" unless @app_name

      # Report some info
      #log "gemspec: detected app name [#{@app_name}]"
    end

    def temp_file_name
      return "/tmp/dockerize-#{@app_name}-#{@options[:tag]}.tar"
      tempfile = Tempfile.new("dockerize-#{@app_name}-")
      filename = tempfile.path
      tempfile.close
      return filename
    end

    def release_name tag
      return "#{@prefix}/#{@app_name}:#{tag}"
    end

    def log message
      puts
      puts "> #{message}"
    end

  end
end