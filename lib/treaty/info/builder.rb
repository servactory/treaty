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
            default: version.default_result,
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
        build_attributes_structure(version.request_factory)
      end

      def build_response_with(version)
        response_factory = version.response_factory
        {
          status: response_factory.status
        }.merge(build_attributes_structure(response_factory))
      end

      ##########################################################################

      def build_attributes_structure(factory)
        {
          attributes: build_attributes_hash(factory.collection_of_attributes)
        }
      end

      def build_attributes_hash(collection, current_level = 0)
        # validate_nesting_level!(current_level)

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
      #   raise Treaty::Exceptions::NestedAttributes,
      #         I18n.t("treaty.attributes.errors.nesting_level_exceeded",
      #                level:,
      #                max_level: Treaty::Engine.config.treaty.attribute_nesting_level)
      # end
    end
  end
end
