# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      # Validates nested object (hash) attributes against their defined structure.
      #
      # ## Purpose
      #
      # Performs validation for nested object attributes during the validation phase.
      # Ensures hash values conform to the nested attribute definitions.
      #
      # ## Responsibilities
      #
      # 1. **Structure Validation** - Validates hash structure matches definition
      # 2. **Attribute Validation** - Validates each nested attribute's value
      # 3. **Type Safety** - Ensures value is a Hash before validation
      # 4. **Validator Caching** - Builds and caches validators for performance
      #
      # ## Usage
      #
      # Used for object-type attributes with nested definitions:
      #
      # ```ruby
      # object :author do
      #   string :name, :required
      #   string :email
      #   integer :age
      # end
      # ```
      #
      # Validates: `{ name: "Alice", email: "alice@example.com", age: 30 }`
      #
      # ## Usage in Code
      #
      # Called by AttributeValidator for nested objects:
      #
      #   validator = NestedObjectValidator.new(attribute)
      #   validator.validate!(hash_value)
      #
      # ## Validation Flow
      #
      # 1. Check if value is a Hash
      # 2. Build validators for all nested attributes (cached)
      # 3. For each nested attribute:
      #    - Extract value from hash
      #    - Validate using AttributeValidator
      # 4. Raise exception if any validation fails
      #
      # ## Architecture
      #
      # Uses:
      # - `AttributeValidator` - Validates individual nested attributes
      # - Caches validators to avoid rebuilding on each validation
      class NestedObjectValidator
        attr_reader :attribute

        # Creates a new nested object validator
        #
        # @param attribute [Attribute::Base] The object-type attribute with nested attributes
        def initialize(attribute)
          @attribute = attribute
          @validators_cache = nil
        end

        # Validates all nested attributes in a hash
        # Skips validation if value is not a Hash
        #
        # @param hash [Hash] The hash to validate
        # @raise [Treaty::Exceptions::Validation] If any nested validation fails
        # @return [void]
        def validate!(hash)
          return unless hash.is_a?(Hash)

          validators.each do |nested_attribute, nested_validator|
            nested_value = hash.fetch(nested_attribute.name, nil)
            nested_validator.validate_value!(nested_value)
          end
        end

        private

        # Gets cached validators or builds them
        #
        # @return [Hash] Hash of nested_attribute => validator
        def validators
          @validators ||= build_validators
        end

        # Builds validators for all nested attributes
        #
        # @return [Hash] Hash of nested_attribute => validator
        def build_validators
          attribute.collection_of_attributes.each_with_object({}) do |nested_attribute, cache|
            validator = AttributeValidator.new(nested_attribute)
            validator.validate_schema!
            cache[nested_attribute] = validator
          end
        end
      end
    end
  end
end
