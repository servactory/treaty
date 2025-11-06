# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when attribute nesting depth exceeds configured maximum
    #
    # ## Purpose
    #
    # Prevents excessive nesting of attributes which can lead to:
    # - Performance degradation
    # - Complex validation logic
    # - Difficult to maintain code
    # - Stack overflow risks
    #
    # ## Usage
    #
    # Raised automatically when defining deeply nested attributes:
    #
    # ```ruby
    # request do
    #   scope :user do
    #     object :profile do
    #       object :settings do
    #         object :preferences do
    #           object :notifications do
    #             # If max nesting is 3, this raises NestedAttributes exception
    #             string :email_enabled
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
    # ```
    #
    # ## Configuration
    #
    # Maximum nesting level is configurable in Treaty engine configuration:
    #
    # ```ruby
    # Treaty::Engine.config.treaty.attribute_nesting_level = 3  # Default
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::NestedAttributes, with: :render_nesting_error
    #
    # def render_nesting_error(exception)
    #   render json: { error: exception.message }, status: :unprocessable_entity
    # end
    # ```
    #
    # ## Best Practices
    #
    # - Keep nesting shallow (2-3 levels maximum)
    # - Consider flattening deeply nested structures
    # - Use separate scopes instead of deep nesting
    # - Refactor complex structures into simpler ones
    class NestedAttributes < Base
    end
  end
end
