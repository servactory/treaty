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
      # ## Built-in Validators
      #
      # - `:required` → RequiredValidator - Validates required/optional attributes
      # - `:type` → TypeValidator - Validates value types
      # - `:inclusion` → InclusionValidator - Validates value is in allowed set
      # - `:format` → FormatValidator - Validates string values match specific formats
      #
      # ## Built-in Modifiers
      #
      # - `:as` → AsModifier - Renames attributes
      # - `:default` → DefaultModifier - Provides default values
      # - `:transform` → TransformModifier - Transforms values using custom lambdas
      # - `:cast` → CastModifier - Converts values between types automatically
      #
      # ## Built-in Conditionals
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
          #
          # @return [void]
          def register_validators!
            Registry.register(:required, Validators::RequiredValidator, category: :validator)
            Registry.register(:type, Validators::TypeValidator, category: :validator)
            Registry.register(:inclusion, Validators::InclusionValidator, category: :validator)
            Registry.register(:format, Validators::FormatValidator, category: :validator)
          end

          # Registers all built-in modifiers
          #
          # @return [void]
          def register_modifiers!
            Registry.register(:as, Modifiers::AsModifier, category: :modifier)
            Registry.register(:default, Modifiers::DefaultModifier, category: :modifier)
            Registry.register(:transform, Modifiers::TransformModifier, category: :modifier)
            Registry.register(:cast, Modifiers::CastModifier, category: :modifier)
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
