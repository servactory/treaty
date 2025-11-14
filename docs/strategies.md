# Strategies

[← Back to Documentation](./README.md)

## Overview

This guide explains the two processing strategies in Treaty: DIRECT and ADAPTER. Learn when to use each strategy, how they differ in performance and validation, and best practices for production APIs.

Treaty supports two processing strategies that determine how requests and responses are handled:

- **DIRECT** - Direct pass-through without validation or transformation
- **ADAPTER** - Full validation and transformation pipeline

## DIRECT Strategy

### What It Does

DIRECT strategy passes data directly to your service without validation or transformation.

```ruby
version 1 do
  strategy Treaty::Strategy::DIRECT

  request { object :post }
  response(201) { object :post }

  delegate_to Posts::CreateService
end
```

### How It Works

```
Client Request
    ↓
    No validation
    No transformation
    ↓
Service (receives raw data)
    ↓
    No validation
    No transformation
    ↓
Client Response
```

### When to Use DIRECT

**Use DIRECT when:**

1. **Prototyping** - Quick MVP development
2. **Service validates** - Your service already handles validation
3. **Performance critical** - You need maximum speed
4. **Simple contracts** - Minimal validation needed
5. **Internal APIs** - Trusted consumers only

### Example

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    strategy Treaty::Strategy::DIRECT

    # Just declare objects, no validation
    request { object :post }
    response(201) { object :post }

    delegate_to Posts::CreateService
  end
end
```

**Request:**
```ruby
{ "post" => { "title" => "Hello", "content" => "World" } }
```

**Passed to service as-is:**
```ruby
{ "post" => { "title" => "Hello", "content" => "World" } }
```

**Service returns:**
```ruby
{ "post" => { "id" => 1, "title" => "Hello", "content" => "World" } }
```

**Response to client as-is:**
```ruby
{ "post" => { "id" => 1, "title" => "Hello", "content" => "World" } }
```

### Limitations

- No request validation
- No response validation
- No type checking
- No default values
- No data transformation
- No attribute renaming (`as:` option ignored)

## ADAPTER Strategy

### What It Does

ADAPTER strategy provides full validation and transformation pipeline.

```ruby
version 2 do
  strategy Treaty::Strategy::ADAPTER

  request do
    object :post do
      string :title
      string :content
      string :summary, :optional
    end
  end

  response 201 do
    object :post do
      string :id
      string :title
      string :content
      datetime :created_at
    end
  end

  delegate_to Posts::Stable::CreateService
end
```

### How It Works

```
Client Request
    ↓
Request Validation
    - Type checking
    - Required fields
    - Inclusion validation
    - Nested validation
    ↓
Request Transformation
    - Apply defaults
    - Rename attributes (as:)
    - Transform nested structures
    ↓
Service (receives validated & transformed data)
    ↓
Response Validation
    - Type checking
    - Structure validation
    - Nested validation
    ↓
Response Transformation
    - Apply defaults
    - Rename attributes (as:)
    - Transform nested structures
    ↓
Client Response
```

### When to Use ADAPTER

**Use ADAPTER when:**

1. **Production APIs** - Strict validation required
2. **Multiple versions** - Need data transformation between versions
3. **Public APIs** - Untrusted consumers
4. **Complex validation** - Nested structures, type safety
5. **Data consistency** - Ensure data integrity

### Example

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 2 do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :title
        string :content
        integer :rating, :optional, in: [1, 2, 3, 4, 5]

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
        integer :rating
        object :author, :required do
          string :name, :required
          string :email, :required
        end
        datetime :created_at, :required
      end
    end

    delegate_to Posts::Stable::CreateService
  end
end
```

**Request:**
```ruby
{
  "post" => {
    "title" => "Hello",
    "content" => "World",
    "rating" => 5,
    "author" => {
      "name" => "John Doe",
      "email" => "johndoe@example.com"
    }
  }
}
```

**Validation happens:**
- `title` is String ✓
- `content` is String ✓
- `rating` is Integer ✓
- `rating` is in [1,2,3,4,5] ✓
- `author` is Hash ✓
- `author.name` is String ✓
- `author.email` is String ✓

**Passed to service (validated):**
```ruby
{
  post: {
    title: "Hello",
    content: "World",
    rating: 5,
    author: {
      name: "John Doe",
      email: "johndoe@example.com"
    }
  }
}
```

**Invalid request fails:**
```ruby
{
  "post" => {
    "title" => "Hello",
    # Missing required 'content'
    "rating" => 6,  # Not in allowed values
    "author" => "John Doe"  # Should be object, not string
  }
}

# Raises:
# Treaty::Exceptions::Validation: Attribute 'content' is required but was not provided
```

### Features

- ✅ Request validation
- ✅ Response validation
- ✅ Type checking
- ✅ Default values
- ✅ Data transformation
- ✅ Attribute renaming (`as:` option)
- ✅ Nested validation
- ✅ Inclusion validation

## Comparison

| Feature | DIRECT | ADAPTER |
|---------|--------|---------|
| Request validation | ❌ | ✅ |
| Response validation | ❌ | ✅ |
| Type checking | ❌ | ✅ |
| Required fields | ❌ | ✅ |
| Default values | ❌ | ✅ |
| Attribute renaming | ❌ | ✅ |
| Inclusion validation | ❌ | ✅ |
| Nested validation | ❌ | ✅ |
| Performance | Fast | Slower |
| Safety | Low | High |
| Best for | Prototypes, MVPs | Production |

## Validation Examples

### Type Validation (ADAPTER only)

```ruby
request do
  object :post do
    integer :rating
  end
end

# Valid
{ rating: 5 } ✓

# Invalid
{ rating: "5" } ✗  # String instead of Integer
# Raises: Attribute 'rating' must be an Integer, got String
```

### Required Validation (ADAPTER only)

```ruby
request do
  object :post do
    string :title
  end
end

# Valid
{ title: "Hello" } ✓

# Invalid
{} ✗  # Missing required field
# Raises: Attribute 'title' is required but was not provided
```

### Inclusion Validation (ADAPTER only)

```ruby
request do
  object :post do
    string :status, in: %w[draft published archived]
  end
end

# Valid
{ status: "draft" } ✓

# Invalid
{ status: "deleted" } ✗  # Not in allowed values
# Raises: Attribute 'status' must be one of: draft, published, archived. Got: 'deleted'
```

## Transformation Examples

### Default Values (ADAPTER only)

```ruby
response 200 do
  object :meta do
    integer :page, default: 1
    integer :limit, default: 12
  end
end

# Service returns:
{ meta: { page: 2 } }

# Client receives (with default applied):
{ "meta" => { "page" => 2, "limit" => 12 } }
```

### Attribute Renaming (ADAPTER only)

```ruby
request do
  object :social do
    string :handle, as: :value
  end
end

# Client sends:
{ "social" => { "handle" => "alice" } }

# Service receives:
{ social: { value: "alice" } }
```

## Mixing Strategies

Different versions can use different strategies:

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  # Version 1: Quick MVP with DIRECT
  version 1 do
    strategy Treaty::Strategy::DIRECT
    request { object :post }
    response(201) { object :post }
    delegate_to Posts::V1::CreateService
  end

  # Version 2: Production-ready with ADAPTER
  version 2, default: true do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :title
        string :content
      end
    end

    response 201 do
      object :post do
        string :id
        string :title
        string :content
        datetime :created_at
      end
    end

    delegate_to Posts::Stable::CreateService
  end
end
```

## Performance Considerations

### DIRECT Performance

```ruby
# DIRECT: ~0.1ms
- No validation
- No transformation
- Direct pass-through
```

### ADAPTER Performance

```ruby
# ADAPTER: ~2-5ms (depending on complexity)
- Request validation
- Request transformation
- Service execution
- Response validation
- Response transformation
```

**Note:** ADAPTER overhead is minimal (1-4ms) and worth it for production APIs.

## Best Practices

### 1. Use ADAPTER in Production

```ruby
# Good for production
version 1, default: true do
  strategy Treaty::Strategy::ADAPTER
  # Full validation
end
```

### 2. Use DIRECT for Rapid Prototyping

```ruby
# OK for MVP/prototype
version 1 do
  strategy Treaty::Strategy::DIRECT
  # Quick iteration
end

# Then upgrade to ADAPTER for production
version 2, default: true do
  strategy Treaty::Strategy::ADAPTER
  # Production-ready
end
```

### 3. Start with DIRECT, Migrate to ADAPTER

```ruby
# Phase 1: MVP
version 1 do
  strategy Treaty::Strategy::DIRECT
  # Fast development
end

# Phase 2: Production
version 2 do
  strategy Treaty::Strategy::ADAPTER
  # Add full validation
end
```

### 4. Use ADAPTER for Public APIs

```ruby
# Public API - always use ADAPTER
class PublicAPI::PostsController
  treaty :create

  class CreateTreaty < ApplicationTreaty
    version 1, default: true do
      strategy Treaty::Strategy::ADAPTER
      # Strict validation for untrusted clients
    end
  end
end
```

### 5. DIRECT Only for Trusted Internal APIs

```ruby
# Internal API - DIRECT may be acceptable
class InternalAPI::PostsController
  treaty :create

  class CreateTreaty < ApplicationTreaty
    version 1 do
      strategy Treaty::Strategy::DIRECT
      # Service validates, trusted consumers
    end
  end
end
```

## Next Steps

- [Validation](./validation.md) - Detailed validation system
- [Transformation](./transformation.md) - Data transformation details
- [Examples](./examples.md) - Practical examples

[← Back to Documentation](./README.md)
