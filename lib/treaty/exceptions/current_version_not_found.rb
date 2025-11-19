# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when no API version is specified and no default version is configured
    #
    # ## Purpose
    #
    # Prevents treaty execution when the client doesn't specify a version
    # and the treaty hasn't defined a default version to fall back to.
    # Enforces explicit version selection for API contracts.
    #
    # ## Usage
    #
    # Raised automatically during version resolution in two scenarios:
    #
    # ### Scenario 1: No Version Specified, No Default Configured
    # ```ruby
    # class PostsTreaty < ApplicationTreaty
    #   version 1 do
    #     # No default: true specified
    #     request { string :title }
    #     response(200) { object :post }
    #   end
    #
    #   version 2 do
    #     request { string :title }
    #     response(200) { object :post }
    #   end
    # end
    #
    # # Client request without version header
    # PostsTreaty.call!(version: nil, params: { title: "Test" })
    # # => Raises Treaty::Exceptions::CurrentVersionNotFound
    # # => "Current version is required for validation"
    # ```
    #
    # ### Scenario 2: Empty Version String
    # ```ruby
    # PostsTreaty.call!(version: "", params: { title: "Test" })
    # # => Raises Treaty::Exceptions::CurrentVersionNotFound
    # ```
    #
    # ### Prevention: Define Default Version
    # ```ruby
    # class PostsTreaty < ApplicationTreaty
    #   version 1 do
    #     request { string :title }
    #     response(200) { object :post }
    #   end
    #
    #   version 2, default: true do  # Marks version 2 as default
    #     request { string :title }
    #     response(200) { object :post }
    #   end
    # end
    #
    # # Now works without explicit version
    # PostsTreaty.call!(version: nil, params: { title: "Test" })
    # # => Uses version 2 by default
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers to return appropriate HTTP status:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::CurrentVersionNotFound, with: :render_version_required
    #
    # def render_version_required(exception)
    #   render json: {
    #     error: exception.message,
    #     hint: "Please specify an API version in the request header"
    #   }, status: :bad_request  # HTTP 400
    # end
    # ```
    #
    # ## HTTP Status
    #
    # Typically returns HTTP 400 Bad Request, indicating that the client
    # failed to provide required version information.
    #
    # ## Best Practices
    #
    # ### For API Providers
    #
    # 1. **Always define a default version** for backward compatibility:
    #    ```ruby
    #    version 1, default: true do
    #      # ...
    #    end
    #    ```
    #
    # 2. **Document version requirements** in API documentation
    #
    # 3. **Provide helpful error messages** in rescue handlers
    #
    # ### For API Clients
    #
    # 1. **Always specify version explicitly** in production code
    # 2. **Don't rely on default versions** for critical applications
    # 3. **Handle this exception** with version selection logic
    #
    # ## Difference from VersionNotFound
    #
    # - **CurrentVersionNotFound**: No version specified (nil/blank)
    # - **VersionNotFound**: Specific version specified but doesn't exist
    #
    # ## Version Selection Flow
    #
    # 1. Client provides version → Use specified version
    # 2. Client provides no version → Look for default version
    # 3. No default version configured → Raise CurrentVersionNotFound
    class CurrentVersionNotFound < Base
    end
  end
end
