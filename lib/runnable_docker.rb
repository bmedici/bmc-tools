require_relative 'runnable'

module BmcTools
  class RunnableDocker < Runnable
    class << self

      def docker_build temp_archive, release
        runcmd ['docker', 'build', '-f', 'Dockerfile', '--build-arg', "CODE_ARCHIVE=\"#{temp_archive}\"", '-t', release, '.']
      end

      def docker_tag from, to
        runcmd ['docker', 'tag', from, to]
      end

      def docker_push release
        runcmd ['docker', 'push', release]
      end

    end
  end
end