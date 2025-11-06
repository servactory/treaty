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

Defines incoming data structure.

```ruby
request do
  scope :post do
    string :title, :required
    string :content, :required
  end
end
```

**Features:**
- Attributes are required by default
- Supports multiple scopes
- Validates types and options

### 5. Response

Defines outgoing data structure for a specific HTTP status.

```ruby
response 200 do
  scope :posts do
    string :id
    string :title
  end
end

response 201 do
  scope :post do
    string :id
  end
end
```

**Features:**
- Attributes are optional by default
- Each status has its own structure
- Supports default values

### 6. Scope

Groups related attributes.

```ruby
scope :post do
  string :title
  string :content
end

scope :meta do
  integer :count
  integer :page
end
```

**Special `:_self` scope:**

```ruby
scope :_self do
  string :signature
end
```

Attributes from `:_self` are merged into parent level (root).

### 7. Delegate To

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

## Key Principles

1. **Contract First** - Define the contract before implementation
2. **Version Everything** - Every change gets a new version
3. **Validate Early** - Catch errors at the contract level
4. **Transform Safely** - Ensure data consistency between versions
5. **Deprecate Gracefully** - Mark old versions as deprecated, don't delete

## Next Steps

- [Defining Contracts](./defining-contracts.md) - detailed treaty creation
- [Attributes](./attributes.md) - attribute types and options
- [Versioning](./versioning.md) - working with versions

[← Back: Getting Started](./getting-started.md) | [← Back to Documentation](./README.md) | [Next: Defining Contracts →](./defining-contracts.md)
