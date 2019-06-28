require "y2dev/version_bumper/file"

module Y2Dev
  class VersionBumper
    class ChangesFile < File
      def add_changelog(version_number, bug_number)
        file.content = changelog_entry(version_number, bug_number) + content
      end

    private

      SEARCH_PATH = "package/*.changes".freeze

      private_constant :SEARCH_PATH

      def search_path
        SEARCH_PATH
      end

      def changelog_entry(version_number, bug_number)
        "-------------------------------------------------------------------\n" \
        "#{time_stamp} - #{user_data}\n\n" \
        "- Bump version (#{bug_number}).\n" \
        "- #{version_number}\n\n"
      end

      def time_stamp
        Time.now.utc.strftime("%a %b %e %T %Z %Y")
      end

      def user_data
        "#{user.name} <#{user.email}>"
      end

      def user
        repository.github.user
      end
    end
  end
end
