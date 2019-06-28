require "base64"
require "y2dev/github/repository/file"

module Y2Dev
  class Github
    class Repository
      attr_reader :github

      attr_reader :data

      attr_reader :branch_name

      def initialize(github, data)
        @github = github
        @data = data
        @branch_name = "master"
        @files = []
      end

      def name
        data.name
      end

      def full_name
        data.full_name
      end

      def file(glob)
        find_file(glob) || retrieve_file(glob)
      end

      def switch_branch(branch_name)
        reset_branch

        @branch_name = branch_name
      end

      def create_branch(branch_name)
        github.client.create_ref(full_name, "heads/#{branch_name}", branch.commit.sha)

        switch_branch(branch_name)
        true
      rescue Octokit::UnprocessableEntity
        false
      end

      def create_commit(message)
        tree = prepare_files

        commit = github.client.create_commit(full_name, message, tree.sha, branch.commit.sha)

        github.client.update_branch(full_name, branch_name, commit.sha)

        reset_branch
      end

      def create_pull_request(base, head, title, body)
        pull_request = github.client.create_pull_request(full_name, base, head, title, body)

        pull_request.html_url
      end

    private

      attr_reader :files

      def find_file(path)
        files.find { |f| f.path == path && f.branch_name == branch_name }
      end

      def retrieve_file(glob)
        path = find_path(glob)

        return nil unless path

        find_file(path) || fetch_file(path)
      end

      def fetch_file(path)
        file = Repository::File.new(self, path)
        files << file

        file
      end

      def find_path(glob)
        paths = directory_paths(::File.dirname(glob))

        paths.find { |f| ::File.fnmatch(glob, f) }
      end

      def directory_paths(directory)
        github.client.contents(full_name, ref: branch_name, path: directory).map(&:path)
      rescue Octokit::NotFound
        []
      end

      def branch
        @branch ||= github.client.branch(full_name, branch_name)
      end

      def reset_branch
        @branch = nil
      end

      def modified_files
        files.select { |f| f.modified? && f.branch_name == branch_name }
      end

      def prepare_files
        tree_entries = modified_files.map { |f| prepare_file(f) }

        github.client.create_tree(full_name, tree_entries, base_tree: branch.commit.sha)
      end

      def prepare_file(file)
        blob = github.client.create_blob(full_name, file.content)

        { path: file.path, mode: "100644", type: "blob", sha: blob }
      end
    end
  end
end
