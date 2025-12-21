# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Validation
        # Handles transformation of nested attributes (objects and arrays).
        # Extracted from Orchestrator::Base to reduce complexity.
        class NestedTransformer
          SELF_OBJECT = :_self
          private_constant :SELF_OBJECT

          attr_reader :attribute, :preset, :validator_cache

          # Creates a new nested transformer
          #
          # @param attribute [Attribute::Base] The attribute with nested structure
          # @param preset [Treaty::Entity::Context::Preset, nil] Preset with default options
          # @param validator_cache [ValidatorCache, nil] Shared validator cache for performance
          def initialize(attribute, preset: nil, validator_cache: nil)
            @attribute = attribute
            @preset = preset
            @validator_cache = validator_cache || ValidatorCache.new
          end

          # Transforms nested attribute value (object or array)
          # Returns original value if nil or not nested
          #
          # @param value [Object] The value to transform
          # @param root_data [Hash] Full raw data from root level (for computed modifier)
          # @return [Object] Transformed value
          def transform(value, root_data = {})
            return value if value.nil?

            case attribute.type
            when :object
              transform_object(value, root_data)
            when :array
              transform_array(value, root_data)
            else
              value
            end
          end

          private

          # Transforms object (hash) value
          #
          # @param value [Hash] The hash to transform
          # @param root_data [Hash] Full raw data from root level (for computed modifier)
          # @return [Hash] Transformed hash
          def transform_object(value, root_data = {})
            return value unless attribute.nested?

            transformer = ObjectTransformer.new(attribute, preset:, validator_cache:)
            transformer.transform(value, root_data)
          end

          # Transforms array value
          #
          # @param value [Array] The array to transform
          # @param root_data [Hash] Full raw data from root level (for computed modifier)
          # @return [Array] Transformed array
          def transform_array(value, root_data = {})
            return value unless attribute.nested?

            transformer = ArrayTransformer.new(attribute, preset:, validator_cache:)
            transformer.transform(value, root_data)
          end

          # Transforms object (hash) with nested attributes
          class ObjectTransformer
            include Concerns::ConditionalSupport

            attr_reader :attribute, :preset, :validator_cache

            # Creates a new object transformer
            #
            # @param attribute [Attribute::Base] The object-type attribute
            # @param preset [Treaty::Entity::Context::Preset, nil] Preset with default options
            # @param validator_cache [ValidatorCache, nil] Shared validator cache for performance
            def initialize(attribute, preset: nil, validator_cache: nil)
              @attribute = attribute
              @preset = preset
              @validator_cache = validator_cache || ValidatorCache.new
              @current_source_hash = nil
            end

            # Transforms hash by processing all nested attributes
            #
            # @param value [Hash] The source hash
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @return [Hash] Transformed hash with processed attributes
            def transform(value, root_data = {})
              transformed = {}
              @current_source_hash = value

              attribute.collection_of_attributes.each do |nested_attribute|
                # Check if conditional (if/unless option) - skip attribute if condition evaluates to skip
                next unless should_process_attribute?(nested_attribute, value)

                process_attribute(nested_attribute, value, transformed, root_data)
              end

              transformed
            end

            private

            # Returns cached conditional processors (implements ConditionalSupport interface)
            #
            # @return [Hash] Hash of attribute => conditional processor
            def conditionals_cache
              @conditionals_cache ||= build_conditionals_cache(attribute.collection_of_attributes)
            end

            # Wraps source data with parent attribute name for conditional evaluation
            # (implements ConditionalSupport interface)
            #
            # @param source_data [Hash] Source hash from transform
            # @return [Hash] Wrapped data for conditional evaluation
            def conditional_evaluation_data(source_data)
              data = source_data || @current_source_hash
              { attribute.name => data }
            end

            # Processes a single nested attribute
            # Validates, transforms, and adds to target hash
            #
            # @param nested_attribute [Attribute::Base] Attribute to process
            # @param source_hash [Hash] Source data
            # @param target_hash [Hash] Target hash to populate
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @return [void]
            def process_attribute(nested_attribute, source_hash, target_hash, root_data = {})
              nested_value = source_hash.fetch(nested_attribute.name, nil)
              # Use cached validator (schema already validated on first access)
              validator = validator_cache.fetch(nested_attribute, preset:)

              transformed_value = validate_and_transform(nested_attribute, nested_value, validator, root_data)
              target_hash[validator.target_name] = transformed_value
            end

            # Validates and transforms attribute value
            #
            # @param nested_attribute [Attribute::Base] Attribute to process
            # @param value [Object] Value to validate and transform
            # @param validator [AttributeValidator] Validator instance
            # @param root_data [Hash] Full raw data from root level
            # @return [Object] Transformed value
            def validate_and_transform(nested_attribute, value, validator, root_data)
              if nested_attribute.nested?
                validator.validate_type!(value) unless value.nil?
                validator.validate_required!(value)
                # Pass validator cache for deep nesting performance
                NestedTransformer.new(nested_attribute, preset:, validator_cache:).transform(value, root_data)
              else
                validator.validate_value!(value)
                validator.transform_value(value, root_data)
              end
            end
          end

          # Transforms array with nested attributes
          class ArrayTransformer
            include Concerns::ConditionalSupport

            SELF_OBJECT = :_self
            private_constant :SELF_OBJECT

            attr_reader :attribute, :preset, :validator_cache

            # Creates a new array transformer
            #
            # @param attribute [Attribute::Base] The array-type attribute
            # @param preset [Treaty::Entity::Context::Preset, nil] Preset with default options
            # @param validator_cache [ValidatorCache, nil] Shared validator cache for performance
            def initialize(attribute, preset: nil, validator_cache: nil)
              @attribute = attribute
              @preset = preset
              @validator_cache = validator_cache || ValidatorCache.new
              @current_source_hash = nil
            end

            # Transforms array by processing each element
            # Handles both simple arrays (:_self) and complex arrays (objects)
            #
            # @param value [Array] The source array
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @return [Array] Transformed array
            def transform(value, root_data = {})
              value.each_with_index.map do |item, index|
                if simple_array?
                  transform_simple_element(item, index, root_data)
                else
                  transform_array_item(item, index, root_data)
                end
              end
            end

            private

            # Returns cached conditional processors (implements ConditionalSupport interface)
            #
            # @return [Hash] Hash of attribute => conditional processor
            def conditionals_cache
              @conditionals_cache ||= build_conditionals_cache(attribute.collection_of_attributes)
            end

            # Wraps source data with parent attribute name for conditional evaluation
            # (implements ConditionalSupport interface)
            #
            # @param source_data [Hash] Source hash from transform_array_item
            # @return [Hash] Wrapped data for conditional evaluation
            def conditional_evaluation_data(source_data)
              data = source_data || @current_source_hash
              { attribute.name => data }
            end

            # Checks if this is a simple array (primitive values)
            #
            # @return [Boolean] True if array contains primitive values with :_self attribute
            def simple_array?
              attribute.collection_of_attributes.size == 1 &&
                attribute.collection_of_attributes.first.name == SELF_OBJECT
            end

            # Transforms a simple array element (primitive value)
            # Validates and applies transformations to the element
            #
            # @param item [Object] Array element to transform
            # @param index [Integer] Element index for error messages
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @raise [Treaty::Exceptions::Validation] If validation fails
            # @return [Object] Transformed element value
            def transform_simple_element(item, index, root_data = {}) # rubocop:disable Metrics/MethodLength
              self_attribute = attribute.collection_of_attributes.first
              # Use cached validator (schema already validated on first access)
              validator = validator_cache.fetch(self_attribute, preset:)

              begin
                validator.validate_value!(item)
                validator.transform_value(item, root_data)
              rescue Treaty::Exceptions::Validation => e
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.validators.nested.array.element_validation_error",
                        attribute: attribute.name,
                        index:,
                        errors: e.message
                      )
              end
            end

            # Transforms a complex array element (hash object)
            #
            # @param item [Hash] Array element to transform
            # @param index [Integer] Element index for error messages
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @raise [Treaty::Exceptions::Validation] If item is not a Hash
            # @return [Hash] Transformed hash
            def transform_array_item(item, index, root_data = {}) # rubocop:disable Metrics/MethodLength
              unless item.is_a?(Hash)
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.validators.nested.array.element_type_error",
                        attribute: attribute.name,
                        index:,
                        actual: item.class
                      )
              end

              transformed = {}
              @current_source_hash = item

              attribute.collection_of_attributes.each do |nested_attribute|
                # Check if conditional (if/unless option) - skip attribute if condition evaluates to skip
                next unless should_process_attribute?(nested_attribute, item)

                process_attribute(nested_attribute, item, transformed, index, root_data)
              end

              transformed
            end

            # Processes a single nested attribute in array element
            # Validates, transforms, and adds to target hash
            #
            # @param nested_attribute [Attribute::Base] Attribute to process
            # @param source_hash [Hash] Source data
            # @param target_hash [Hash] Target hash to populate
            # @param index [Integer] Array index for error messages
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @raise [Treaty::Exceptions::Validation] If validation fails
            # @return [void]
            def process_attribute(nested_attribute, source_hash, target_hash, index, root_data = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
              source_name = nested_attribute.name
              nested_value = source_hash.fetch(source_name, nil)

              # Use cached validator (schema already validated on first access)
              validator = validator_cache.fetch(nested_attribute, preset:)

              begin
                transformed_value = if nested_attribute.nested?
                                      # Pass validator cache for deep nesting performance
                                      nested_transformer = NestedTransformer.new(nested_attribute, preset:,
                                                                                                   validator_cache:)
                                      validator.validate_type!(nested_value) unless nested_value.nil?
                                      validator.validate_required!(nested_value)
                                      nested_transformer.transform(nested_value, root_data)
                                    else
                                      validator.validate_value!(nested_value)
                                      validator.transform_value(nested_value, root_data)
                                    end
              rescue Treaty::Exceptions::Validation => e
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.validators.nested.array.attribute_error",
                        attribute: attribute.name,
                        index:,
                        message: e.message
                      )
              end

              target_name = validator.target_name
              target_hash[target_name] = transformed_value
            end
          end
        end
      end
    end
  end
end
