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
  # ## Options
  #
  # The `required:` option controls default required behavior for all attributes:
  #
  # ```ruby
  # UserEntity.call(data, required: true)   # strict validation (default)
  # UserEntity.call(data, required: false)  # lenient validation
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
      # Validates and transforms data according to Entity definition.
      # Returns a Result object containing processed data and any validation errors.
      #
      # @param data [Hash] Data to validate and transform
      # @param options [Hash] Options for processing
      # @option options [Boolean] :required Default required value for attributes (default: true)
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
      # @example With options
      #   result = UserEntity.call(data, required: false)  # lenient validation
      def call(data, **options)
        configuration = Entity::Configuration.new(options)
        processor = Entity::Processor.new(self, configuration)
        processor.call(data)
      end

      # Validates and transforms data, raising an exception on validation errors.
      # Returns a Result object if validation succeeds.
      #
      # @param data [Hash] Data to validate and transform
      # @param options [Hash] Options for processing
      # @option options [Boolean] :required Default required value for attributes (default: true)
      # @return [Treaty::Entity::Result] Result object with validated data
      # @raise [Treaty::Exceptions::Validation] If validation fails
      #
      # @example
      #   result = UserEntity.call!(params)
      #   UserService.create(result.to_h)
      def call!(data, **options)
        configuration = Entity::Configuration.new(options)
        processor = Entity::Processor.new(self, configuration)
        processor.call!(data)
      end

      # Predicate method that checks if data is valid according to Entity definition.
      # Does not perform transformation, only validation.
      #
      # @param data [Hash] Data to validate
      # @param options [Hash] Options for validation
      # @option options [Boolean] :required Default required value for attributes (default: true)
      # @return [Boolean] true if data is valid, false otherwise
      #
      # @example
      #   if UserEntity.valid?(params)
      #     # proceed with processing
      #   end
      def valid?(data, **options)
        call(data, **options).valid?
      end

      # Creates an anonymous Entity class from a block.
      # Useful for creating inline Entity definitions without explicit class.
      #
      # @param options [Hash] Default options for the Entity
      # @option options [Boolean] :required Default required value for attributes
      # @yield Block containing attribute definitions
      # @return [Class] Anonymous class inheriting from Treaty::Entity
      #
      # @example
      #   entity_class = Treaty::Entity.from_block(required: true) do
      #     object :user do
      #       string :name
      #     end
      #   end
      #
      #   result = entity_class.call(data)
      def from_block(**options, &block)
        Class.new(self) do
          class_eval(&block) if block_given?

          # Store default options for this anonymous Entity
          define_singleton_method(:default_options) { options }
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
