# frozen_string_literal: true

module Treaty
  module Info
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
            summary: version.summary_text,
            strategy: version.strategy_instance.code,
            deprecated: version.deprecated_result,
            executor: version.executor,
            request: build_request_with(version),
            response: build_response_with(version)
          }
        end
      end

      ##########################################################################

      def build_request_with(version)
        {
          scopes: build_request_scopes_with(version.request_factory)
        }
      end

      def build_response_with(version)
        response_factory = version.response_factory
        {
          status: response_factory.status,
          scopes: build_response_scopes_with(response_factory)
        }
      end

      ##########################################################################

      def build_request_scopes_with(request_factory)
        request_factory.collection_of_scopes.to_h do |scope|
          [
            scope.name,
            {}
          ]
        end
      end

      def build_response_scopes_with(response_factory)
        response_factory.collection_of_scopes.to_h do |scope|
          [
            scope.name,
            {}
          ]
        end
      end
    end
  end
end
