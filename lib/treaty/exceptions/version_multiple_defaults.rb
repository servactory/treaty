# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when multiple versions are marked as default in the same treaty
    #
    # ## Purpose
    #
    # Ensures that only one version in a treaty can be marked as the default.
    # The default version is used when clients don't specify an API version
    # in their requests, so having multiple defaults would create ambiguity.
    #
    # ## Usage
    #
    # This exception is raised automatically during version definition validation:
    #
    # ### Invalid Configuration
    # ```ruby
    # class PostsTreaty < ApplicationTreaty
    #   version 1, default: true do
    #     # First default version
    #   end
    #
    #   version 2, default: true do
    #     # ERROR: Cannot have two default versions
    #   end
    # end
    # ```
    #
    # ### Valid Configurations
    # ```ruby
    # # Option 1: Single default version
    # class PostsTreaty < ApplicationTreaty
    #   version 1 do
    #     # Not default
    #   end
    #
    #   version 2, default: true do
    #     # Only one default - valid
    #   end
    # end
    #
    # # Option 2: No default version (version must be explicitly specified)
    # class PostsTreaty < ApplicationTreaty
    #   version 1 do
    #     # Not default
    #   end
    #
    #   version 2 do
    #     # Not default - valid, but version must be specified in requests
    #   end
    # end
    # ```
    #
    # ## When It's Raised
    #
    # The exception is raised during treaty class loading when:
    # 1. A second version is being defined with `default: true`
    # 2. AND another version already has `default: true`
    #
    # ## Integration
    #
    # This is a configuration error that should be caught during development.
    # It can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::VersionMultipleDefaults, with: :render_config_error
    #
    # def render_config_error(exception)
    #   render json: { error: exception.message }, status: :internal_server_error  # HTTP 500
    # end
    # ```
    #
    # ## HTTP Status
    #
    # Returns HTTP 500 Internal Server Error as this indicates a configuration
    # problem in the application code that should be fixed by developers.
    #
    # ## Resolution
    #
    # To fix this error:
    # 1. Identify which version should truly be the default
    # 2. Remove `default: true` from all other versions
    # 3. Keep only one `default: true` declaration
    #
    # ## Best Practice
    #
    # Typically, the newest stable version should be marked as default:
    #
    # ```ruby
    # version 1 do
    #   deprecated true  # Old version
    # end
    #
    # version 2 do
    #   # Stable version
    # end
    #
    # version 3, default: true do
    #   # Latest stable version - the default
    # end
    # ```
    #
    # ## Related Exceptions
    #
    # - `VersionDefaultDeprecatedConflict` - When a single version has both default and deprecated
    # - `SpecifiedVersionNotFound` - When no default exists and no version is specified
    class VersionMultipleDefaults < Base
    end
  end
end
