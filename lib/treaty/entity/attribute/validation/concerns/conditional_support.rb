# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Validation
        module Concerns
          # Shared logic for conditional (if/unless) attribute processing.
          #
          # Extracted from:
          # - Orchestrator::Base
          # - NestedTransformer::ObjectTransformer
          # - NestedTransformer::ArrayTransformer
          #
          # ## Usage
          #
          # Include this module and implement:
          # - `conditionals_cache` - returns cached conditional processors
          # - `conditional_evaluation_data(source_data)` - wraps data for condition evaluation
          #
          # Example:
          #   class MyValidator
          #     include Concerns::ConditionalSupport
          #
          #     def conditionals_cache
          #       @conditionals_cache ||= build_conditionals_cache(attributes)
          #     end
          #
          #     def conditional_evaluation_data(source_data)
          #       source_data  # or wrap with parent: { parent_name => source_data }
          #     end
          #   end
          module ConditionalSupport
            # Returns the conditional option type if present (:if or :unless)
            # Raises error if both are present (mutual exclusivity)
            #
            # @param attribute [Attribute::Base] The attribute to check
            # @raise [Treaty::Exceptions::Validation] If both :if and :unless are present
            # @return [Symbol, nil] :if, :unless, or nil
            def conditional_option_for(attribute) # rubocop:disable Metrics/MethodLength
              # Use memoized methods if available on attribute
              return attribute.conditional_type if attribute.respond_to?(:conditional_type)

              # Fallback for attributes without memoization
              has_if = attribute.options.key?(:if)
              has_unless = attribute.options.key?(:unless)

              if has_if && has_unless
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.conditionals.mutual_exclusivity_error",
                        attribute: attribute.name
                      )
              end

              return :if if has_if
              return :unless if has_unless

              nil
            end

            # Checks if an attribute should be processed based on its conditional
            # Returns true if no conditional is defined or if conditional evaluates appropriately
            #
            # @param attribute [Attribute::Base] The attribute to check
            # @param source_data [Hash] Source data to pass to conditional (used by nested transformers)
            # @return [Boolean] True if attribute should be processed, false to skip it
            def should_process_attribute?(attribute, source_data = nil)
              # Fast path: no conditional option
              conditional_type = conditional_option_for(attribute)
              return true if conditional_type.nil?

              # Get cached conditional processor
              conditional = conditionals_cache[attribute]
              return true if conditional.nil?

              # Evaluate condition with appropriate data
              evaluation_data = conditional_evaluation_data(source_data)
              conditional.evaluate_condition(evaluation_data)
            rescue StandardError
              # If conditional evaluation fails, skip the attribute
              false
            end

            # Builds conditional processors for attributes with :if or :unless option
            # Validates schema at build time for performance
            #
            # @param attributes_collection [Enumerable] Collection of attributes to process
            # @return [Hash] Hash of attribute => conditional processor
            def build_conditionals_cache(attributes_collection) # rubocop:disable Metrics/MethodLength
              attributes_collection.each_with_object({}) do |attribute, cache|
                conditional_type = conditional_option_for(attribute)
                next if conditional_type.nil?

                processor_class = Option::Registry.processor_for(conditional_type)
                next if processor_class.nil?

                conditional = processor_class.new(
                  attribute_name: attribute.name,
                  attribute_type: attribute.type,
                  option_schema: attribute.options.fetch(conditional_type)
                )

                conditional.validate_schema!

                cache[attribute] = conditional
              end
            end

            protected

            # Returns cached conditional processors
            # Must be implemented by including class
            #
            # @return [Hash] Hash of attribute => conditional processor
            def conditionals_cache
              raise NotImplementedError, "#{self.class} must implement #conditionals_cache"
            end

            # Wraps source data for conditional evaluation
            # Override in nested transformers to wrap with parent attribute name
            #
            # @param source_data [Hash, nil] Source data
            # @return [Hash] Data for conditional evaluation
            def conditional_evaluation_data(source_data)
              source_data
            end
          end
        end
      end
    end
  end
end
