# Versioning

[← Back to Documentation](./README.md)

## Overview

This guide covers Treaty's powerful versioning system, allowing multiple API versions to run simultaneously. Learn about version formats, deprecation, version selection, migration strategies, and best practices for evolving your API without breaking existing clients.

## Version Formats

Treaty supports multiple version number formats:

### Numeric Versions

```ruby
version 1 do
  # Version 1
end

version 2 do
  # Version 2
end

version 3 do
  # Version 3
end
```

### Semantic Versioning

```ruby
version "1.0.0" do
  # Version 1.0.0
end

version "1.1.0" do
  # Version 1.1.0
end

version "2.0.0" do
  # Version 2.0.0
end
```

### With Pre-release Labels

```ruby
version "1.0.0.rc1" do
  # Release Candidate 1
end

version [1, 0, 0, :rc2] do
  # Release Candidate 2
end

version "2.0.0.beta1" do
  # Beta 1
end
```

### Shorthand Formats

```ruby
version 1    # Equivalent to 1.0.0
version 1.5  # Equivalent to 1.5.0
version "1"  # Equivalent to 1.0.0
```

## Default Version

Mark one version as default - it will be used when clients don't specify a version:

```ruby
version 1 do
  # Not default
end

version 2 do
  # Not default
end

version 3, default: true do
  # This is the default version
end
```

**Best practice:** The default version should be your latest stable version.

## Version Selection

### How Treaty Determines Version

Treaty can determine the version from several sources (in order of priority):

1. **URL parameter** - `?version=3`
2. **HTTP Header** - `API-Version: 3`
3. **Accept header** - `Accept: application/vnd.api+json; version=3`
4. **Default version** - If none specified

### Version Resolution Exceptions

Treaty raises specific exceptions during version resolution:

#### SpecifiedVersionNotFound

Raised when no version is specified and no default version is configured:

```ruby
class PostsTreaty < ApplicationTreaty
  version 1 do
    # No default: true
  end

  version 2 do
    # No default: true
  end
end

# Client doesn't specify version
PostsTreaty.call!(version: nil, params: {})
# => Raises Treaty::Exceptions::SpecifiedVersionNotFound
# => "Specified version is required for validation"
```

**HTTP Status:** 400 Bad Request

**Solution:** Define a default version or ensure clients always specify a version.

#### VersionNotFound

Raised when a specific version is requested but doesn't exist:

```ruby
class PostsTreaty < ApplicationTreaty
  version 1 do
    # Version 1 definition
  end

  version 2, default: true do
    # Version 2 definition
  end
end

# Client requests non-existent version
PostsTreaty.call!(version: "3", params: {})
# => Raises Treaty::Exceptions::VersionNotFound
# => "Version 3 not found in treaty definition"
```

**HTTP Status:** 404 Not Found

**Solution:** Use an available version or add the requested version to the treaty.

#### Deprecated

Raised when a deprecated version is requested:

```ruby
class PostsTreaty < ApplicationTreaty
  version 1 do
    deprecated true
  end

  version 2, default: true do
    # Current version
  end
end

# Client requests deprecated version
PostsTreaty.call!(version: "1", params: {})
# => Raises Treaty::Exceptions::Deprecated
# => "Version 1 is deprecated and cannot be used"
```

**HTTP Status:** 410 Gone

**Solution:** Migrate to a non-deprecated version.

#### VersionDefaultDeprecatedConflict

Raised when a version is configured as both default and deprecated:

```ruby
class PostsTreaty < ApplicationTreaty
  version 1, default: true do
    deprecated true  # ERROR: Cannot be both default and deprecated
  end
end
```

This is a **configuration error** caught during class loading. A default version must be active and usable - it cannot be deprecated.

**HTTP Status:** 500 Internal Server Error

**Solution:** Choose one of:
- Remove `default: true` if the version should be deprecated
- Remove the `deprecated` call if the version should be default
- Create a new version to be the default, and deprecate the old one

**Valid configurations:**

```ruby
# Option 1: Default version without deprecation
version 1, default: true do
  # No deprecated - valid
end

# Option 2: Deprecated version without default
version 1 do
  deprecated true  # Valid
end

# Option 3: Separate default and deprecated versions
version 1 do
  deprecated true
end

version 2, default: true do
  # Current default - valid
end
```

#### VersionMultipleDefaults

Raised when multiple versions are marked as default:

```ruby
class PostsTreaty < ApplicationTreaty
  version 1, default: true do
    # First default
  end

  version 2, default: true do
    # ERROR: Cannot have multiple defaults
  end
end
```

This is a **configuration error** caught during class loading. Only one version can be the default version.

**HTTP Status:** 500 Internal Server Error

**Solution:** Choose which version should truly be the default and remove `default: true` from all others.

**Valid configuration:**

```ruby
version 1 do
  deprecated true  # Old version
end

version 2 do
  # Stable version, not default
end

version 3, default: true do
  # Only one default - valid
end
```

**Best practice:** The newest stable version should typically be the default.

### Exception Handling in Controllers

```ruby
class ApplicationController < ActionController::API
  rescue_from Treaty::Exceptions::SpecifiedVersionNotFound,
              with: :render_version_required
  rescue_from Treaty::Exceptions::VersionNotFound,
              with: :render_version_not_found
  rescue_from Treaty::Exceptions::Deprecated,
              with: :render_version_deprecated
  rescue_from Treaty::Exceptions::VersionDefaultDeprecatedConflict,
              with: :render_config_error
  rescue_from Treaty::Exceptions::VersionMultipleDefaults,
              with: :render_config_error

  private

  def render_version_required(exception)
    render json: {
      error: exception.message,
      hint: "Please specify an API version"
    }, status: :bad_request
  end

  def render_version_not_found(exception)
    render json: {
      error: exception.message,
      available_versions: extract_available_versions,
      hint: "Please use one of the available versions"
    }, status: :not_found
  end

  def render_version_deprecated(exception)
    render json: {
      error: exception.message,
      hint: "This version is no longer supported. Please upgrade."
    }, status: :gone
  end

  def render_config_error(exception)
    render json: {
      error: exception.message,
      hint: "This is a configuration error. Please contact the development team."
    }, status: :internal_server_error
  end
end
```

### URL Parameter

```bash
GET /api/posts?version=2
```

### HTTP Header

```bash
GET /api/posts
Headers:
  API-Version: 2
```

### Accept Header

```bash
GET /api/posts
Headers:
  Accept: application/vnd.api+json; version=2
```

## Deprecation

Mark versions as deprecated to warn clients:

### Simple Boolean

```ruby
version 1 do
  deprecated true
  # ... rest of definition
end
```

### Block/Lambda

```ruby
version 1 do
  deprecated do
    Time.current > Time.zone.parse("2024-12-31")
  end
  # ... rest of definition
end
```

### Environment-Based

```ruby
version 1 do
  deprecated lambda {
    Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
      Gem::Version.new("3.0.0")
  }
  # ... rest of definition
end
```

**When deprecated:**
- Version still works normally
- Can trigger warnings/logging
- Helps clients know to upgrade

## Version Metadata

### Summary

Add human-readable descriptions to versions:

```ruby
version 1 do
  summary "Initial release with basic post management"
end

version 2 do
  summary "Added category and tags support"
end

version 3 do
  summary "Added author information and social links"
end
```

## Version Evolution Example

Here's how an API evolves through versions:

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  # Version 1: Basic implementation
  version 1 do
    summary "Initial release"
    deprecated true


    request { object :post }
    response(201) { object :post }

    delegate_to Posts::V1::CreateService
  end

  # Version 2: Added validation and new fields
  version 2 do
    summary "Added validation and category support"
    deprecated lambda { ENV["APP_VERSION"] >= "3.0" }


    request do
      object :post do
        string :title
        string :content
        string :category, :optional, in: %w[tech business lifestyle]
      end
    end

    response 201 do
      object :post do
        string :id
        string :title
        string :content
        string :category
        time :created_at
      end
    end

    delegate_to Posts::Stable::CreateService
  end

  # Version 3: Added author and tags
  version 3, default: true do
    summary "Added author information and tags"


    request do
      object :post do
        string :title
        string :content
        string :category, in: %w[tech business lifestyle]

        array :tags, :optional do
          string :_self
        end

        object :author do
          string :name
          string :email
        end
      end
    end

    response 201 do
      object :post do
        string :id, :required
        string :title, :required
        string :content, :required
        string :category, :required

        array :tags, :required do
          string :_self
        end

        object :author, :required do
          string :name, :required
          string :email, :required
        end

        time :created_at, :required
        time :updated_at, :required
      end
    end

    delegate_to Posts::Stable::CreateService
  end
end
```

## Multiple Versions Running Simultaneously

All versions run simultaneously. Clients can choose which version to use:

```ruby
# Client using version 1
GET /api/posts?version=1

# Client using version 2
GET /api/posts?version=2

# Client using version 3 (default)
GET /api/posts
```

Each version has its own:
- Request structure
- Response structure
- Validation rules
- Service delegation

## Migration Strategy

### Phase 1: Add New Version

```ruby
version 2 do
  summary "New version with breaking changes"
  # New structure
end

version 1, default: true do
  # Keep as default initially
end
```

### Phase 2: Switch Default

```ruby
version 2, default: true do
  # New version is now default
end

version 1 do
  deprecated true
  # Old version still works
end
```

### Phase 3: Remove Old Version

```ruby
version 2, default: true do
  # Only version remaining
end

# Version 1 removed completely
```

## Backward Compatibility

### Adding Fields (Non-Breaking)

```ruby
version 1 do
  response 200 do
    object :post do
      string :id
      string :title
    end
  end
end

version 2, default: true do
  response 200 do
    object :post do
      string :id
      string :title
      string :author  # New field - non-breaking
      time :created_at  # New field - non-breaking
    end
  end
end
```

### Changing Structure (Breaking)

```ruby
version 1 do
  response 200 do
    # Old structure
    object :post do
      string :author_name
    end
  end
end

version 2, default: true do
  response 200 do
    # New structure - breaking change
    object :post do
      object :author do
        string :name
        string :email
      end
    end
  end
end
```

### Field Renaming (Breaking)

```ruby
version 1 do
  request do
    object :post do
      string :title
      string :body  # Old name
    end
  end
end

version 2, default: true do
  request do
    object :post do
      string :title
      string :content  # New name - breaking change
    end
  end
end
```

## Version-Specific Services

Different versions can delegate to different services:

```ruby
version 1 do
  delegate_to Posts::V1::CreateService
end

version 2 do
  delegate_to Posts::V2::CreateService
end

version 3 do
  delegate_to Posts::Stable::CreateService
end
```

## Best Practices

### 1. Semantic Versioning for Breaking Changes

```ruby
version "1.0.0" do
  summary "Initial release"
end

version "1.1.0" do
  summary "Added optional fields"  # Minor - backward compatible
end

version "2.0.0" do
  summary "Changed response structure"  # Major - breaking change
end
```

### 2. Always Have a Default

```ruby
# Good
version 3, default: true do
  # Latest stable version as default
end

# Bad - no default specified
version 1 do; end
version 2 do; end
```

### 3. Deprecate Before Removing

```ruby
# Step 1: Add new version
version 2 do
  # New version
end

# Step 2: Deprecate old version
version 1, default: true do
  deprecated true
end

# Step 3: Make new version default
version 2, default: true do
end

version 1 do
  deprecated true
end

# Step 4: Remove old version (after transition period)
version 2, default: true do
end
```

### 4. Document Changes

```ruby
version 1 do
  summary "Initial release"
end

version 2 do
  summary "Added category field, changed author from string to object"
end

version 3 do
  summary "Added tags array and social links to author"
end
```

### 5. Use Environment Variables for Deprecation

```ruby
version 1 do
  deprecated lambda {
    # Automatically deprecate when app version reaches 3.0
    Gem::Version.new(ENV.fetch("APP_VERSION", "0.0.0")) >=
      Gem::Version.new("3.0.0")
  }
end
```

## Next Steps

- [Validation](./validation.md) - Validation across versions
- [Transformation](./transformation.md) - Data transformation between versions

[← Back to Documentation](./README.md)
