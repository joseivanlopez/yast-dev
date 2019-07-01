require "y2dev/scripts/bump_version/options"
require "y2dev/github"
require "y2dev/version_bumper"

module Y2Dev
  module Scripts
    class BumpVersion
      def self.run(args)
        new(args).run
      end

      def initialize(args)
        @args = args
      end

      def run
        parse_options

        say("Loggin into GitHub ...")
        github = Github.login

        say("Fetching repositories ...")
        github.repositories(ORGANIZATION).each { |r| bump_version(r) }

        say("[end]")
      end

    private

      attr_reader :args

      ORGANIZATION = "yast".freeze

      def bump_version(repository)
        say("Bumping repository: #{repository.full_name}")

        pr_url = bumper.bump_version(repository)

        say_errors

        pr_url
      end

      def bumper
        @bumper ||= VersionBumper.new do |config|
          config.version_number = options.version
          config.bug_number = options.bug
          config.branch_name = options.branch
        end
      end

      def options
        parse_options unless @options

        @options
      end

      def parse_options
        @options = Options.new(args)
        @options.parse
      end

      def say_errors
        return if bumper.errors.none?

        say(bumper.errors)
        say("Version cannot be bumped!")
      end

      def say(message)
        message = message.join("\n") if message.is_a?(Array)

        puts(message)
      end
    end
  end
end
