# frozen_string_literal: true

module Treaty
  module Entity
    module Attribute
      module Validation
        # Handles transformation of nested attributes (objects and arrays).
        # Extracted from Orchestrator::Base to reduce complexity.
        class NestedTransformer
          SELF_OBJECT = :_self
          private_constant :SELF_OBJECT

          attr_reader :attribute

          # Creates a new nested transformer
          #
          # @param attribute [Attribute::Base] The attribute with nested structure
          def initialize(attribute)
            @attribute = attribute
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

            transformer = ObjectTransformer.new(attribute)
            transformer.transform(value, root_data)
          end

          # Transforms array value
          #
          # @param value [Array] The array to transform
          # @param root_data [Hash] Full raw data from root level (for computed modifier)
          # @return [Array] Transformed array
          def transform_array(value, root_data = {})
            return value unless attribute.nested?

            transformer = ArrayTransformer.new(attribute)
            transformer.transform(value, root_data)
          end

          # Transforms object (hash) with nested attributes
          class ObjectTransformer
            include Concerns::ConditionalProcessing

            attr_reader :attribute

            # Creates a new object transformer
            #
            # @param attribute [Attribute::Base] The object-type attribute
            def initialize(attribute)
              @attribute = attribute
            end

            # Transforms hash by processing all nested attributes
            #
            # @param value [Hash] The source hash
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @return [Hash] Transformed hash with processed attributes
            def transform(value, root_data = {})
              transformed = {}

              attribute.collection_of_attributes.each do |nested_attribute|
                # Check if conditional (if/unless option) - skip attribute if condition evaluates to skip
                next unless should_process_attribute?(nested_attribute, value)

                process_attribute(nested_attribute, value, transformed, root_data)
              end

              transformed
            end

            private

            # Processes a single nested attribute
            # Validates, transforms, and adds to target hash
            #
            # @param nested_attribute [Attribute::Base] Attribute to process
            # @param source [Hash, Object] Source data (Hash or PORO)
            # @param target_hash [Hash] Target hash to populate
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @return [void]
            def process_attribute(nested_attribute, source, target_hash, root_data = {}) # rubocop:disable Metrics/MethodLength
              source_name = nested_attribute.name
              nested_value = ValueExtractor.extract(source, source_name)

              validator = AttributeValidator.new(nested_attribute)
              validator.validate_schema!

              transformed_value = if nested_attribute.nested?
                                    nested_transformer = NestedTransformer.new(nested_attribute)
                                    validator.validate_type!(nested_value) unless nested_value.nil?
                                    validator.validate_required!(nested_value)
                                    nested_transformer.transform(nested_value, root_data)
                                  else
                                    validator.validate_value!(nested_value)
                                    validator.transform_value(nested_value, root_data)
                                  end

              target_name = validator.target_name
              target_hash[target_name] = transformed_value
            end
          end

          # Transforms array with nested attributes
          class ArrayTransformer # rubocop:disable Metrics/ClassLength
            include Concerns::ConditionalProcessing

            SELF_OBJECT = :_self
            private_constant :SELF_OBJECT

            attr_reader :attribute

            # Creates a new array transformer
            #
            # @param attribute [Attribute::Base] The array-type attribute
            def initialize(attribute)
              @attribute = attribute
            end

            # Transforms array by processing each element
            # Handles three array types:
            # - Simple arrays (primitives like string :_self)
            # - Self-object arrays (object :_self pattern)
            # - Complex arrays (regular attributes)
            #
            # @param value [Array] The source array
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @return [Array] Transformed array
            def transform(value, root_data = {})
              value.each_with_index.map do |item, index|
                if simple_array?
                  transform_simple_element(item, index, root_data)
                elsif self_object_array?
                  transform_self_object_element(item, index, root_data)
                else
                  transform_array_item(item, index, root_data)
                end
              end
            end

            private

            # Checks if this is a simple array (primitive values)
            # Excludes object :_self which is handled separately
            #
            # @return [Boolean] True if array contains primitive values with :_self attribute
            def simple_array?
              return false unless attribute.collection_of_attributes.size == 1

              first_attr = attribute.collection_of_attributes.first
              first_attr.name == SELF_OBJECT && first_attr.type != :object
            end

            # Checks if this is a self-object array (object :_self pattern)
            #
            # @return [Boolean] True if array uses object :_self pattern
            def self_object_array?
              return false unless attribute.collection_of_attributes.size == 1

              first_attr = attribute.collection_of_attributes.first
              first_attr.name == SELF_OBJECT && first_attr.type == :object
            end

            # Transforms a self-object array element (object :_self pattern)
            #
            # @param item [Hash, Object] Array element to transform (Hash or PORO)
            # @param index [Integer] Element index for error messages
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @raise [Treaty::Exceptions::Validation] If item type doesn't match expected
            # @return [Hash] Transformed hash
            def transform_self_object_element(item, index, root_data = {}) # rubocop:disable Metrics/MethodLength
              self_object_attribute = attribute.collection_of_attributes.first
              expected_type = self_object_attribute.custom_type || Hash

              unless item.is_a?(expected_type)
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.validators.nested.array.element_type_error",
                        attribute: attribute.name,
                        index:,
                        actual: item.class
                      )
              end

              return item unless self_object_attribute.nested?

              transformed = {}

              self_object_attribute.collection_of_attributes.each do |nested_attribute|
                next unless should_process_attribute?(nested_attribute, item)

                process_self_object_attribute(nested_attribute, item, transformed, index, root_data)
              end

              transformed
            end

            # Processes a single nested attribute in self-object array element
            #
            # @param nested_attribute [Attribute::Base] Attribute to process
            # @param source [Hash, Object] Source data (Hash or PORO)
            # @param target_hash [Hash] Target hash to populate
            # @param index [Integer] Array index for error messages
            # @param root_data [Hash] Full raw data from root level (for computed modifier)
            # @raise [Treaty::Exceptions::Validation] If validation fails
            # @return [void]
            def process_self_object_attribute(nested_attribute, source, target_hash, index, root_data = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
              source_name = nested_attribute.name
              nested_value = ValueExtractor.extract(source, source_name)

              validator = AttributeValidator.new(nested_attribute)
              validator.validate_schema!

              begin
                transformed_value = if nested_attribute.nested?
                                      nested_transformer = NestedTransformer.new(nested_attribute)
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
              validator = AttributeValidator.new(self_attribute)
              validator.validate_schema!

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

              validator = AttributeValidator.new(nested_attribute)
              validator.validate_schema!

              begin
                transformed_value = if nested_attribute.nested?
                                      nested_transformer = NestedTransformer.new(nested_attribute)
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
