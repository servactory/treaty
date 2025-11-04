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
        {
          scopes: build_scopes_with(version.request_factory)
        }
      end

      def build_response_with(version)
        response_factory = version.response_factory
        {
          status: response_factory.status,
          scopes: build_scopes_with(response_factory)
        }
      end

      ##########################################################################

      def build_scopes_with(request_factory)
        request_factory.collection_of_scopes.to_h do |scope|
          [
            scope.name,
            build_attributes_with(scope.collection_of_attributes)
          ]
        end
      end

      ##########################################################################

      def build_attributes_with(collection, current_level = 0)
        # validate_nesting_level!(current_level)

        {
          attributes: build_attributes_hash(collection, current_level)
        }
      end

      def build_attributes_hash(collection, current_level)
        collection.to_h do |attribute|
          [
            attribute.name,
            {
              type: attribute.type,
              options: attribute.options,
              attributes: build_nested_attributes(attribute, current_level)
            }
          ]
        end
      end

      def build_nested_attributes(attribute, current_level)
        return {} unless attribute.nested?

        build_attributes_hash(attribute.collection_of_attributes, current_level + 1)
      end

      # def validate_nesting_level!(level)
      #   return unless level > Treaty::Engine.config.treaty.attribute_nesting_level
      #
      #   # TODO: It is necessary to implement a translation system (I18n).
      #   raise Treaty::Exceptions::NestedAttributes,
      #         "Nesting level #{level} exceeds maximum allowed level of " \
      #         "#{Treaty::Engine.config.treaty.attribute_nesting_level}"
      # end
    end
  end
end
