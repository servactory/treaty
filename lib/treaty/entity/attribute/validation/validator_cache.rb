# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Validation
        # Cache for AttributeValidator instances within a single validation call.
        #
        # ## Purpose
        #
        # Eliminates redundant validator instantiation and schema validation
        # in nested transformers. Instead of creating a new AttributeValidator
        # for every nested attribute on every array element, the cache reuses
        # validated instances.
        #
        # ## Performance Impact
        #
        # Before: 100 array items x 5 attributes = 500 validator instances + 500 schema validations
        # After: 5 validator instances (one per unique attribute), each validated once
        #
        # ## Usage
        #
        # ```ruby
        # cache = ValidatorCache.new
        # validator = cache.fetch(attribute, preset: preset)
        # validator.validate_value!(value)
        # ```
        #
        # ## Scope
        #
        # This cache is created per validation call and is NOT shared across requests.
        # Each NestedTransformer creates its own cache instance.
        class ValidatorCache
          def initialize
            @cache = {}
          end

          # Fetches or creates a validator for the given attribute
          #
          # @param attribute [Attribute::Base] The attribute to validate
          # @param preset [Treaty::Entity::Context::Preset, nil] Preset with default options
          # @return [AttributeValidator] Cached or newly created validator
          def fetch(attribute, preset: nil)
            key = cache_key(attribute, preset)

            @cache[key] ||= build_validator(attribute, preset)
          end

          # Returns the target name for an attribute (used for output key naming)
          #
          # @param attribute [Attribute::Base] The attribute
          # @param preset [Treaty::Entity::Context::Preset, nil] Preset with default options
          # @return [Symbol] The target attribute name (may be renamed via :as option)
          def target_name_for(attribute, preset: nil)
            fetch(attribute, preset:).target_name
          end

          # Clears the cache (primarily for testing)
          #
          # @return [void]
          def clear!
            @cache.clear
          end

          # Returns the number of cached validators
          #
          # @return [Integer] Cache size
          def size
            @cache.size
          end

          private

          # Builds and validates a new validator instance
          #
          # @param attribute [Attribute::Base] The attribute to validate
          # @param preset [Treaty::Entity::Context::Preset, nil] Preset with default options
          # @return [AttributeValidator] New validated validator
          def build_validator(attribute, preset)
            validator = AttributeValidator.new(attribute, preset:)
            validator.validate_schema!
            validator
          end

          # Generates a unique cache key for attribute + preset combination
          #
          # @param attribute [Attribute::Base] The attribute
          # @param preset [Treaty::Entity::Context::Preset, nil] The preset
          # @return [Array] Unique cache key
          def cache_key(attribute, preset)
            [attribute.object_id, preset&.object_id]
          end
        end
      end
    end
  end
end
