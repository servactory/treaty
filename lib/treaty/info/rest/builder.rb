# frozen_string_literal: true

module Treaty
  module Info
    module Rest
      class Builder
        attr_reader :versions

        def self.build(...)
          new.build(...)
        end

        def build(collection_of_versions:)
          build_all(
            versions: collection_of_versions
          )

          self
        end

        private

        def build_all(versions:)
          build_versions_with(
            collection: versions
          )
        end

        ##########################################################################

        def build_versions_with(collection:) # rubocop:disable Metrics/MethodLength
          @versions = collection.map do |version|
            gem_version = version.version.version
            {
              version: gem_version.version,
              segments: gem_version.segments,
              default: version.default_result,
              summary: version.summary_text,
              deprecated: version.deprecated_result,
              executor: build_executor_with(version),
              request: build_request_with(version),
              response: build_response_with(version)
            }
          end
        end

        ##########################################################################

        def build_executor_with(version)
          {
            executor: version.executor.executor,
            method: version.executor.method
          }
        end

        ##########################################################################

        def build_request_with(version)
          version.request_factory.info
        end

        def build_response_with(version)
          response_factory = version.response_factory
          {
            status: response_factory.status
          }.merge(response_factory.info)
        end
      end
    end
  end
end
