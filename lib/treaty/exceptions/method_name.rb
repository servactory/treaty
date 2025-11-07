# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when an unknown method is called in the version DSL
    #
    # ## Purpose
    #
    # Prevents typos and invalid method calls in the treaty version definition DSL.
    # Ensures only recognized DSL methods are used within version blocks.
    #
    # ## Usage
    #
    # Raised automatically by method_missing in VersionFactory:
    #
    # ```ruby
    # version 1 do
    #   strategy Treaty::Strategy::ADAPTER  # Valid
    #   deprecated true                     # Valid
    #   summary "Version 1"                 # Valid
    #
    #   invalid_method "foo"  # Raises Treaty::Exceptions::MethodName
    # end
    # ```
    #
    # ## Integration
    #
    # Typically caught during development/testing rather than production:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::MethodName, with: :render_dsl_error
    #
    # def render_dsl_error(exception)
    #   render json: { error: exception.message }, status: :internal_server_error
    # end
    # ```
    #
    # ## Valid DSL Methods
    #
    # Within a version block, these methods are valid:
    # - strategy(code) - Set version strategy (DIRECT/ADAPTER)
    # - deprecated(condition) - Mark version as deprecated
    # - summary(text) - Add version description
    # - request(&block) - Define request schema
    # - response(status, &block) - Define response schema
    # - delegate_to(executor, method) - Set executor
    #
    # ## Prevention
    #
    # Always refer to Treaty documentation for valid DSL methods.
    # This exception helps catch typos early in development.
    class MethodName < Base
    end
  end
end
