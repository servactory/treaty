# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      # Central registry for all option processors (validators and modifiers).
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
      # 3. **Categorization** - Organizes processors by category (validator/modifier)
      # 4. **Validation** - Checks if options are registered
      #
      # ## Registered Options
      #
      # ### Validators
      # - `:required` → RequiredValidator
      # - `:type` → TypeValidator
      # - `:inclusion` → InclusionValidator
      #
      # ### Modifiers
      # - `:as` → AsModifier
      # - `:default` → DefaultModifier
      #
      # ## Usage
      #
      # Registration (done in RegistryInitializer):
      #   Registry.register(:required, RequiredValidator, category: :validator)
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
          # @param category [Symbol] The category (:validator or :modifier)
          def register(option_name, processor_class, category:)
            registry[option_name] = {
              processor_class:,
              category:
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
            registry.select { |_, info| info[:category] == :validator }
                    .transform_values { |info| info[:processor_class] }
          end

          # Get all modifiers
          #
          # @return [Hash] Hash of option_name => processor_class for modifiers
          def modifiers
            registry.select { |_, info| info[:category] == :modifier }
                    .transform_values { |info| info[:processor_class] }
          end

          # Reset registry (mainly for testing)
          def reset!
            @registry = nil
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
