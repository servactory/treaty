# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised for unexpected errors that don't fit other exception types
    #
    # ## Purpose
    #
    # Serves as a catch-all for unexpected errors that occur during Treaty
    # processing but don't fall into specific exception categories.
    # Helps maintain consistent error handling across the gem.
    #
    # ## Usage
    #
    # Used for rare or unexpected edge cases:
    #
    # ```ruby
    # def process_data(data)
    #   # ... processing logic
    # rescue => e
    #   # Log the unexpected error for investigation
    #   Rails.logger.error("Unexpected Treaty error: #{e.message}")
    #
    #   raise Treaty::Exceptions::Unexpected,
    #         "An unexpected error occurred during processing: #{e.message}"
    # end
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers as a safety net:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::Unexpected, with: :render_unexpected_error
    #
    # def render_unexpected_error(exception)
    #   # Log for investigation
    #   Rails.logger.error("Unexpected Treaty exception: #{exception.message}")
    #   Rails.logger.error(exception.backtrace.join("\n"))
    #
    #   render json: { error: "An unexpected error occurred" },
    #          status: :internal_server_error
    # end
    # ```
    #
    # ## When to Use
    #
    # - Edge cases not covered by specific exceptions
    # - Defensive programming for "should never happen" scenarios
    # - Wrapping third-party library errors
    # - Temporary exception during development before creating specific type
    #
    # ## When Not to Use
    #
    # If the error fits an existing exception type, use that instead:
    # - Validation errors → Treaty::Exceptions::Validation
    # - Execution errors → Treaty::Exceptions::Execution
    # - Configuration errors → specific exception type
    #
    # ## Investigation
    #
    # When this exception occurs in production:
    # 1. Review logs for full context
    # 2. Analyze stack trace
    # 3. Consider creating a specific exception type if pattern emerges
    # 4. Add tests to prevent recurrence
    class Unexpected < Base
    end
  end
end
