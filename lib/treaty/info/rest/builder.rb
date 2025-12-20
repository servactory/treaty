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
          build_attributes_structure(version.request_factory)
        end

        def build_response_with(version)
          response_factory = version.response_factory
          preset = build_preset_for(response_factory)
          {
            status: response_factory.status
          }.merge(build_attributes_structure(response_factory, preset:))
        end

        ##########################################################################

        def build_attributes_structure(factory, preset: nil)
          {
            attributes: build_attributes_hash(factory.collection_of_attributes, preset:)
          }
        end

        def build_attributes_hash(collection, current_level = 0, preset: nil)
          # validate_nesting_level!(current_level)

          collection.to_h do |attribute|
            [
              attribute.name,
              {
                type: attribute.type,
                options: compute_effective_options(attribute, preset),
                attributes: build_nested_attributes(attribute, current_level, preset:)
              }
            ]
          end
        end

        def build_nested_attributes(attribute, current_level, preset: nil)
          return {} unless attribute.nested?

          build_attributes_hash(attribute.collection_of_attributes, current_level + 1, preset:)
        end

        # Builds preset from factory if it has preset_options
        #
        # @param factory [Request::Factory, Response::Factory] The factory
        # @return [Entity::Context::Preset, nil] Preset instance or nil
        def build_preset_for(factory)
          return nil unless factory.respond_to?(:preset_options)
          return nil unless factory.entity_class

          preset_options = factory.preset_options
          return nil if preset_options.nil? || preset_options.empty?

          Treaty::Entity::Context::Preset.new(factory.entity_class, **preset_options)
        end

        # Computes effective options by applying preset
        #
        # @param attribute [Attribute::Base] The attribute
        # @param preset [Entity::Context::Preset, nil] Preset to apply
        # @return [Hash] Effective options
        def compute_effective_options(attribute, preset)
          return attribute.options if preset.nil?

          preset.merge_with(attribute.options, attribute.explicit_options)
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
end
