require "y2dev/github/repository"

module Y2Dev
  class VersionBumper
    attr_accessor :version_number

    attr_accessor :branch_name

    attr_accessor :bug_number

    def initialize
      yield(self)
    end

    def bump_version(repository)
      @repository = repository

      update_repository
      create_pull_request
    end

  private

    attr_reader :repository

    def update_repository
      create_branch

      update_spec_file
      update_changes_file

      create_commit
    end

    def create_branch
      repository.create_branch(branch_name)
    end

    def update_spec_file
      return unless spec_file

      spec_file.content = modify_version_number(spec_file.content)
    end

    def update_changes_file
      return unless changes_file

      changes_file.content = add_changelog(changes_file.content)
    end

    def spec_file
      repository.file("package/*.spec")
    end

    def changes_files
      repository.file("package/*.changes")
    end

    def modify_version_number(content)
      # TODO
    end

    def add_changelog(content)
      # TODO
    end

    COMMIT_MESSAGE = "Update version and changelog".freeze

    def create_commit
      repository.create_commit(COMMIT_MESSAGE)
    end

    def create_pull_request
      repository.create_pull_request("master", branch_name, pull_request_title, pull_request_body)
    end

    def pull_request_title
      "Bump version to #{version_number}"
    end

    def pull_request_body
      "This PR was automatically created.\n\n" \
      "* #{bug_number}\n"
    end
  end
end
