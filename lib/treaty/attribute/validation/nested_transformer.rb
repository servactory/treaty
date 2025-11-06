# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      # Handles transformation of nested attributes (objects and arrays).
      # Extracted from Orchestrator::Base to reduce complexity.
      class NestedTransformer
        SELF_SCOPE = :_self
        private_constant :SELF_SCOPE

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
        # @return [Object] Transformed value
        def transform(value)
          return value if value.nil?

          case attribute.type
          when :object
            transform_object(value)
          when :array
            transform_array(value)
          else
            value
          end
        end

        private

        # Transforms object (hash) value
        #
        # @param value [Hash] The hash to transform
        # @return [Hash] Transformed hash
        def transform_object(value)
          return value unless attribute.nested?

          transformer = ObjectTransformer.new(attribute)
          transformer.transform(value)
        end

        # Transforms array value
        #
        # @param value [Array] The array to transform
        # @return [Array] Transformed array
        def transform_array(value)
          return value unless attribute.nested?

          transformer = ArrayTransformer.new(attribute)
          transformer.transform(value)
        end

        # Transforms object (hash) with nested attributes
        class ObjectTransformer
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
          # @return [Hash] Transformed hash with processed attributes
          def transform(value)
            transformed = {}

            attribute.collection_of_attributes.each do |nested_attribute|
              process_attribute(nested_attribute, value, transformed)
            end

            transformed
          end

          private

          # Processes a single nested attribute
          # Validates, transforms, and adds to target hash
          #
          # @param nested_attribute [Attribute::Base] Attribute to process
          # @param source_hash [Hash] Source data
          # @param target_hash [Hash] Target hash to populate
          # @return [void]
          def process_attribute(nested_attribute, source_hash, target_hash) # rubocop:disable Metrics/MethodLength
            source_name = nested_attribute.name
            nested_value = source_hash.fetch(source_name, nil)

            validator = AttributeValidator.new(nested_attribute)
            validator.validate_schema!

            transformed_value = if nested_attribute.nested?
                                  nested_transformer = NestedTransformer.new(nested_attribute)
                                  validator.validate_type!(nested_value) unless nested_value.nil?
                                  validator.validate_required!(nested_value)
                                  nested_transformer.transform(nested_value)
                                else
                                  validator.validate_value!(nested_value)
                                  validator.transform_value(nested_value)
                                end

            target_name = validator.target_name
            target_hash[target_name] = transformed_value
          end
        end

        # Transforms array with nested attributes
        class ArrayTransformer
          SELF_SCOPE = :_self
          private_constant :SELF_SCOPE

          attr_reader :attribute

          # Creates a new array transformer
          #
          # @param attribute [Attribute::Base] The array-type attribute
          def initialize(attribute)
            @attribute = attribute
          end

          # Transforms array by processing each element
          # Handles both simple arrays (:_self) and complex arrays (objects)
          #
          # @param value [Array] The source array
          # @return [Array] Transformed array
          def transform(value)
            value.each_with_index.map do |item, index|
              if simple_array?
                validate_simple_element(item, index)
                item
              else
                transform_array_item(item, index)
              end
            end
          end

          private

          # Checks if this is a simple array (primitive values)
          #
          # @return [Boolean] True if array contains primitive values with :_self scope
          def simple_array?
            attribute.collection_of_attributes.size == 1 &&
              attribute.collection_of_attributes.first.name == SELF_SCOPE
          end

          # Validates a simple array element (primitive value)
          #
          # @param item [Object] Array element to validate
          # @param index [Integer] Element index for error messages
          # @raise [Treaty::Exceptions::Validation] If validation fails
          # @return [void]
          def validate_simple_element(item, index) # rubocop:disable Metrics/MethodLength
            self_attr = attribute.collection_of_attributes.first
            validator = AttributeValidator.new(self_attr)
            validator.validate_schema!

            begin
              validator.validate_value!(item)
            rescue Treaty::Exceptions::Validation => e
              raise Treaty::Exceptions::Validation,
                    I18n.t("treaty.nested.array.element_validation_error",
                           attribute: attribute.name,
                           index: index,
                           errors: e.message)
            end
          end

          # Transforms a complex array element (hash object)
          #
          # @param item [Hash] Array element to transform
          # @param index [Integer] Element index for error messages
          # @raise [Treaty::Exceptions::Validation] If item is not a Hash
          # @return [Hash] Transformed hash
          def transform_array_item(item, index)
            unless item.is_a?(Hash)
              raise Treaty::Exceptions::Validation,
                    I18n.t("treaty.nested.array.element_type_error",
                           attribute: attribute.name,
                           index: index,
                           actual: item.class)
            end

            transformed = {}

            attribute.collection_of_attributes.each do |nested_attribute|
              process_attribute(nested_attribute, item, transformed, index)
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
          # @raise [Treaty::Exceptions::Validation] If validation fails
          # @return [void]
          def process_attribute(nested_attribute, source_hash, target_hash, index) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            source_name = nested_attribute.name
            nested_value = source_hash.fetch(source_name, nil)

            validator = AttributeValidator.new(nested_attribute)
            validator.validate_schema!

            begin
              transformed_value = if nested_attribute.nested?
                                    nested_transformer = NestedTransformer.new(nested_attribute)
                                    validator.validate_type!(nested_value) unless nested_value.nil?
                                    validator.validate_required!(nested_value)
                                    nested_transformer.transform(nested_value)
                                  else
                                    validator.validate_value!(nested_value)
                                    validator.transform_value(nested_value)
                                  end
            rescue Treaty::Exceptions::Validation => e
              raise Treaty::Exceptions::Validation,
                    I18n.t("treaty.nested.array.attribute_error",
                           attribute: attribute.name,
                           index: index,
                           message: e.message)
            end

            target_name = validator.target_name
            target_hash[target_name] = transformed_value
          end
        end
      end
    end
  end
end
