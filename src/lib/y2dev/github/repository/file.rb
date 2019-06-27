module Y2Dev
  class Github
    class Repository
      class File
        attr_reader :repository

        attr_reader :path

        attr_reader :branch_name

        attr_reader :data

        def initialize(repository, path)
          @repository = repository
          @path = path
          @branch_name = repository.branch_name
          @data = fetch
        end

        def content
          modified? ? new_content : original_content
        end

        def content=(new_content)
          @new_content = new_content
        end

        def modified?
          !new_content.nil?
        end

      private

        attr_reader :new_content

        def original_content
          encoded? ? decode_content : data.content
        end

        def encoded?
          data.encoding == "base64"
        end

        def decode_content
          Base64.decode64(data.content)
        end

        def fetch
          repository.github.client.contents(repository.full_name, path: path, ref: branch_name)
        end
      end
    end
  end
end
