# frozen_string_literal: true

module Treaty
  module Attribute
    # Orchestrates all option processors for a single attribute.
    #
    # ## Purpose
    #
    # Coordinates the execution of all option processors (validators and modifiers)
    # for an attribute through three distinct processing phases.
    #
    # ## Responsibilities
    #
    # 1. **Processor Building** - Creates instances of all relevant option processors
    # 2. **Schema Validation** - Validates DSL definition correctness (phase 1)
    # 3. **Value Validation** - Validates runtime data values (phase 2)
    # 4. **Value Transformation** - Transforms values through modifiers (phase 3)
    # 5. **Name Transformation** - Provides target name if `as:` option is used
    #
    # ## Processing Phases
    #
    # ### Phase 1: Schema Validation
    # Validates that the attribute definition in the DSL is correct.
    # Called once during treaty definition loading.
    #
    # ```ruby
    # orchestrator.validate_schema!
    # ```
    #
    # ### Phase 2: Value Validation
    # Validates that runtime data matches the constraints.
    # Called for each request/response.
    #
    # ```ruby
    # orchestrator.validate_value!(value)
    # ```
    #
    # ### Phase 3: Value Transformation
    # Transforms the value (applies defaults, renaming, etc.).
    # Called for each request/response after validation.
    #
    # ```ruby
    # transformed = orchestrator.transform_value(value)
    # ```
    #
    # ## Usage
    #
    # Used by AttributeValidator to coordinate all option processing:
    #
    #   orchestrator = OptionOrchestrator.new(attribute)
    #   orchestrator.validate_schema!
    #   orchestrator.validate_value!(value)
    #   transformed = orchestrator.transform_value(value)
    #   target_name = orchestrator.target_name
    #
    # ## Processor Building
    #
    # Automatically:
    # - Builds processor instances for all defined options
    # - Always includes TypeValidator (even if not explicitly defined)
    # - Validates that all options are registered in Registry
    # - Raises error for unknown options
    #
    # ## Architecture
    #
    # Works with:
    # - Option::Registry - Looks up processor classes
    # - Option::Base - Base class for all processors
    # - AttributeValidator - Uses orchestrator to coordinate processing
    class OptionOrchestrator
      # Creates a new orchestrator instance
      #
      # @param attribute [Attribute::Base] The attribute to orchestrate options for
      def initialize(attribute)
        @attribute = attribute
        @processors = build_processors
      end

      # Phase 1: Validates all option schemas
      # Ensures DSL definition is correct and all options are registered
      #
      # @raise [Treaty::Exceptions::Validation] If unknown options found
      # @return [void]
      def validate_schema!
        validate_known_options!

        @processors.each_value(&:validate_schema!)
      end

      # Phase 2: Validates value against all option validators
      # Validates runtime data against all defined constraints
      #
      # @param value [Object] The value to validate
      # @raise [Treaty::Exceptions::Validation] If validation fails
      # @return [void]
      def validate_value!(value)
        @processors.each_value do |processor|
          processor.validate_value!(value)
        end
      end

      # Phase 3: Transforms value through all option modifiers
      # Applies transformations like defaults, type coercion, etc.
      #
      # @param value [Object] The value to transform
      # @return [Object] Transformed value
      def transform_value(value)
        @processors.values.reduce(value) do |current_value, processor|
          processor.transform_value(current_value)
        end
      end

      # Checks if any processor transforms the attribute name
      #
      # @return [Boolean] True if any processor (like AsModifier) transforms names
      def transforms_name?
        @processors.values.any?(&:transforms_name?)
      end

      # Gets the target name from the processor that transforms names
      # Returns original name if no transformation
      #
      # @return [Symbol] The target attribute name
      def target_name
        name_transformer = @processors.values.find(&:transforms_name?)
        name_transformer ? name_transformer.target_name : @attribute.name
      end

      # Gets specific processor by option name
      #
      # @param option_name [Symbol] The option name (:required, :type, etc.)
      # @return [Option::Base, nil] The processor instance or nil if not found
      def processor_for(option_name)
        @processors.fetch(option_name)
      end

      private

      # Builds processor instances for all defined options
      # Always includes TypeValidator even if not explicitly defined
      #
      # @return [Hash<Symbol, Option::Base>] Hash of option_name => processor
      def build_processors # rubocop:disable Metrics/MethodLength
        processors_hash = {}

        @attribute.options.each do |option_name, option_schema|
          processor_class = Option::Registry.processor_for(option_name)

          next unless processor_class

          processors_hash[option_name] = processor_class.new(
            attribute_name: @attribute.name,
            attribute_type: @attribute.type,
            option_schema:
          )
        end

        # Always include type validator
        unless processors_hash.key?(:type)
          processors_hash[:type] = Option::Validators::TypeValidator.new(
            attribute_name: @attribute.name,
            attribute_type: @attribute.type,
            option_schema: nil
          )
        end

        processors_hash
      end

      # Validates that all options are registered in the Registry
      #
      # @raise [Treaty::Exceptions::Validation] If unknown options found
      # @return [void]
      def validate_known_options!
        unknown_options = @attribute.options.keys - Option::Registry.all_options

        return if unknown_options.empty?

        raise Treaty::Exceptions::Validation,
              I18n.t("treaty.attributes.options.unknown",
                     attribute: @attribute.name,
                     unknown: unknown_options.join(", "),
                     known: Option::Registry.all_options.join(", "))
      end
    end
  end
end
