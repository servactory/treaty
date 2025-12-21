# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Option
        # Central registry for all option processors (validators, modifiers, and conditionals).
        #
        # ## Purpose
        #
        # Provides a centralized registry pattern for managing all option processors.
        # Enables dynamic discovery and extensibility of the option system.
        #
        # ## Responsibilities
        #
        # 1. **Registration** - Stores option processor classes
        # 2. **Retrieval** - Provides access to registered processors
        # 3. **Categorization** - Organizes processors by category (validator/modifier/conditional)
        # 4. **Validation** - Checks if options are registered
        #
        # ## Registered Options
        #
        # ### Validators (sorted by position)
        # - `:type` → TypeValidator (position: 100)
        # - `:required` → RequiredValidator (position: 200)
        # - `:inclusion` → InclusionValidator (position: 300)
        # - `:format` → FormatValidator (position: 400)
        #
        # ### Modifiers (sorted by position)
        # - `:transform` → TransformModifier (position: 500)
        # - `:cast` → CastModifier (position: 600)
        # - `:computed` → ComputedModifier (position: 700)
        # - `:default` → DefaultModifier (position: 800)
        # - `:as` → AsModifier (position: 900)
        #
        # ### Conditionals (no position - handled separately)
        # - `:if` → IfConditional
        # - `:unless` → UnlessConditional
        #
        # ## Usage
        #
        # Registration (done in RegistryInitializer):
        #   Registry.register(:required, RequiredValidator, category: :validator, position: 200)
        #   Registry.register(:if, IfConditional, category: :conditional)
        #
        # Retrieval (done in OptionOrchestrator):
        #   processor_class = Registry.processor_for(:required)
        #   processor = processor_class.new(...)
        #
        # ## Extensibility
        #
        # To add a new option:
        # 1. Create processor class inheriting from Option::Base
        # 2. Register it: `Registry.register(:my_option, MyProcessor, category: :validator)`
        # 3. Option becomes available in DSL immediately
        #
        # ## Architecture
        #
        # Works with:
        # - RegistryInitializer - Populates registry with built-in options
        # - OptionOrchestrator - Uses registry to build processors
        # - Option::Base - Base class for all registered processors
        class Registry
          class << self
            # Register an option processor
            #
            # @param option_name [Symbol] The name of the option (e.g., :required, :as, :default)
            # @param processor_class [Class] The processor class
            # @param category [Symbol] The category (:validator, :modifier, or :conditional)
            # @param position [Integer, nil] Execution order position (nil for conditionals)
            def register(option_name, processor_class, category:, position: nil)
              registry[option_name] = {
                processor_class:,
                category:,
                position:
              }
            end

            # Get processor class for an option
            #
            # @param option_name [Symbol] The name of the option
            # @return [Class, nil] The processor class or nil if not found
            def processor_for(option_name)
              registry.dig(option_name, :processor_class)
            end

            # Get category for an option
            #
            # @param option_name [Symbol] The name of the option
            # @return [Symbol, nil] The category (:validator or :modifier) or nil if not found
            def category_for(option_name)
              registry.dig(option_name, :category)
            end

            # Get position for an option (uses cache for O(1) lookup)
            #
            # @param option_name [Symbol] The name of the option
            # @return [Integer] The execution order position or 0 if not set
            def position_for(option_name)
              cached_positions[option_name] || 0
            end

            # Cached positions for faster sorting (computed once after registration)
            #
            # Thread-safety note: Cache initialization uses ||= which is not atomic.
            # This is acceptable because Registry is populated during Rails boot
            # (single-threaded phase) via RegistryInitializer before any requests.
            #
            # @return [Hash<Symbol, Integer>] Frozen hash of option_name => position
            def cached_positions
              @cached_positions ||= registry.transform_values { |info| info[:position] || 0 }.freeze
            end

            # Check if an option is registered
            #
            # @param option_name [Symbol] The name of the option
            # @return [Boolean]
            def registered?(option_name)
              registry.key?(option_name)
            end

            # Get all registered option names
            #
            # @return [Array<Symbol>]
            def all_options
              registry.keys
            end

            # Get all validators
            #
            # @return [Hash] Hash of option_name => processor_class for validators
            def validators
              registry.select { |_, info| info.fetch(:category) == :validator }
                      .transform_values { |info| info.fetch(:processor_class) }
            end

            # Get all modifiers
            #
            # @return [Hash] Hash of option_name => processor_class for modifiers
            def modifiers
              registry.select { |_, info| info.fetch(:category) == :modifier }
                      .transform_values { |info| info.fetch(:processor_class) }
            end

            # Get all conditionals
            #
            # @return [Hash] Hash of option_name => processor_class for conditionals
            def conditionals
              registry.select { |_, info| info.fetch(:category) == :conditional }
                      .transform_values { |info| info.fetch(:processor_class) }
            end

            # Reset registry (mainly for testing)
            def reset!
              @registry = nil
              @cached_positions = nil
            end

            private

            def registry
              @registry ||= {}
            end
          end
        end
      end
    end
  end
end
