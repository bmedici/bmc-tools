module BmcTools
  class Docker < Runner
    class << self

      def docker_build temp_archive, release_name
        "docker build -f Dockerfile --build-arg CODE_ARCHIVE=\"#{temp_archive}\" . -t \"#{release_name}\""
      end

      def docker_tag from, to
        "docker tag \"#{from}\" \"#{to}\""
      end

    end
  end
end