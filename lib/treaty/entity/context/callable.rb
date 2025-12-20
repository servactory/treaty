# frozen_string_literal: true

module Treaty
  class Entity
    module Context
      # Provides class methods for Entity entry point.
      # Creates an instance and delegates to internal processing methods.
      #
      # ## API Design
      #
      # Public API (without preset:):
      # - call(arguments) -> Result
      # - call!(arguments) -> Result or raises
      # - valid?(arguments) -> Boolean
      # - preset(**options) -> Preset
      # - from_block(&block) -> Class
      #
      # Private API (with preset:):
      # - _process(arguments, preset:) -> Result (catches exceptions)
      # - _process!(arguments, preset:) -> Result (raises exceptions)
      # - _call!(entity_instance, incoming_arguments:, preset:) -> delegates to instance
      #
      # ## Why preset: is private
      #
      # If Entity has an attribute named `preset`, having `preset:` in public API
      # would create confusion. The preset mechanism is internal:
      # - User calls: Entity.preset(required: false).call(data)
      # - Preset delegates to: entity_class.send(:_process, data, preset: self)
      #
      # Follows the Treaty::Context::Callable pattern.
      module Callable
        # Returns a Preset wrapper with pre-configured options.
        # Preset delegates to private _process/_process! methods.
        def preset(**options)
          Entity::Preset.new(self, **options)
        end

        # Validates and transforms data, catching validation errors.
        # @param arguments [Hash] Data to validate (default: {})
        # @return [Entity::Result] Result object (always valid or with errors)
        def call(arguments = {})
          _process(arguments, preset: nil)
        end

        # Validates and transforms data, raising on errors.
        # @param arguments [Hash] Data to validate (default: {})
        # @return [Entity::Result] Result object
        # @raise [Treaty::Exceptions::Validation] If validation fails
        def call!(arguments = {})
          _process!(arguments, preset: nil)
        end

        # Checks if data is valid.
        # @param arguments [Hash] Data to validate (default: {})
        # @return [Boolean] True if valid
        def valid?(arguments = {})
          call(arguments).valid?
        end

        # Creates anonymous Entity class from block.
        # @yield Block with attribute definitions
        # @return [Class] Anonymous Entity subclass
        def from_block(&block)
          Class.new(self) do
            class_eval(&block) if block_given?
          end
        end

        private

        # Internal processing with exception handling.
        # Called by: call() and Preset#call()
        # @param arguments [Hash] Data to validate
        # @param preset [Preset, nil] Preset with options
        # @return [Entity::Result] Result object
        def _process(arguments, preset:)
          _process!(arguments, preset:)
        rescue Treaty::Exceptions::Validation => e
          result = Entity::Result.new
          result.errors.add(:base, e.message)
          result
        end

        # Internal processing that raises on errors.
        # Called by: call!(), _process(), and Preset#call!()
        # @param arguments [Hash] Data to validate
        # @param preset [Preset, nil] Preset with options
        # @return [Entity::Result] Result object
        # @raise [Treaty::Exceptions::Validation] If validation fails
        def _process!(arguments, preset:)
          entity_instance = send(:new)
          _call!(entity_instance, incoming_arguments: arguments, preset:)
        end

        # Delegates to instance method.
        # @param entity_instance [Entity] The entity instance
        # @param incoming_arguments [Hash] Data to validate
        # @param preset [Preset, nil] Preset with options
        # @return [Entity::Result] Result object
        def _call!(entity_instance, incoming_arguments:, preset:)
          entity_instance.send(:_call!, incoming_arguments:, preset:)
        end

        # Factory method for creating Entity attributes.
        # Called by Attribute::DSL when defining attributes.
        def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
          Attribute::Entity::Attribute.new(
            name, type, *helpers, nesting_level:, **options, &block
          )
        end
      end
    end
  end
end
