# frozen_string_literal: true

module Treaty
  # Base class for defining DTO (Data Transfer Object) entities in Treaty.
  #
  # ## Purpose
  #
  # Treaty::Entity provides a base class for creating reusable DTO classes
  # that can be used in both request and response definitions. This allows
  # for better code organization and reusability of common data structures.
  #
  # ## Standalone Usage
  #
  # Entity classes can be used independently for data validation and transformation:
  #
  # ```ruby
  # class UserEntity < Treaty::Entity
  #   object :user do
  #     string :name
  #     string :email, format: :email
  #   end
  # end
  #
  # # Validate and transform data
  # result = UserEntity.call(params)
  # result.valid?     # => true/false
  # result.data       # => { user: { name: "John", email: "john@test.com" } }
  # result.errors     # => Errors collection
  #
  # # With exception on validation errors
  # result = UserEntity.call!(params)  # raises Treaty::Exceptions::Validation
  #
  # # Check validity only (predicate)
  # UserEntity.valid?(params)  # => true/false
  # ```
  #
  # ## Options via .preset()
  #
  # Use `.preset()` method to configure validation behavior. This approach
  # avoids name conflicts between attribute names and option names:
  #
  # ```ruby
  # # With options
  # UserEntity.preset(required: false).call(data)  # lenient validation
  # UserEntity.preset(required: false, default: "N/A").call(data)  # multiple options
  #
  # # Reuse preset
  # preset = UserEntity.preset(required: false)
  # result1 = preset.call(data1)
  # result2 = preset.call(data2)
  #
  # # No conflict with attribute names!
  # class PaymentEntity < Treaty::Entity
  #   object :payment do
  #     boolean :required  # Attribute named "required" - OK!
  #   end
  # end
  # PaymentEntity.preset(required: false).call({ payment: { required: true } })
  # ```
  #
  # ## Usage with Treaty Class
  #
  # Entity classes can also be used in Treaty definitions:
  #
  # ```ruby
  # class CreateTreaty < ApplicationTreaty
  #   version 1 do
  #     request PostEntity
  #     response 201, PostEntity
  #   end
  # end
  # ```
  #
  # ## Attribute Defaults
  #
  # Unlike request/response blocks, Entity attributes are required by default:
  # - All attributes have `required: true` unless explicitly marked as `:optional`
  # - Use `:optional` helper to make attributes optional:
  #   ```ruby
  #   string :title           # required by default
  #   string :summary, :optional  # optional
  #   ```
  #
  # ## Features
  #
  # - **Type Safety** - Enforce strict type checking for all attributes
  # - **Nested Structures** - Support for nested objects and arrays
  # - **Validation** - Built-in validation for all attribute types
  # - **Reusability** - Define once, use in multiple treaties
  # - **Options** - Full support for attribute options (required, default, as, etc.)
  #
  # ## Supported Types
  #
  # - `string` - String values
  # - `integer` - Integer values
  # - `boolean` - Boolean values (true/false)
  # - `datetime` - DateTime values
  # - `array` - Array values (with nested type definition)
  # - `object` - Object values (with nested attributes)
  class Entity
    include Info::Entity::DSL
    include Attribute::DSL

    class << self
      # Creates a Preset wrapper with pre-configured options.
      # Use this to configure validation behavior without conflicting
      # with attribute names.
      #
      # @param options [Hash] Configuration options to apply
      # @return [Treaty::Entity::Preset] Preset wrapper with options
      #
      # @example Single option
      #   preset = UserEntity.preset(required: false)
      #   result = preset.call(data)
      #
      # @example Multiple options
      #   preset = UserEntity.preset(required: false, default: "N/A")
      #   result = preset.call(data)
      #
      # @example Reusable preset
      #   preset = UserEntity.preset(required: false)
      #   result1 = preset.call(data1)
      #   result2 = preset.call(data2)
      def preset(**options)
        Entity::Preset.new(self, options)
      end

      # Validates and transforms data according to Entity definition.
      # Returns a Result object containing processed data and any validation errors.
      #
      # @param data [Hash] Data to validate and transform
      # @return [Treaty::Entity::Result] Result object with data and errors
      #
      # @example Basic usage
      #   result = UserEntity.call(params)
      #   if result.valid?
      #     UserService.create(result.to_h)
      #   else
      #     render json: { errors: result.errors.to_h }, status: 422
      #   end
      #
      # @example With options (use .preset() method)
      #   result = UserEntity.preset(required: false).call(data)
      def call(data)
        processor = Entity::Processor.new(self, nil)
        processor.call(data)
      end

      # Validates and transforms data, raising an exception on validation errors.
      # Returns a Result object if validation succeeds.
      #
      # @param data [Hash] Data to validate and transform
      # @return [Treaty::Entity::Result] Result object with validated data
      # @raise [Treaty::Exceptions::Validation] If validation fails
      #
      # @example
      #   result = UserEntity.call!(params)
      #   UserService.create(result.to_h)
      #
      # @example With options (use .preset() method)
      #   result = UserEntity.preset(required: false).call!(data)
      def call!(data)
        processor = Entity::Processor.new(self, nil)
        processor.call!(data)
      end

      # Predicate method that checks if data is valid according to Entity definition.
      # Does not perform transformation, only validation.
      #
      # @param data [Hash] Data to validate
      # @return [Boolean] true if data is valid, false otherwise
      #
      # @example
      #   if UserEntity.valid?(params)
      #     # proceed with processing
      #   end
      #
      # @example With options (use .preset() method)
      #   UserEntity.preset(required: false).valid?(params)
      def valid?(data)
        call(data).valid?
      end

      # Creates an anonymous Entity class from a block.
      # Useful for creating inline Entity definitions without explicit class.
      #
      # @yield Block containing attribute definitions
      # @return [Class] Anonymous class inheriting from Treaty::Entity
      #
      # @example
      #   entity_class = Treaty::Entity.from_block do
      #     object :user do
      #       string :name
      #     end
      #   end
      #
      #   result = entity_class.call(data)
      #
      # @example With options
      #   entity_class = Treaty::Entity.from_block do
      #     object :user do
      #       string :name
      #     end
      #   end
      #   result = entity_class.preset(required: false).call(data)
      def from_block(&block)
        Class.new(self) do
          class_eval(&block) if block_given?
        end
      end

      private

      # Creates an Attribute::Entity::Attribute for this Entity class
      #
      # @return [Attribute::Entity::Attribute] Created attribute instance
      def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
        Attribute::Entity::Attribute.new(
          name,
          type,
          *helpers,
          nesting_level:,
          **options,
          &block
        )
      end
    end
  end
end
