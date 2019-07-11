require_relative 'runnable'

module BmcTools
  class RunnableGit < Runnable
    class << self

      def git_archive temp_archive, tag
        runcmd ['git', 'archive', '--format=tar', '--prefix=/', tag, '-o', temp_archive]
      end

      def git_tags
        runcmd ['git', 'tag']
      end

    end
  end
end