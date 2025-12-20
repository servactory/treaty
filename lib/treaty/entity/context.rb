# frozen_string_literal: true

module Treaty
  class Entity
    # Wrapper for Entity with pre-configured options.
    # Acts as both the API wrapper AND the configuration storage.
    #
    # ## Purpose
    #
    # Provides a way to pre-configure Entity validation options without
    # conflicting with attribute names. Created by Entity.options() method.
    #
    # ## Usage
    #
    # ```ruby
    # # Create context with options
    # context = UserEntity.options(required: false)
    # result = context.call(data)
    # result = context.call!(data)
    # context.valid?(data)
    #
    # # Multiple options
    # context = UserEntity.options(required: false, default: "N/A")
    # result = context.call(data)
    #
    # # Reuse context
    # context = UserEntity.options(required: false)
    # result1 = context.call(data1)
    # result2 = context.call(data2)
    # ```
    #
    # ## Option Precedence
    #
    # Options are applied with the following precedence (highest to lowest):
    # 1. Explicit attribute options (e.g., `string :name, required: false`)
    # 2. Context options (e.g., `required: true` from .options())
    # 3. Entity class defaults (e.g., `required: true` for Entity base class)
    #
    # ## Why Context Exists
    #
    # Using `.options()` instead of passing options to `.call()` avoids
    # name conflicts between attribute names and option names:
    #
    # ```ruby
    # class PaymentEntity < Treaty::Entity
    #   object :payment do
    #     boolean :required  # Attribute named "required" - OK!
    #     string :default    # Attribute named "default" - OK!
    #   end
    # end
    #
    # # Options are separate from data - no conflict!
    # PaymentEntity.options(required: false).call({
    #   payment: { required: true, default: "card" }
    # })
    # ```
    class Context
      # @return [Class<Entity>] The Entity class to process with
      attr_reader :entity_class

      # Creates a new Context instance.
      #
      # @param entity_class [Class<Entity>] The Entity class to process with
      # @param options [Hash] Configuration options (will be normalized)
      def initialize(entity_class, options = {})
        @entity_class = entity_class
        @options = Attribute::OptionNormalizer.normalize(options)
      end

      # Processes data through the Entity's validation and transformation pipeline.
      #
      # @param data [Hash] The data to validate and transform
      # @return [Result] Result object with data and/or errors
      def call(data)
        processor = Processor.new(entity_class, self)
        processor.call(data)
      end

      # Processes data and raises exception on validation errors.
      #
      # @param data [Hash] The data to validate and transform
      # @return [Result] Result object with validated data
      # @raise [Treaty::Exceptions::Validation] If validation fails
      def call!(data)
        processor = Processor.new(entity_class, self)
        processor.call!(data)
      end

      # Checks if data is valid according to Entity definition.
      #
      # @param data [Hash] The data to validate
      # @return [Boolean] True if data is valid
      def valid?(data)
        call(data).valid?
      end

      # Returns true if any options are configured.
      #
      # @return [Boolean]
      def any?
        @options.any?
      end

      # Merges context options with attribute options.
      # Explicit attribute options take precedence over context defaults.
      #
      # @param attribute_options [Hash] Options defined on the attribute
      # @param explicit_options [Set<Symbol>] Set of explicitly defined option names
      # @return [Hash] Merged options
      def merge_with(attribute_options, explicit_options)
        return attribute_options if @options.empty?

        result = attribute_options.dup
        @options.each do |option_name, value|
          # Skip if attribute explicitly defined this option
          next if explicit_options.include?(option_name)

          result[option_name] = value
        end
        result
      end

      # Returns the context as a Hash.
      #
      # @return [Hash]
      def to_h
        @options.dup
      end

      # Returns a human-readable representation.
      #
      # @return [String]
      def inspect
        "#<#{self.class.name} entity_class=#{entity_class.name} options=#{@options.keys.inspect}>"
      end
    end
  end
end
