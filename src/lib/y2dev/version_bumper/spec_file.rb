require "y2dev/version_bumper/file"

module Y2Dev
  class VersionBumper
    class SpecFile < File
      def version
        return nil unless exist?

        matches = content.match(VERSION_REGEXP)

        matches ? matches[2] : nil
      end

      def update_version(new_version)
        return nil unless exist?

        file.content = content_with_version(new_version)
      end

    private

      SEARCH_PATH = "package/*.spec".freeze

      VERSION_REGEXP = /(^[[:blank]]*Version:[[:blank:]]*)([[[:alnum:]]\.]+)[[:blank:]]*$/.freeze

      private_constant :SEARCH_PATH, :VERSION_REGEXP

      def search_path
        SEARCH_PATH
      end

      def content_with_version(new_version)
        content.sub(VERSION_REGEXP) { $1 + new_version }
      end
    end
  end
end
