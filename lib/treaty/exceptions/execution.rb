# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when service or executor execution fails
    #
    # ## Purpose
    #
    # Indicates errors during the execution phase, including executor resolution,
    # service invocation, and result processing. Wraps underlying errors to provide
    # consistent error handling across different executor types.
    #
    # ## Usage
    #
    # Raised in various execution scenarios:
    #
    # ### Executor Resolution
    # ```ruby
    # # When executor class not found
    # raise Treaty::Exceptions::Execution,
    #       I18n.t("treaty.execution.executor_not_found", class_name: "Posts::IndexService")
    #
    # # When executor not defined
    # raise Treaty::Exceptions::Execution,
    #       I18n.t("treaty.execution.executor_missing", version: "1.0.0")
    # ```
    #
    # ### Service Execution
    # ```ruby
    # # Proc executor error
    # begin
    #   executor.call(params: validated_params)
    # rescue StandardError => e
    #   raise Treaty::Exceptions::Execution, I18n.t("treaty.execution.proc_error", message: e.message)
    # end
    #
    # # Servactory service error
    # begin
    #   executor.call!(params: validated_params)
    # rescue Servactory::Exceptions::Input => e
    #   raise Treaty::Exceptions::Execution, I18n.t("treaty.execution.servactory_input_error", message: e.message)
    # end
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::Execution, with: :render_execution_error
    #
    # def render_execution_error(exception)
    #   render json: { error: exception.message }, status: :internal_server_error
    # end
    # ```
    #
    # ## Executor Types
    #
    # Handles errors from multiple executor types:
    # - Proc - Lambda/Proc executors
    # - Servactory - ApplicationService-based services
    # - Regular Class - Plain Ruby classes with custom methods
    class Execution < Base
    end
  end
end
