# Treaty Cheatsheet

[← Back to Documentation](./README.md)

Quick reference for common Treaty patterns and syntax.

## Basic Structure

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do
    strategy Treaty::Strategy::ADAPTER

    request do
      # Request definition
    end

    response 201 do
      # Response definition
    end

    delegate_to Posts::CreateService
  end
end
```

## Strategies

```ruby
# No validation - direct pass-through
strategy Treaty::Strategy::DIRECT

# Full validation and transformation
strategy Treaty::Strategy::ADAPTER
```

## Version Definition

```ruby
# Simple version
version 1 do; end

# Version with options
version 2, default: true do; end

# Semantic versioning
version "1.0.0" do; end
version "2.0.0", default: true do; end

# Deprecated version
version 1 do
  deprecated true
end

# Deprecated with condition
version 1 do
  deprecated lambda { ENV["APP_VERSION"] >= "3.0.0" }
end

# Version with summary
version 1 do
  summary "Initial release with basic features"
end
```

## Attribute Types

```ruby
string :name
integer :count
boolean :active
datetime :created_at
object :metadata do; end
array :items do; end
```

## Attribute Options - Helper Mode

```ruby
string :title, :required    # Must be present
string :summary, :optional  # Can be missing
```

## Attribute Options - Simple Mode

```ruby
# Required
string :title, required: true

# Default value
integer :page, default: 1
string :status, default: "draft"

# Inclusion (allowed values)
string :status, in: %w[draft published archived]
integer :rating, in: [1, 2, 3, 4, 5]

# Attribute renaming
string :handle, as: :value
```

## Attribute Options - Advanced Mode

```ruby
# Custom required message
string :title, required: {
  is: true,
  message: "Post title cannot be empty"
}

# Custom inclusion message
string :category, in: {
  list: %w[tech business lifestyle],
  message: "Please select a valid category"
}
```

## Scopes

```ruby
# Regular object
object :post do
  string :title
end

# Special :_self object (merges to parent level)
object :_self do
  integer :page
  integer :limit
end

# Multiple objects
object :post do
  string :title
end

object :filters do
  string :category
end

# Empty object (no structure)
object :metadata
```

## Objects (Nested Hashes)

```ruby
# Basic object
object :author do
  string :name, :required
  string :email
end

# Required object
object :author, :required do
  string :name, :required
end

# Optional object
object :settings, :optional do
  string :theme
end

# Deeply nested
object :post do
  object :author do
    object :company do
      string :name
    end
  end
end

# Empty object
object :metadata, :optional
```

## Arrays

```ruby
# Simple array (primitives)
array :tags do
  string :_self
end
# Data: ["ruby", "rails", "api"]

# Simple array with validation
array :tags do
  string :_self, in: %w[ruby rails api docker]
end

# Complex array (objects)
array :authors do
  string :name, :required
  string :email
end
# Data: [{ name: "John Doe", email: "..." }, { name: "John Doe", email: "..." }]

# Array with nested objects
array :posts do
  string :title

  object :author do
    string :name
  end
end

# Required array
array :tags, :required do
  string :_self
end

# Optional array
array :tags, :optional do
  string :_self
end
```

## Request Definition

```ruby
request do
  # Root-level attributes
  object :_self do
    integer :page, default: 1
    integer :limit, default: 12
  end

  # Data object
  object :post do
    string :title, :required
    string :content, :required
    string :status, default: "draft"
  end

  # Filters object
  object :filters do
    string :category, :optional
    datetime :created_after_at, :optional
  end
end
```

## Response Definition

```ruby
response 200 do
  object :posts do
    string :id
    string :title
    datetime :created_at
  end

  object :meta do
    integer :count
    integer :page
    integer :limit
  end
end

response 201 do
  object :post do
    string :id
    datetime :created_at
  end
end

response 404 do
  object :error do
    string :message
  end
end
```

## Delegation

```ruby
# Service class
delegate_to Posts::CreateService

# Lambda
delegate_to lambda { |params:|
  { result: params[:a] + params[:b] }
}

# With options
delegate_to Posts::CreateService, with: { user_id: :current_user_id }
```

## Controller Integration

```ruby
class PostsController < ApplicationController
  # Auto-discovers Posts::IndexTreaty
  treaty :index

  # Auto-discovers Posts::CreateTreaty
  treaty :create

  # Custom treaty class
  treaty :update, class_name: Posts::CustomUpdateTreaty

  def index
    # Treaty handles everything
  end
end
```

## Version Selection

```ruby
# URL parameter
GET /api/posts?version=2

# HTTP Header
GET /api/posts
Headers: API-Version: 2

# Accept Header
GET /api/posts
Headers: Accept: application/vnd.api+json; version=2

# Default version (if not specified)
version 2, default: true do; end
```

## Common Patterns

### Pagination

```ruby
object :_self do
  integer :page, default: 1
  integer :limit, default: 12
end

object :meta do
  integer :count
  integer :page
  integer :limit
  integer :total_pages
end
```

### Filtering

```ruby
object :filters do
  string :status, :optional, in: %w[draft published archived]
  string :category, :optional
  datetime :created_after_at, :optional
  datetime :created_before_at, :optional
end
```

### Sorting

```ruby
object :sort do
  string :by, default: "created_at", in: %w[created_at updated_at title]
  string :direction, default: "desc", in: %w[asc desc]
end
```

## Complete Examples

### Simple Index Endpoint

```ruby
class Posts::IndexTreaty < ApplicationTreaty
  version 1, default: true do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :filters do
        string :title, :optional
        string :category, :optional
      end
    end

    response 200 do
      object :posts do
        string :id
        string :title
        string :summary
      end

      object :meta do
        integer :count
        integer :page, default: 1
        integer :limit, default: 12
      end
    end

    delegate_to Posts::IndexService
  end
end
```

### Create Endpoint with Nested Structures

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :title, :required
        string :content, :required
        string :category, :required, in: %w[tech business lifestyle]
        boolean :published, :optional

        array :tags, :optional do
          string :_self, in: %w[ruby rails api docker]
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
        boolean :published

        array :tags do
          string :_self
        end

        object :author do
          string :name
          string :email
        end

        datetime :created_at
      end
    end

    delegate_to Posts::CreateService
  end
end
```

### Multi-Version API

```ruby
class Posts::ShowTreaty < ApplicationTreaty
  # Version 1: Simple, deprecated
  version 1 do
    deprecated true
    strategy Treaty::Strategy::DIRECT

    request { object :post }
    response(200) { object :post }

    delegate_to Posts::V1::ShowService
  end

  # Version 2: Current
  version 2, default: true do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :id, :required
      end
    end

    response 200 do
      object :post do
        string :id
        string :title
        string :content

        object :author do
          string :name
          string :email
        end

        datetime :created_at
      end
    end

    delegate_to Posts::Stable::ShowService
  end
end
```

## Validation Errors

```ruby
# Required field
"Attribute 'title' is required but was not provided"

# Type mismatch
"Attribute 'rating' must be an Integer, got String"

# Inclusion validation
"Attribute 'status' must be one of: draft, published, archived. Got: 'deleted'"

# Object validation
"Attribute 'author' must be a Hash (object), got String"

# Array validation
"Error in array 'tags' at index 2: Attribute 'tags' must be a String, got Integer"
```

## Configuration

```ruby
# config/initializers/treaty.rb
Treaty::Engine.configure do |config|
  config.treaty.attribute_nesting_level = 3
end
```

## Testing

```ruby
RSpec.describe Posts::CreateTreaty do
  subject(:perform) { described_class.call!(version: version, params: params) }

  context "when validating required fields" do
    let(:version) { "1" }
    let(:params) { { post: {} } }

    it "raises validation error" do
      expect { perform }.to raise_error(Treaty::Exceptions::Validation)
    end
  end

  context "when creating post successfully" do
    let(:version) { "1" }
    let(:params) { { post: { title: "Test", content: "Content" } } }

    it "returns post with expected attributes" do
      expect(perform.data[:post]).to include(:id, :title, :content)
    end
  end
end
```

## Quick Tips

- Use `:required` and `:optional` helpers for clarity
- ADAPTER for production, DIRECT only for prototypes
- Always mark one version as `default: true`
- Use `:_self` object for root-level attributes
- Keep nesting shallow (max 5 levels recommended)
- Deprecate versions before removing them
- Test both old and new versions during migration

## Next Steps

- [Getting Started](./getting-started.md) - detailed tutorial
- [API Reference](./api-reference.md) - complete API docs
- [Examples](./examples.md) - more examples

[← Back to Documentation](./README.md)
