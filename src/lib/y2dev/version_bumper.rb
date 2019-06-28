require "y2dev/github/repository"
require "y2dev/version_bumper/spec_file"
require "y2dev/version_bumper/changes_file"

module Y2Dev
  class VersionBumper
    attr_accessor :version_number

    attr_accessor :branch_name

    attr_accessor :bug_number

    attr_reader :errors

    def initialize
      yield(self)
    end

    def bump_version(repository)
      reset

      load_repository(repository)

      execute_steps(
        :update_repository,
        :create_pull_request
      )
    end

  private

    attr_reader :repository

    attr_reader :spec_file

    attr_reader :changes_file

    COMMIT_MESSAGE = "Update version and changelog".freeze

    def reset
      @repository = nil
      @spec_file = nil
      @changes_file = nil
      @errors = []
    end

    def load_repository(repository)
      @repository = repository
      @spec_file = SpecFile.new(repository)
      @changes_file = ChangesFile.new(repository)
      @errors = spec_file_errors
    end

    def update_repository
      execute_steps(
        :create_branch,
        :update_spec_file,
        :update_changes_file,
        :create_commit
      )
    end

    def create_branch
      return if repository.create_branch(branch_name)

      @errors << "Branch cannot be created. Maybe exists yet?"
    end

    def create_commit
      repository.create_commit(COMMIT_MESSAGE)
    end

    def create_pull_request
      repository.create_pull_request("master", branch_name, pull_request_title, pull_request_body)
    end

    def spec_file_errors
      [missing_spec_file_error, version_number_error].compact
    end

    def missing_spec_file_error
      return nil if spec_file.exist?

      "Spec file cannot be found"
    end

    def version_number_error
      return nil if !spec_file.exist? || spec_file.version < version_number

      "Spec file contains a newer version: #{spec_file.version} >= #{version_number}"
    end

    def update_spec_file
      return unless spec_file.exist?

      spec_file.update_version(version_number)
    end

    def update_changes_file
      return unless changes_file.exist?

      changes_file.add_changelog(version_number, bug_number)
    end

    def pull_request_title
      "Bump version to #{version_number}"
    end

    def pull_request_body
      "This PR was automatically created.\n\n" \
      "* #{bug_number}\n"
    end

    def execute_steps(*steps)
      steps.each do |step|
        break if errors.any?
        send(step)
      end
    end
  end
end
