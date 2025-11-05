# Treaty Documentation

Treaty is a Ruby library for defining and managing REST API contracts with versioning support.

## What does Treaty do?

Treaty allows you to:

- **Define API contracts** for requests and responses
- **Version your API** with support for multiple concurrent versions
- **Validate data** on input (request) and output (response)
- **Transform data** between different API versions
- **Manage deprecated versions** with explicit deprecation markers
- **Delegate processing** to services or lambda functions

## Core Concepts

### Contract (Treaty)

A contract defines the data structure for a specific API endpoint. Each contract can have multiple versions.

### Version

Each contract version describes:
- Request structure (input data)
- Response structure (output data) for various HTTP statuses
- Data processing strategy
- Which service handles the processing

### Strategies

- **DIRECT** - direct data passing without transformation
- **ADAPTER** - data adaptation between versions with validation and transformation

## Documentation Structure

### Core Documentation

1. [Getting Started](./getting-started.md) - start working with Treaty
2. [Core Concepts](./core-concepts.md) - fundamental concepts and terms
3. [Defining Contracts](./defining-contracts.md) - how to create treaties
4. [Versioning](./versioning.md) - working with API versions
5. [Attributes](./attributes.md) - attribute types and options
6. [Validation](./validation.md) - data validation system
7. [Transformation](./transformation.md) - data transformation
8. [Strategies](./strategies.md) - DIRECT vs ADAPTER
9. [Nested Structures](./nested-structures.md) - working with objects and arrays
10. [Scopes](./scopes.md) - organizing data through scopes

### Additional Resources

11. [Examples](./examples.md) - practical usage examples
12. [API Reference](./api-reference.md) - complete API reference
13. [Cheatsheet](./cheatsheet.md) - quick reference guide
14. [Migration Guide](./migration-guide.md) - migrating between API versions
15. [Troubleshooting](./troubleshooting.md) - common issues and solutions

## Quick Example

```ruby
class PostsController < ApplicationController
  treaty :create
end

class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    strategy Treaty::Strategy::ADAPTER

    request do
      scope :post do
        string :title, :required
        string :content, :required
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

    delegate_to Posts::CreateService
  end
end
```

## Links

- [GitHub Repository](https://github.com/servactory/treaty)
- [Changelog](../CHANGELOG.md)
