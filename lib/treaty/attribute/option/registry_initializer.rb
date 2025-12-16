# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      # Initializes and registers all built-in option processors with the Registry.
      #
      # ## Purpose
      #
      # Centralized registration point for all option processors (validators, modifiers, and conditionals).
      # Automatically registers all built-in options when loaded.
      #
      # ## Responsibilities
      #
      # 1. **Validator Registration** - Registers all built-in validators
      # 2. **Modifier Registration** - Registers all built-in modifiers
      # 3. **Conditional Registration** - Registers all built-in conditionals
      # 4. **Auto-Loading** - Executes automatically when file is loaded
      #
      # ## Built-in Validators (sorted by position)
      #
      # - `:type` → TypeValidator (position: 100) - Validates value types
      # - `:required` → RequiredValidator (position: 200) - Validates required/optional attributes
      # - `:inclusion` → InclusionValidator (position: 300) - Validates value is in allowed set
      # - `:format` → FormatValidator (position: 400) - Validates string values match specific formats
      #
      # ## Built-in Modifiers (sorted by position)
      #
      # - `:transform` → TransformModifier (position: 500) - Transforms values using custom lambdas
      # - `:cast` → CastModifier (position: 600) - Converts values between types automatically
      # - `:computed` → ComputedModifier (position: 700) - Computes values from all raw data
      # - `:default` → DefaultModifier (position: 800) - Provides default values
      # - `:as` → AsModifier (position: 900) - Renames attributes
      #
      # ## Built-in Conditionals (no position - handled separately)
      #
      # - `:if` → IfConditional - Conditionally includes attributes based on runtime data
      # - `:unless` → UnlessConditional - Conditionally excludes attributes based on runtime data
      #
      # ## Auto-Registration
      #
      # This file calls `register_all!` when loaded, ensuring all processors
      # are available immediately.
      #
      # ## Adding New Options
      #
      # To add a new option processor:
      #
      # 1. Create the processor class (inherit from Option::Base)
      # 2. Add registration call here:
      # ```ruby
      # def register_validators!
      #   Registry.register(:required, Validators::RequiredValidator, category: :validator)
      #   Registry.register(:my_option, Validators::MyValidator, category: :validator)
      # end
      # ```
      #
      # ## Architecture
      #
      # Works with:
      # - Registry - Stores processor registrations
      # - Option::Base - Base class for all processors
      # - OptionOrchestrator - Uses registered processors
      module RegistryInitializer
        class << self
          # Registers all built-in option processors
          # Called automatically when this file is loaded
          #
          # @return [void]
          def register_all!
            register_validators!
            register_modifiers!
            register_conditionals!
          end

          private

          # Registers all built-in validators
          # Position determines execution order (lower = earlier)
          #
          # @return [void]
          def register_validators!
            Registry.register(:type, Validators::TypeValidator, category: :validator, position: 100)
            Registry.register(:required, Validators::RequiredValidator, category: :validator, position: 200)
            Registry.register(:inclusion, Validators::InclusionValidator, category: :validator, position: 300)
            Registry.register(:format, Validators::FormatValidator, category: :validator, position: 400)
          end

          # Registers all built-in modifiers
          # Position determines execution order (lower = earlier)
          #
          # @return [void]
          def register_modifiers!
            Registry.register(:transform, Modifiers::TransformModifier, category: :modifier, position: 500)
            Registry.register(:cast, Modifiers::CastModifier, category: :modifier, position: 600)
            Registry.register(:computed, Modifiers::ComputedModifier, category: :modifier, position: 700)
            Registry.register(:default, Modifiers::DefaultModifier, category: :modifier, position: 800)
            Registry.register(:as, Modifiers::AsModifier, category: :modifier, position: 900)
          end

          # Registers all built-in conditionals
          #
          # @return [void]
          def register_conditionals!
            Registry.register(:if, Conditionals::IfConditional, category: :conditional)
            Registry.register(:unless, Conditionals::UnlessConditional, category: :conditional)
          end
        end
      end
    end
  end
end

# Auto-register all options when this file is loaded
Treaty::Attribute::Option::RegistryInitializer.register_all!
