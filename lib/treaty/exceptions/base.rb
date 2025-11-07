# frozen_string_literal: true

module Treaty
  module Exceptions
    # Base exception class for all Treaty-specific exceptions
    #
    # ## Purpose
    #
    # Serves as the parent class for all custom exceptions in the Treaty gem.
    # Allows catching all Treaty-related exceptions with a single rescue clause.
    #
    # ## Usage
    #
    # All Treaty exceptions inherit from this base class:
    #
    # ```ruby
    # begin
    #   Treaty::Base.call!(controller: self, params: params)
    # rescue Treaty::Exceptions::Base => e
    #   # Catches any Treaty-specific exception
    #   handle_treaty_error(e)
    # end
    # ```
    #
    # ## Integration
    #
    # Can be used in application controllers for centralized error handling:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::Base, with: :handle_treaty_error
    # ```
    #
    # ## Subclasses
    #
    # - Validation - Attribute validation errors
    # - Execution - Service execution errors
    # - Deprecated - API version deprecation
    # - Strategy - Invalid strategy specification
    # - ClassName - Treaty class not found
    # - MethodName - Unknown method in DSL
    # - NestedAttributes - Nesting depth exceeded
    # - NotImplemented - Abstract method not implemented
    # - Unexpected - General unexpected errors
    class Base < StandardError
    end
  end
end
