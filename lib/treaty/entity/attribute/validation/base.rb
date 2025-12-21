# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Validation
        # Base class for request and response validation.
        #
        # ## Purpose
        #
        # Provides common interface for validation used in Treaty.
        # Subclasses implement specific validation logic for requests and responses.
        #
        # ## Responsibilities
        #
        # 1. **Validation Interface** - Defines common validation interface
        # 2. **Factory Pattern** - Provides class-level validate! method
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
        # - VersionFactory - Provides version information
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
          # @param version_factory [VersionFactory] Factory containing version information
          def initialize(version_factory:)
            @version_factory = version_factory
          end

          # Performs validation and transformation
          # Must be implemented in subclasses
          #
          # @raise [Treaty::Exceptions::NotImplemented] If subclass doesn't implement
          # @return [Hash] Validated and transformed data
          def validate!
            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.nested.orchestrator.collection_not_implemented")
          end
        end
      end
    end
  end
end
