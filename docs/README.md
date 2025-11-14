# Treaty Documentation

## Overview

Treaty is a Ruby library for defining and managing REST API contracts with versioning support. This documentation provides comprehensive guides for all Treaty features, from basic setup to advanced usage patterns.

## What Treaty Does

Treaty allows you to:

- **Define API contracts** - Specify request and response structures
- **Version your API** - Support multiple concurrent API versions
- **Validate data** - Automatically validate inputs and outputs
- **Transform data** - Seamlessly adapt data between versions
- **Manage deprecation** - Mark versions as deprecated with flexible conditions
- **Delegate processing** - Route to services or lambda functions

## Key Concepts

**Contract (Treaty)** - Defines the data structure for a specific API endpoint. Each contract can have multiple versions.

**Version** - Each version describes request structure, response structure, processing strategy, and service delegation.

**Strategies**:
- **DIRECT** - Direct data passing without transformation
- **ADAPTER** - Full validation and transformation pipeline

## Documentation Structure

### Core Documentation

1. [Getting Started](./getting-started.md) - Installation and basic setup
2. [Core Concepts](./core-concepts.md) - Fundamental concepts and architecture
3. [Defining Contracts](./defining-contracts.md) - Creating and configuring treaties
4. [Attributes](./attributes.md) - Attribute types and options
5. [Nested Structures](./nested-structures.md) - Objects and arrays
6. [Objects](./objects.md) - Organizing data with object attributes
7. [Entity Classes (DTOs)](./entities.md) - Reusable data transfer objects
8. [Validation](./validation.md) - Data validation system
9. [Transformation](./transformation.md) - Data transformation pipeline
10. [Strategies](./strategies.md) - DIRECT vs ADAPTER strategies
11. [Versioning](./versioning.md) - API version management

### Additional Resources

12. [Examples](./examples.md) - Real-world usage examples
13. [API Reference](./api-reference.md) - Complete API documentation
14. [Cheatsheet](./cheatsheet.md) - Quick reference guide
15. [Migration Guide](./migration-guide.md) - API version migration strategies
16. [Internationalization](./internationalization.md) - I18n and multilingual support
17. [Troubleshooting](./troubleshooting.md) - Common issues and solutions

## Quick Example

```ruby
class PostsController < ApplicationController
  treaty :create
end

class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
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

    delegate_to Posts::CreateService
  end
end
```

## Links

- [GitHub Repository](https://github.com/servactory/treaty)
- [Changelog](../CHANGELOG.md)
