# Scopes

[← Back to Documentation](./README.md)

## What are Scopes?

Scopes are organizational units that group related attributes together. They create nested structures in your request and response data.

## Basic Scopes

### Single Scope

```ruby
request do
  scope :post do
    string :title, :required
    string :content, :required
  end
end
```

**Expected data structure:**
```ruby
{
  post: {
    title: "Hello",
    content: "World"
  }
}
```

### Multiple Scopes

```ruby
request do
  scope :post do
    string :title, :required
  end

  scope :filters do
    string :category
    array :tags do
      string :_self
    end
  end
end
```

**Expected data structure:**
```ruby
{
  post: {
    title: "Hello"
  },
  filters: {
    category: "tech",
    tags: ["ruby", "rails"]
  }
}
```

## Special `:_self` Scope

The `:_self` scope is special - its attributes are merged into the parent level instead of creating a nested structure.

### Root Level Attributes

```ruby
request do
  scope :_self do
    string :signature, :required
    string :timestamp, :required
  end

  scope :post do
    string :title, :required
  end
end
```

**Expected data structure:**
```ruby
{
  signature: "abc123",      # From :_self - at root level
  timestamp: "2024-01-01",  # From :_self - at root level
  post: {                   # Regular scope - nested
    title: "Hello"
  }
}
```

**Without `:_self` you would need:**
```ruby
{
  _self: {
    signature: "abc123",
    timestamp: "2024-01-01"
  },
  post: {
    title: "Hello"
  }
}
```

### Use Cases for `:_self`

**1. Authentication tokens at root:**
```ruby
request do
  scope :_self do
    string :api_key, :required
  end

  scope :data do
    string :message
  end
end

# Expects: { api_key: "...", data: { message: "..." } }
```

**2. Pagination params at root:**
```ruby
request do
  scope :_self do
    integer :page, default: 1
    integer :limit, default: 12
  end

  scope :filters do
    string :category
  end
end

# Expects: { page: 1, limit: 12, filters: { category: "..." } }
```

**3. Metadata in responses:**
```ruby
response 200 do
  scope :_self do
    string :request_id
    datetime :timestamp
  end

  scope :data do
    string :message
  end
end

# Returns: { request_id: "...", timestamp: "...", data: { message: "..." } }
```

## Empty Scopes

You can declare scopes without defining their internal structure.

```ruby
request do
  scope :post
  scope :filters
end
```

**Use cases:**
- With DIRECT strategy (no validation needed)
- When structure is validated elsewhere
- Placeholder for future definitions

## Scope Organization Patterns

### Pattern 1: Domain Grouping

Group attributes by domain entity:

```ruby
request do
  scope :user do
    string :name
    string :email
  end

  scope :post do
    string :title
    string :content
  end

  scope :settings do
    string :theme
    string :language
  end
end
```

### Pattern 2: Functionality Grouping

Group by functionality:

```ruby
request do
  scope :authentication do
    string :api_key
    string :signature
  end

  scope :pagination do
    integer :page
    integer :limit
  end

  scope :data do
    # Actual data
  end
end
```

### Pattern 3: Singular vs Plural

**Singular** for single objects:
```ruby
scope :post do
  string :title
end

scope :user do
  string :name
end
```

**Plural** for collections (usually in responses):
```ruby
scope :posts do
  string :id
  string :title
end

scope :users do
  string :id
  string :name
end
```

## Nested Scopes Through Objects

While you can't nest scopes directly, you can achieve nesting through objects:

```ruby
request do
  scope :post do
    string :title

    # Nested structure through object type
    object :author do
      string :name
      string :email

      object :company do
        string :name
        string :website
      end
    end
  end
end
```

## Scopes in Request vs Response

### Request Scopes

Organize incoming data:

```ruby
request do
  # Query parameters
  scope :filters do
    string :category
    string :status
  end

  # Body parameters
  scope :post do
    string :title
    string :content
  end

  # Pagination
  scope :_self do
    integer :page, default: 1
  end
end
```

### Response Scopes

Organize outgoing data:

```ruby
response 200 do
  # Main data
  scope :posts do
    string :id
    string :title
  end

  # Metadata
  scope :meta do
    integer :count
    integer :page
    integer :total_pages
  end

  # Related data
  scope :included do
    # Related resources
  end
end
```

## Multiple Request Blocks

You can define multiple `request` blocks that will be merged:

```ruby
# Query parameters
request do
  scope :filters do
    string :category
  end
end

# Header parameters
request do
  scope :_self do
    string :api_key
  end
end

# Body parameters
request do
  scope :post do
    string :title
  end
end

# All three are merged into single request definition
```

## Best Practices

### 1. Use Meaningful Names

```ruby
# Good
scope :post
scope :filters
scope :meta

# Bad
scope :data
scope :params
scope :stuff
```

### 2. Keep Scope Structure Flat

```ruby
# Good - flat structure with clear scopes
request do
  scope :post do
    string :title
  end

  scope :author do
    string :name
  end
end

# Avoid - use object instead for nesting
request do
  scope :post do
    scope :author do  # Don't nest scopes this way
      string :name
    end
  end
end

# Better - use object for nesting
request do
  scope :post do
    string :title

    object :author do
      string :name
    end
  end
end
```

### 3. Use `:_self` Sparingly

```ruby
# Good use of :_self - authentication/pagination at root
scope :_self do
  string :api_key
  integer :page
end

# Avoid - don't put too much in :_self
scope :_self do
  string :title
  string :content
  string :summary
  # ... too many attributes at root level
end
```

### 4. Consistent Naming Convention

```ruby
# Good - singular for single entity
scope :post do
  string :title
end

# Good - plural for collection
scope :posts do
  string :id
end

# Be consistent across your API
```

## Real-World Examples

### Index Endpoint

```ruby
version 3 do
  request do
    scope :filters do
      string :title, :optional
      string :summary, :optional
      string :description, :optional
    end
  end

  response 200 do
    scope :posts do
      string :id
      string :title
      string :summary
    end

    scope :meta do
      integer :count
      integer :page
      integer :limit, default: 12
    end
  end
end
```

### Create Endpoint

```ruby
version 3 do
  request do
    scope :_self do
      string :signature, :required
    end

    scope :post do
      string :title, :required
      string :content, :required

      object :author, :required do
        string :name, :required
      end
    end
  end

  response 201 do
    scope :post do
      string :id
      string :title
      string :content
      datetime :created_at
    end
  end
end
```

## Next Steps

- [Validation](./validation.md) - understand validation within scopes
- [Transformation](./transformation.md) - how scopes are transformed
- [Examples](./examples.md) - more practical examples

[← Back: Nested Structures](./nested-structures.md) | [← Back to Documentation](./README.md) | [Next: Validation →](./validation.md)
