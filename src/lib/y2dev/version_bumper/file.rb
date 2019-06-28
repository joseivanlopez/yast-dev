module Y2Dev
  class VersionBumper
    class File
      attr_reader :repository

      def initialize(repository)
        @repository = repository
      end

      def exist?
        !file.nil?
      end

      def content
        return nil unless exist?

        file.content
      end

    private

      attr_reader :path

      # {#search_path} must be defined by derived classes
      def file
        return @file if @file && @file.branch_name == repository.branch_name

        @file = repository.file(search_path)
      end
    end
  end
end
