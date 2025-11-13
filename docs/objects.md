# Objects

[← Back to Documentation](./README.md)

## What are Objects?

Objects group related attributes together, creating nested structures in your request and response data. Use the `object` attribute type to organize your API data into logical hierarchies.

## Basic Object Grouping

### Single Object

```ruby
request do
  object :post do
    string :title
    string :content
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

### Multiple Objects

```ruby
request do
  object :post do
    string :title
  end

  object :filters do
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

## Special `:_self` Object

The `:_self` object is special - its attributes are merged into the parent level instead of creating a nested structure.

### Root Level Attributes

```ruby
request do
  object :_self do
    string :signature
    string :timestamp
  end

  object :post do
    string :title
  end
end
```

**Expected data structure:**
```ruby
{
  signature: "abc123",      # From :_self - at root level
  timestamp: "2024-01-01",  # From :_self - at root level
  post: {                   # Regular object - nested
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
  object :_self do
    string :api_key
  end

  object :data do
    string :message
  end
end

# Expects: { api_key: "...", data: { message: "..." } }
```

**2. Pagination params at root:**
```ruby
request do
  object :_self do
    integer :page, default: 1
    integer :limit, default: 12
  end

  object :filters do
    string :category
  end
end

# Expects: { page: 1, limit: 12, filters: { category: "..." } }
```

**3. Metadata in responses:**
```ruby
response 200 do
  object :_self do
    string :request_id
    datetime :responded_at
  end

  object :data do
    string :message
  end
end

# Returns: { request_id: "...", responded_at: "...", data: { message: "..." } }
```

## Empty Objects

You can declare objects without defining their internal structure.

```ruby
request do
  object :post
  object :filters
end
```

**Use cases:**
- With DIRECT strategy (no validation needed)
- When structure is validated elsewhere
- Placeholder for future definitions

## Object Organization Patterns

### Pattern 1: Domain Grouping

Group attributes by domain entity:

```ruby
request do
  object :user do
    string :name
    string :email
  end

  object :post do
    string :title
    string :content
  end

  object :settings do
    string :theme
    string :language
  end
end
```

### Pattern 2: Functionality Grouping

Group by functionality:

```ruby
request do
  object :authentication do
    string :api_key
    string :signature
  end

  object :pagination do
    integer :page
    integer :limit
  end

  object :data do
    # Actual data
  end
end
```

### Pattern 3: Singular vs Plural

**Singular** for single object attributes:
```ruby
object :post do
  string :title
end

object :user do
  string :name
end
```

**Plural** for collections (usually in responses):
```ruby
array :posts do
  string :id
  string :title
end

object :users do
  string :id
  string :name
end
```

## Deeply Nested Objects

You can nest objects to create complex data structures:

```ruby
request do
  object :post do
    string :title

    # Nested objects create deeper structures
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

## Objects in Request vs Response

### Request Objects

Organize incoming data:

```ruby
request do
  # Query parameters
  object :filters do
    string :category
    string :status
  end

  # Body parameters
  object :post do
    string :title
    string :content
  end

  # Pagination
  object :_self do
    integer :page, default: 1
  end
end
```

### Response Objects

Organize outgoing data:

```ruby
response 200 do
  # Main data
  array :posts do
    string :id
    string :title
  end

  # Metadata
  object :meta do
    integer :count
    integer :page
    integer :total_pages
  end

  # Related data
  object :included do
    # Related resources
  end
end
```

## Multiple Request Blocks

You can define multiple `request` blocks that will be merged:

```ruby
# Query parameters
request do
  object :filters do
    string :category
  end
end

# Header parameters
request do
  object :_self do
    string :api_key
  end
end

# Body parameters
request do
  object :post do
    string :title
  end
end

# All three are merged into single request definition
```

## Best Practices

### 1. Use Meaningful Names

```ruby
# Good
object :post
object :filters
object :meta

# Bad
object :data
object :params
object :stuff
```

### 2. Organize Related Data Together

```ruby
# Good - clear grouping of related attributes
request do
  object :post do
    string :title
  end

  object :author do
    string :name
  end
end

# Good - nest related objects
request do
  object :post do
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
object :_self do
  string :api_key
  integer :page
end

# Avoid - don't put too much in :_self
object :_self do
  string :title
  string :content
  string :summary
  # ... too many attributes at root level
end
```

### 4. Consistent Naming Convention

```ruby
# Good - singular for single entity
object :post do
  string :title
end

# Good - plural for collection
array :posts do
  string :id
end

# Be consistent across your API
```

## Real-World Examples

### Index Endpoint

```ruby
version 3 do
  request do
    object :filters do
      string :title, :optional
      string :summary, :optional
      string :description, :optional
    end
  end

  response 200 do
    array :posts do
      string :id, :required
      string :title, :required
      string :summary, :required
    end

    object :meta do
      integer :count, :required
      integer :page, :required
      integer :limit, default: 12
    end
  end
end
```

### Create Endpoint

```ruby
version 3 do
  request do
    object :_self do
      string :signature
    end

    object :post do
      string :title
      string :content

      object :author do
        string :name
      end
    end
  end

  response 201 do
    object :post do
      string :id, :required
      string :title, :required
      string :content, :required
      datetime :created_at, :required
    end
  end
end
```

## Next Steps

- [Validation](./validation.md) - understand validation within objects
- [Transformation](./transformation.md) - how objects are transformed
- [Examples](./examples.md) - more practical examples

[← Back: Nested Structures](./nested-structures.md) | [← Back to Documentation](./README.md) | [Next: Validation →](./validation.md)
