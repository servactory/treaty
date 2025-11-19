# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when a specific API version is requested but doesn't exist in the treaty
    #
    # ## Purpose
    #
    # Prevents execution with non-existent API versions. Helps clients
    # discover available versions and prevents errors from version mismatches.
    # Ensures API versioning integrity.
    #
    # ## Usage
    #
    # Raised automatically during version resolution when a requested version
    # is not defined in the treaty:
    #
    # ### Example: Requesting Non-Existent Version
    # ```ruby
    # class PostsTreaty < ApplicationTreaty
    #   version 1 do
    #     request { string :title }
    #     response(200) { object :post }
    #   end
    #
    #   version 2, default: true do
    #     request { string :title, :summary }
    #     response(200) { object :post }
    #   end
    # end
    #
    # # Client requests version 3 (doesn't exist)
    # PostsTreaty.call!(version: "3", params: { title: "Test" })
    # # => Raises Treaty::Exceptions::VersionNotFound
    # # => "Version 3 not found in treaty definition"
    # ```
    #
    # ### Example: Version Format Mismatch
    # ```ruby
    # # Treaty defines version 1
    # version 1 do
    #   # ...
    # end
    #
    # # Client requests "1.0.0" (treated as different from "1")
    # PostsTreaty.call!(version: "1.0.0", params: {})
    # # => Raises Treaty::Exceptions::VersionNotFound if exact match not found
    # ```
    #
    # ### Example: Typo in Version Number
    # ```ruby
    # PostsTreaty.call!(version: "v2", params: {})  # Should be "2"
    # # => Raises Treaty::Exceptions::VersionNotFound
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers to return appropriate HTTP status:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::VersionNotFound, with: :render_version_not_found
    #
    # def render_version_not_found(exception)
    #   available_versions = extract_available_versions(exception)
    #
    #   render json: {
    #     error: exception.message,
    #     available_versions: available_versions,
    #     hint: "Please use one of the available API versions"
    #   }, status: :not_found  # HTTP 404
    # end
    # ```
    #
    # ## HTTP Status
    #
    # Typically returns HTTP 404 Not Found, indicating that the requested
    # resource (API version) does not exist on the server.
    #
    # ## Common Scenarios
    #
    # ### 1. Client Using Outdated Version Number
    # ```ruby
    # # Version 1 was removed, only version 2 and 3 exist
    # PostsTreaty.call!(version: "1", params: {})
    # # => VersionNotFound
    # ```
    #
    # ### 2. Client Using Future Version
    # ```ruby
    # # Client expects version 5 but only version 1-3 deployed
    # PostsTreaty.call!(version: "5", params: {})
    # # => VersionNotFound
    # ```
    #
    # ### 3. Version Format Inconsistency
    # ```ruby
    # # Treaty uses integers, client uses semantic versioning
    # version 1 do ... end
    # version 2 do ... end
    #
    # PostsTreaty.call!(version: "v2.0.0", params: {})
    # # => VersionNotFound (should use "2")
    # ```
    #
    # ## Best Practices
    #
    # ### For API Providers
    #
    # 1. **Version numbering consistency**:
    #    ```ruby
    #    # Choose one format and stick with it
    #    version 1 do ... end
    #    version 2 do ... end
    #    # OR
    #    version "1.0.0" do ... end
    #    version "2.0.0" do ... end
    #    ```
    #
    # 2. **Document available versions** in API documentation
    #
    # 3. **Provide version discovery endpoint**:
    #    ```ruby
    #    GET /api/versions
    #    # => { available_versions: ["1", "2", "3"], default: "3" }
    #    ```
    #
    # 4. **Use deprecation** before removal:
    #    ```ruby
    #    version 1 do
    #      deprecated true  # Warn before removing
    #    end
    #    ```
    #
    # ### For API Clients
    #
    # 1. **Validate version before requests**
    # 2. **Handle version errors gracefully**
    # 3. **Check API documentation** for available versions
    # 4. **Implement version fallback logic** when appropriate
    #
    # ## Difference from SpecifiedVersionNotFound
    #
    # - **SpecifiedVersionNotFound**: No version specified (nil/blank), no default configured
    # - **VersionNotFound**: Specific version specified but doesn't exist in treaty
    #
    # ## Difference from Deprecated
    #
    # - **VersionNotFound**: Version doesn't exist at all (HTTP 404)
    # - **Deprecated**: Version exists but is marked as deprecated (HTTP 410)
    #
    # ## Version Resolution Order
    #
    # 1. Version specified → Look for exact match
    # 2. Exact match not found → Raise VersionNotFound
    # 3. Match found but deprecated → Raise Deprecated
    # 4. Match found and active → Use version
    class VersionNotFound < Base
    end
  end
end
