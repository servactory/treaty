# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when an unknown or invalid strategy is specified
    #
    # ## Purpose
    #
    # Ensures only valid strategy types are used in version definitions.
    # Prevents typos and invalid strategy configurations.
    #
    # ## Usage
    #
    # Raised when specifying an invalid strategy in version definition:
    #
    # ```ruby
    # version 1 do
    #   strategy Treaty::Strategy::ADAPTER  # Valid
    #   strategy Treaty::Strategy::DIRECT   # Valid
    #
    #   strategy :invalid_strategy  # Raises Treaty::Exceptions::Strategy
    # end
    # ```
    #
    # ## Valid Strategies
    #
    # Only two strategies are supported:
    #
    # - `Treaty::Strategy::DIRECT` - Direct pass-through mode
    #   - No transformation between service and response
    #   - Service output becomes response output directly
    #   - Faster but less flexible
    #
    # - `Treaty::Strategy::ADAPTER` - Adapter mode (default)
    #   - Transforms service output to match response schema
    #   - Validates and adapts data structure
    #   - More flexible, recommended for most cases
    #
    # ## Integration
    #
    # Can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::Strategy, with: :render_strategy_error
    #
    # def render_strategy_error(exception)
    #   render json: { error: exception.message }, status: :internal_server_error
    # end
    # ```
    #
    # ## Default Behavior
    #
    # If no strategy is specified, ADAPTER is used by default:
    #
    # ```ruby
    # version 1 do
    #   # strategy defaults to Treaty::Strategy::ADAPTER
    # end
    # ```
    class Strategy < Base
    end
  end
end
