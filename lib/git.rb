module BmcTools
  class Git < Runner
    class << self

      def git_archive temp_archive, tag
        runcmd ['git', 'archive', '--format=tar', '-o', temp_archive, '--prefix=/', tag]
      end

      def git_tags
        runcmd ['git', 'tag']
      end

    end
  end
end