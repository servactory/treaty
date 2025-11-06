# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      # Base class for validation strategies (adapter vs non-adapter).
      #
      # ## Purpose
      #
      # Provides common interface for validation strategies used in Treaty.
      # Subclasses implement specific validation logic for different strategies.
      #
      # ## Responsibilities
      #
      # 1. **Strategy Interface** - Defines common validation interface
      # 2. **Factory Pattern** - Provides class-level validate! method
      # 3. **Strategy Detection** - Checks if adapter strategy is active
      #
      # ## Subclasses
      #
      # - Request::Validation - Validates request data (uses Orchestrator::Request)
      # - Response::Validation - Validates response data (uses Orchestrator::Response)
      #
      # ## Usage
      #
      # Subclasses must implement:
      # - `validate!` - Performs validation and returns transformed data
      #
      # Example usage:
      #   Request::Validation.validate!(version_factory: factory, data: params)
      #
      # ## Strategy Pattern
      #
      # The validation system supports two strategies:
      # - **Adapter Strategy** - Adapts between different API versions
      # - **Standard Strategy** - Direct version handling
      #
      # This base class provides `adapter_strategy?` helper to check current strategy.
      #
      # ## Factory Method
      #
      # The `self.validate!(...)` class method provides a convenient factory pattern:
      # ```ruby
      # Request::Validation.validate!(version_factory: factory, data: params)
      # # Equivalent to:
      # Request::Validation.new(version_factory: factory).validate!(data: params)
      # ```
      #
      # ## Architecture
      #
      # Works with:
      # - VersionFactory - Provides version and strategy information
      # - Orchestrator::Base - Performs actual validation and transformation
      class Base
        # Class-level factory method for validation
        # Creates instance and calls validate!
        #
        # @param args [Hash] Arguments passed to initialize and validate!
        # @return [Hash] Validated and transformed data
        def self.validate!(...)
          new(...).validate!
        end

        # Creates a new validation instance
        #
        # @param version_factory [VersionFactory] Factory containing version and strategy
        def initialize(version_factory:)
          @version_factory = version_factory
        end

        # Performs validation and transformation
        # Must be implemented in subclasses
        #
        # @raise [NotImplementedError] If subclass doesn't implement
        # @return [Hash] Validated and transformed data
        def validate!
          raise Treaty::Exceptions::Validation,
                I18n.t("treaty.orchestrator.collection_not_implemented")
        end

        private

        # Checks if adapter strategy is active
        #
        # @return [Boolean] True if using adapter strategy
        def adapter_strategy?
          @version_factory.strategy_instance.adapter?
        end
      end
    end
  end
end
