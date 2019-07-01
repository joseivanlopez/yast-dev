require "optparse"

module Y2Dev
  module Scripts
    class BumpVersion
      class Options

        attr_accessor :bug, :version, :branch

        def initialize(args)
          @args = args
          @parser = OptionParser.new

          define_options
        end

        def parse
          parser.parse!(args)
          validate

          self
        rescue OptionParser::MissingArgument => e
          exit_with_error(e.message)
        end

      private

        attr_reader :args

        attr_reader :parser

        def define_options
          banner
          bug_option
          version_option
          branch_option
          help
        end

        def banner
          parser.banner = "Usage: bump_version OPTIONS"
        end

        def bug_option
          parser.on("--bug BUG", "Bug number to include in the changelog (mandatory)") do |bug|
            self.bug = bug
          end
        end

        def version_option
          parser.on("--version VERSION", "Version number to bump to (mandatory)") do |version|
            self.version = version
          end
        end

        def branch_option
          parser.on("--branch BRANCH", "Name of the new branch (mandatory)") do |branch|
            self.branch = branch
          end
        end

        def help
          parser.on_tail("-h", "--help", "Show this message") do
            exit_with_help
          end
        end

        def validate
          mandatory = [:bug, :version, :branch]

          missing = mandatory.select { |s| send(s).nil? }

          return true if missing.none?

          raise OptionParser::MissingArgument.new(missing.map { |m| "--#{m}"}.join(", "))
        end

        def error_message(error)
          "#{parser.program_name}: #{error}\n" \
          "Try '#{parser.program_name} --help' for more information."
        end

        def exit_with_error(error)
          puts error_message(error)

          exit
        end

        def exit_with_help
          puts parser

          exit
        end
      end
    end
  end
end
