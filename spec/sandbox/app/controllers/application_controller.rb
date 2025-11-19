# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from Treaty::Exceptions::Deprecated, with: :render_treaty_deprecated_error
  rescue_from Treaty::Exceptions::SpecifiedVersionNotFound, with: :render_treaty_specified_version_not_found_error
  rescue_from Treaty::Exceptions::VersionNotFound, with: :render_treaty_version_not_found_error
  rescue_from Treaty::Exceptions::Validation, with: :render_treaty_validation_error
  rescue_from Treaty::Exceptions::NestedAttributes, with: :render_treaty_nested_attributes_error
  # rescue_from Treaty::Exceptions::Strategy,   with: :render_treaty_strategy_error
  rescue_from Treaty::Exceptions::Execution,  with: :render_treaty_execution_error
  # rescue_from Treaty::Exceptions::MethodName, with: :render_treaty_method_name_error
  rescue_from Treaty::Exceptions::ClassName,  with: :render_treaty_class_name_error
  rescue_from Treaty::Exceptions::NotImplemented, with: :render_treaty_not_implemented_error
  rescue_from Treaty::Exceptions::Unexpected, with: :render_treaty_unexpected_error
  rescue_from Treaty::Exceptions::VersionDefaultDeprecatedConflict,
              with: :render_treaty_version_default_deprecated_conflict_error
  rescue_from Treaty::Exceptions::VersionMultipleDefaults, with: :render_treaty_version_multiple_defaults_error

  private

  def render_treaty_deprecated_error(exception)
    render json: build_error_response_for(exception),
           status: :gone
  end

  def render_treaty_specified_version_not_found_error(exception)
    render json: build_error_response_for(exception),
           status: :bad_request
  end

  def render_treaty_version_not_found_error(exception)
    render json: build_error_response_for(exception),
           status: :not_found
  end

  def render_treaty_validation_error(exception)
    render json: build_error_response_for(exception),
           status: :unprocessable_entity
  end

  def render_treaty_nested_attributes_error(exception)
    render json: build_error_response_for(exception),
           status: :unprocessable_entity
  end

  # def render_treaty_strategy_error(exception)
  #   render json: build_error_response_for(exception),
  #          status: :internal_server_error
  # end

  def render_treaty_execution_error(exception)
    render json: build_error_response_for(exception),
           status: :internal_server_error
  end

  # def render_treaty_method_name_error(exception)
  #   render json: build_error_response_for(exception),
  #          status: :internal_server_error
  # end

  def render_treaty_class_name_error(exception)
    render json: build_error_response_for(exception),
           status: :internal_server_error
  end

  def render_treaty_not_implemented_error(exception)
    render json: build_error_response_for(exception),
           status: :internal_server_error
  end

  def render_treaty_unexpected_error(exception)
    render json: build_error_response_for(exception),
           status: :internal_server_error
  end

  def render_treaty_version_default_deprecated_conflict_error(exception)
    render json: build_error_response_for(exception),
           status: :internal_server_error
  end

  def render_treaty_version_multiple_defaults_error(exception)
    render json: build_error_response_for(exception),
           status: :internal_server_error
  end

  def build_error_response_for(exception)
    {
      error: {
        message: exception.message
      }
    }
  end
end
