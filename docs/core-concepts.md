# Core Concepts

[← Back to Documentation](./README.md)

## What is a Treaty?

A Treaty (contract) is a formal definition of the data structure for an API endpoint. A contract describes:

- What data the endpoint accepts (request)
- What data the endpoint returns (response)
- How data is validated and transformed
- Which service handles the request

## Main Components

### 1. Treaty Class

Inherits from `Treaty::Base` and defines the contract for a specific action.

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  # Version definitions
end
```

**Naming:**
- Located in `app/treaties/[namespace]/[controller]/[action]_treaty.rb`
- Class named `[Action]Treaty`
- Example: `Posts::CreateTreaty` for `posts#create`

### 2. Version

Each contract can have multiple versions. A version defines a specific contract implementation.

```ruby
version 1 do
  # Version 1 definition
end

version 2, default: true do
  # Version 2 definition (default)
end
```

**Version formats:**
- Numeric: `1`, `2`, `3`
- Semantic: `"1.0.0"`, `"2.1.0"`
- With labels: `"1.0.0.rc1"`, `[1, 0, 0, :rc1]`

### 3. Strategy

Strategy defines how data is processed.

#### DIRECT Strategy

Direct data passing without validation and transformation.

```ruby
strategy Treaty::Strategy::DIRECT
```

**Use cases:**
- Quick prototypes
- Simple endpoints without complex logic
- When service validates data itself

#### ADAPTER Strategy

Full data validation and transformation.

```ruby
strategy Treaty::Strategy::ADAPTER
```

**Use cases:**
- Production API
- When strict validation is needed
- Working with multiple versions
- Data transformation between versions

### 4. Request

Defines incoming data structure. Can be defined using a block or an Entity class.

**Using a block:**
```ruby
request do
  object :post do
    string :title
    string :content
  end
end
```

**Using an Entity class:**
```ruby
request PostRequestEntity
```

**Features:**
- Attributes are required by default
- Supports multiple objects
- Validates types and options
- Can be defined inline or as reusable Entity classes

**Internal Architecture:**
When using a block, Treaty creates an anonymous `Request::Entity` class dynamically and evaluates the block within it. This means request blocks and Entity classes use the same underlying system, ensuring consistent behavior.

### 5. Response

Defines outgoing data structure for a specific HTTP status. Can be defined using a block or an Entity class.

**Using a block:**
```ruby
response 200 do
  array :posts do
    string :id
    string :title
  end
end

response 201 do
  object :post do
    string :id
  end
end
```

**Using an Entity class:**
```ruby
response 201, PostResponseEntity
```

**Features:**
- Attributes are optional by default
- Each status has its own structure
- Supports default values
- Can be defined inline or as reusable Entity classes

**Internal Architecture:**
When using a block, Treaty creates an anonymous `Response::Entity` class dynamically and evaluates the block within it. This unified architecture means both blocks and Entity classes share the same validation and transformation logic.

### 6. Objects

Groups related attributes.

```ruby
object :post do
  string :title
  string :content
end

object :meta do
  integer :count
  integer :page
end
```

**Special `:_self` object:**

```ruby
object :_self do
  string :signature
end
```

Attributes from `:_self` are merged into parent level (root).

### 7. Entity Classes (DTOs)

Reusable data structure definitions that can be used across multiple treaties and versions.

```ruby
class PostEntity < Treaty::Entity
  string :id
  string :title
  string :content
  datetime :created_at
end
```

**Use in treaties:**
```ruby
version 1 do
  request PostRequestEntity
  response 201, PostResponseEntity
end
```

**Features:**
- Attributes are required by default (like request blocks)
- Reusable across multiple versions and treaties
- Better code organization and maintainability
- Support all attribute types and options

See [Entity Classes (DTOs)](./entities.md) for detailed documentation.

### 8. Delegate To

Specifies where to pass request processing.

**Service:**
```ruby
delegate_to Posts::CreateService
delegate_to "Posts::CreateService"
delegate_to "posts/create_service"
```

**Lambda:**
```ruby
delegate_to lambda { |params:|
  # Process locally
  params
}
```

**With options:**
```ruby
delegate_to Posts::CreateService => :call, return: lambda(&:data)
```

## Request Lifecycle

```
1. HTTP Request → Controller
2. Treaty determines version
3. Request Validation (validate incoming data)
4. Request Transformation (transform incoming data)
5. Delegate To Service (pass to service)
6. Service Execution (service processes request)
7. Response Validation (validate service output)
8. Response Transformation (transform output data)
9. HTTP Response → Client
```

## Deprecation

Marking a version as deprecated:

```ruby
version 1 do
  deprecated true
  # or
  deprecated { Time.current > Time.zone.parse("2024-12-31") }
  # or
  deprecated lambda { ENV["RELEASE_VERSION"] >= "2.0.0" }
end
```

## Summary

Adding description to a version:

```ruby
version 2 do
  summary "Added author support to posts"
  # ...
end
```

## Data Flow Example

```ruby
# Client sends:
{ "filters" => { "title" => "Ruby" } }

# Treaty validates against request definition

# Treaty passes to service:
{ filters: { title: "Ruby" } }

# Service returns:
{ posts: [...], meta: { count: 10, page: 1 } }

# Treaty validates against response definition

# Treaty transforms and returns:
{ "posts" => [...], "meta" => { "count" => 10, "page" => 1, "limit" => 12 } }
```

## Internal Architecture

Understanding how Treaty works internally can help you use it more effectively.

### Unified Entity System

Treaty uses a unified entity-based architecture for all attribute definitions:

1. **Treaty::Entity** - Base class for user-defined DTOs (required by default)
2. **Treaty::RequestEntity** - Internal class for request blocks (required by default)
3. **Treaty::ResponseEntity** - Internal class for response blocks (optional by default)

All three share the same DSL (`Treaty::Attribute::DSL`) and attribute system, ensuring consistent behavior.

### Request/Response Blocks

When you write:
```ruby
request do
  string :title
end
```

Treaty automatically:
1. Creates an anonymous `RequestEntity` class
2. Evaluates your block in that class's context
3. Uses the resulting attribute collection for validation

This means blocks and Entity classes are equivalent under the hood!

### Attribute System

```
Treaty::Attribute::DSL
  ↓
Treaty::Entity (required: true)
  ↓
├── Your DTOs
├── RequestEntity (for request blocks)
└── ResponseEntity (for response blocks)
```

### Factory Pattern

Request and Response factories:
- Accept blocks (creates anonymous entity)
- Accept Entity classes (uses directly)
- Provide `collection_of_attributes` for validators
- Ensure consistent validation regardless of definition method

## Key Principles

1. **Contract First** - Define the contract before implementation
2. **Version Everything** - Every change gets a new version
3. **Validate Early** - Catch errors at the contract level
4. **Transform Safely** - Ensure data consistency between versions
5. **Deprecate Gracefully** - Mark old versions as deprecated, don't delete
6. **Unified System** - Blocks and Entity classes use the same underlying architecture

## Next Steps

- [Defining Contracts](./defining-contracts.md) - detailed treaty creation
- [Attributes](./attributes.md) - attribute types and options
- [Versioning](./versioning.md) - working with versions

[← Back: Getting Started](./getting-started.md) | [← Back to Documentation](./README.md) | [Next: Defining Contracts →](./defining-contracts.md)
