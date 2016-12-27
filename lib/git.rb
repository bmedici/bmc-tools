module Helpers
  class Git < Runner
    class << self

      def cmd_archive temp_archive, opt_tag
       "git archive --format=tar -o \"#{temp_archive}\" --prefix=/ #{opt_tag}"
      end

      def fetch_tags
        runcmd ['git', 'tag']
      end

      def list_tags tags
        puts "Valid tags are:"
        tags.each.map { |tag| puts "- #{tag}" }
      end


    end
  end
end