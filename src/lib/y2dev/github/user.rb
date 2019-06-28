module Y2Dev
  class Github
    class User
      attr_reader :github

      attr_reader :data

      def initialize(github, data)
        @github = github
        @data = data
      end

      def login
        data.login
      end

      def name
        data.name
      end

      def email
        data.email
      end
    end
  end
end
