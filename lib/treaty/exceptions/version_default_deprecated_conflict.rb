# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when a version is marked as both default and deprecated
    #
    # ## Purpose
    #
    # Prevents the logical contradiction of having a version that is both
    # the default version (used when no version is specified) and deprecated
    # (should not be used). A default version must be active and usable.
    #
    # ## Usage
    #
    # This exception is raised automatically during version definition validation:
    #
    # ### Invalid Configuration
    # ```ruby
    # class PostsTreaty < ApplicationTreaty
    #   version 1, default: true do
    #     deprecated true  # ERROR: Cannot be both default and deprecated
    #     # ... rest of version definition
    #   end
    # end
    # ```
    #
    # ### Valid Configurations
    # ```ruby
    # # Option 1: Default version without deprecation
    # version 1, default: true do
    #   # No deprecated call - valid
    # end
    #
    # # Option 2: Deprecated version without default
    # version 1 do
    #   deprecated true  # Valid, but not default
    # end
    #
    # # Option 3: Neither default nor deprecated
    # version 1 do
    #   # Regular version - valid
    # end
    # ```
    #
    # ## When It's Raised
    #
    # The exception is raised during treaty class loading when:
    # 1. A version has `default: true` in the version declaration
    # 2. AND the same version calls `deprecated` method with any truthy value or block
    #
    # ## Integration
    #
    # This is a configuration error that should be caught during development.
    # It can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::VersionDefaultDeprecatedConflict, with: :render_config_error
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
    # To fix this error, choose one of the following:
    # 1. Remove `default: true` if the version should be deprecated
    # 2. Remove the `deprecated` call if the version should be default
    # 3. Create a new version that will be the default, and deprecate the old one
    #
    # ## Related Exceptions
    #
    # - `VersionMultipleDefaults` - When multiple versions are marked as default
    # - `Deprecated` - When attempting to use an already deprecated version
    class VersionDefaultDeprecatedConflict < Base
    end
  end
end
