# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when attempting to use a deprecated API version
    #
    # ## Purpose
    #
    # Prevents usage of API versions that have been marked as deprecated.
    # Helps enforce API version lifecycle management and guides clients
    # to migrate to newer versions.
    #
    # ## Usage
    #
    # Raised automatically during version resolution when a deprecated version is requested:
    #
    # ```ruby
    # version 1 do
    #   deprecated true  # Simple boolean
    #   # or
    #   deprecated(ENV['RELEASE_VERSION'].to_i >= 17)  # Conditional
    #   # or
    #   deprecated { some_condition? }  # Dynamic evaluation
    #
    #   # ... rest of version definition
    # end
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers to return appropriate HTTP status:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::Deprecated, with: :render_version_deprecated
    #
    # def render_version_deprecated(exception)
    #   render json: { error: exception.message }, status: :gone  # HTTP 410
    # end
    # ```
    #
    # ## HTTP Status
    #
    # Typically returns HTTP 410 Gone to indicate that the resource (API version)
    # is no longer available and will not be available again.
    #
    # ## Version Lifecycle
    #
    # 1. Version is active (deprecated: false)
    # 2. Version is deprecated (deprecated: true) - raises this exception
    # 3. Version is removed from code
    class Deprecated < Base
    end
  end
end
