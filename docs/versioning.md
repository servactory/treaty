# Versioning

[← Back to Documentation](./README.md)

## Overview

Treaty provides powerful versioning capabilities for your API. Each treaty can have multiple versions running simultaneously, allowing you to evolve your API without breaking existing clients.

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

    strategy Treaty::Strategy::DIRECT

    request { object :post }
    response(201) { object :post }

    delegate_to Posts::V1::CreateService
  end

  # Version 2: Added validation and new fields
  version 2 do
    summary "Added validation and category support"
    deprecated lambda { ENV["APP_VERSION"] >= "3.0" }

    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :title, :required
        string :content, :required
        string :category, :optional, in: %w[tech business lifestyle]
      end
    end

    response 201 do
      object :post do
        string :id
        string :title
        string :content
        string :category
        datetime :created_at
      end
    end

    delegate_to Posts::Stable::CreateService
  end

  # Version 3: Added author and tags
  version 3, default: true do
    summary "Added author information and tags"

    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :title, :required
        string :content, :required
        string :category, :required, in: %w[tech business lifestyle]

        array :tags, :optional do
          string :_self
        end

        object :author, :required do
          string :name, :required
          string :email, :required
        end
      end
    end

    response 201 do
      object :post do
        string :id
        string :title
        string :content
        string :category

        array :tags do
          string :_self
        end

        object :author do
          string :name
          string :email
        end

        datetime :created_at
        datetime :updated_at
      end
    end

    delegate_to Posts::Stable::CreateService
  end
end
```

## Strategies Across Versions

Different versions can use different strategies:

```ruby
version 1 do
  strategy Treaty::Strategy::DIRECT
  # Fast, no validation - for MVP
end

version 2 do
  strategy Treaty::Strategy::ADAPTER
  # Full validation - for production
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
      datetime :created_at  # New field - non-breaking
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

Or use the same service with adapters:

```ruby
version 1 do
  strategy Treaty::Strategy::DIRECT
  delegate_to Posts::CreateService
end

version 2 do
  strategy Treaty::Strategy::ADAPTER
  delegate_to Posts::CreateService  # Same service, different strategy
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

- [Strategies](./strategies.md) - understand DIRECT vs ADAPTER strategies
- [Validation](./validation.md) - validation across versions
- [Transformation](./transformation.md) - data transformation between versions

[← Back: Examples](./examples.md) | [← Back to Documentation](./README.md) | [Next: Strategies →](./strategies.md)
