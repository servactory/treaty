# frozen_string_literal: true

module Treaty
  module Entity
    module Attribute
      module Validation
        module Concerns
          # Provides conditional attribute processing for nested transformers.
          #
          # ## Purpose
          #
          # Handles :if and :unless options for nested attributes during transformation.
          # Extracts duplicated conditional logic from ObjectTransformer and ArrayTransformer.
          #
          # ## Responsibilities
          #
          # 1. **Conditional Detection** - Identifies :if/:unless options on attributes
          # 2. **Mutual Exclusivity** - Ensures :if and :unless aren't used together
          # 3. **Processor Caching** - Builds and caches conditional processors
          # 4. **Condition Evaluation** - Evaluates conditions with source data
          #
          # ## Requirements
          #
          # Including class must provide:
          # - `attribute` method returning Attribute::Base with collection_of_attributes
          #
          # ## Usage
          #
          #   class ObjectTransformer
          #     include Concerns::ConditionalProcessing
          #
          #     def transform(value)
          #       attribute.collection_of_attributes.each do |nested_attribute|
          #         next unless should_process_attribute?(nested_attribute, value)
          #         # process attribute...
          #       end
          #     end
          #   end
          module ConditionalProcessing
            private

            # Returns the conditional option name if present (:if or :unless)
            # Raises error if both are present (mutual exclusivity)
            #
            # @param nested_attribute [Attribute::Base] The attribute to check
            # @raise [Treaty::Exceptions::Validation] If both :if and :unless are present
            # @return [Symbol, nil] :if, :unless, or nil
            def conditional_option_for(nested_attribute) # rubocop:disable Metrics/MethodLength
              has_if = nested_attribute.options.key?(:if)
              has_unless = nested_attribute.options.key?(:unless)

              if has_if && has_unless
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.conditionals.mutual_exclusivity_error",
                        attribute: nested_attribute.name
                      )
              end

              return :if if has_if
              return :unless if has_unless

              nil
            end

            # Gets cached conditional processors for attributes or builds them
            #
            # @return [Hash] Hash of attribute => conditional processor
            def conditionals_for_attributes
              @conditionals_for_attributes ||= build_conditionals_for_attributes
            end

            # Builds conditional processors for attributes with :if or :unless option
            # Validates schema at definition time for performance
            #
            # @return [Hash] Hash of attribute => conditional processor
            def build_conditionals_for_attributes # rubocop:disable Metrics/MethodLength
              attribute.collection_of_attributes.each_with_object({}) do |nested_attribute, cache|
                # Get conditional option name (:if or :unless)
                conditional_type = conditional_option_for(nested_attribute)
                next if conditional_type.nil?

                processor_class = Option::Registry.processor_for(conditional_type)
                next if processor_class.nil?

                # Create processor instance
                conditional = processor_class.new(
                  attribute_name: nested_attribute.name,
                  attribute_type: nested_attribute.type,
                  option_schema: nested_attribute.options.fetch(conditional_type)
                )

                # Validate schema at definition time (not runtime)
                conditional.validate_schema!

                cache[nested_attribute] = conditional
              end
            end

            # Checks if an attribute should be processed based on its conditional
            # Returns true if no conditional is defined or if conditional evaluates appropriately
            #
            # @param nested_attribute [Attribute::Base] The attribute to check
            # @param source_data [Hash, Object] Source data to pass to conditional
            # @return [Boolean] True if attribute should be processed, false to skip it
            def should_process_attribute?(nested_attribute, source_data)
              # Check if attribute has a conditional option
              conditional_type = conditional_option_for(nested_attribute)
              return true if conditional_type.nil?

              # Get cached conditional processor
              conditional = conditionals_for_attributes[nested_attribute]
              return true if conditional.nil?

              # Evaluate condition with source data wrapped with parent attribute name
              wrapped_data = { attribute.name => source_data }
              conditional.evaluate_condition(wrapped_data)
            rescue StandardError
              # If conditional evaluation fails, skip the attribute
              false
            end
          end
        end
      end
    end
  end
end
