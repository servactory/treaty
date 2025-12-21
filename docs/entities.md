# Entity Classes

[← Back to Documentation](./README.md)

## Overview

Entity classes are reusable data structure definitions that can be used across multiple treaties and versions. This guide covers creating entities, organizing them, using the introspection `.info` method, and best practices for maintainable API design.

**Important:** Entity classes and request/response blocks use the same underlying system. When you define a request or response with a block, Treaty creates an anonymous Entity class internally. This unified architecture ensures consistent behavior whether you use blocks or explicit Entity classes.

## What are Entity Classes?

Entity classes are reusable class definitions that can be used in multiple treaty definitions. They provide a way to define data structures once and reuse them across different versions and treaties.

## Benefits of Entity Classes

1. **Reusability** - Define once, use in multiple places
2. **Maintainability** - Update in one place, changes propagate everywhere
3. **Organization** - Keep related data structures together
4. **Type Safety** - Enforce consistent data structures across your API
5. **Testing** - Test data structures independently

## Creating Entity Classes

Entity classes inherit from `Treaty::Entity`:

```ruby
module Posts
  module Create
    class ResponseEntity < Treaty::Entity
      string :id
      string :title
      string :content
      time :created_at
    end
  end
end
```

Place entity classes in `app/entities/` directory with domain-based structure.

## Attribute Defaults in Entities

**Important:** Entity attributes have different defaults than request/response blocks:

- **Entities**: All attributes are **required by default**
- **Request blocks**: All attributes are **required by default**
- **Response blocks**: All attributes are **optional by default**

```ruby
module Users
  module Create
    class ResponseEntity < Treaty::Entity
      string :name        # required by default
      string :email       # required by default
      string :bio, :optional  # explicitly optional
    end
  end
end
```

## Using Entity Classes in Treaties

Entity classes can be used directly in request and response definitions:

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do

    request Posts::Create::RequestEntity
    response 201, Posts::Create::ResponseEntity

    delegate_to Posts::CreateService
  end
end
```

## Request and Response Entities

It's common to have separate entities for requests and responses:

```ruby
# app/entities/posts/create/request_entity.rb
module Posts
  module Create
    class RequestEntity < Treaty::Entity
      string :title
      string :content
      string :summary, :optional
    end
  end
end

# app/entities/posts/create/response_entity.rb
module Posts
  module Create
    class ResponseEntity < Treaty::Entity
      string :id
      string :title
      string :content
      string :summary
      time :created_at
      time :updated_at
    end
  end
end
```

## Organizing Entity Classes

### By Domain and Action (Recommended)

```
app/entities/
├── application_entity.rb    # Base class
├── shared/
│   ├── author_entity.rb     # Shared entities
│   └── social_entity.rb
├── posts/
│   ├── create/
│   │   ├── request_entity.rb
│   │   └── response_entity.rb
│   └── index/
│       ├── request_entity.rb
│       └── response_entity.rb
└── users/
    └── create/
        ├── request_entity.rb
        └── response_entity.rb
```

**Example:**

```ruby
# app/entities/application_entity.rb
class ApplicationEntity < Treaty::Entity
end

# app/entities/posts/create/request_entity.rb
module Posts
  module Create
    class RequestEntity < ApplicationEntity
      object :post do
        string :title
        string :content
        string :summary, :optional
      end
    end
  end
end

# app/entities/posts/create/response_entity.rb
module Posts
  module Create
    class ResponseEntity < ApplicationEntity
      object :post do
        string :id
        string :title
        string :content
        string :summary
        time :created_at
      end
    end
  end
end

# app/entities/shared/author_entity.rb
module Shared
  class AuthorEntity < ApplicationEntity
    string :name
    string :bio, :optional
  end
end
```

## Nested Structures

Entity classes support nested objects and arrays:

```ruby
module Posts
  module Show
    class ResponseEntity < Treaty::Entity
      string :id
      string :title
      string :content

      object :author do
        string :name
        string :bio

        array :socials, :optional do
          string :provider
          string :url
        end
      end

      array :tags, :optional do
        string :_self  # Simple array of strings
      end
    end
  end
end
```

## Combining Blocks and Entities

You can mix entity classes with inline block definitions:

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do

    # Use entity class for request
    request Posts::Create::RequestEntity

    # Use block definition for response
    response 201 do
      object :post do
        string :id
        string :title
      end
    end

    delegate_to Posts::CreateService
  end
end
```

## Using Entities in Nested Blocks

You can reuse Entity classes within nested `object` or `array` blocks using `use_entity`:

```ruby
# Define reusable entities in app/entities/shared/
# app/entities/shared/author_entity.rb
module Shared
  class AuthorEntity < ApplicationEntity
    string :name
    string :bio, :optional
  end
end

# app/entities/shared/social_entity.rb
module Shared
  class SocialEntity < ApplicationEntity
    string :provider, in: %w[twitter linkedin github]
    string :handle
  end
end

# Use entities in nested blocks
version 1 do
  request do
    object :post do
      string :title
      string :content

      # Reuse Shared::AuthorEntity inside the author object
      object :author do
        use_entity(Shared::AuthorEntity)
      end

      # Reuse Shared::SocialEntity inside the socials array
      array :socials, :optional do
        use_entity(Shared::SocialEntity)
      end
    end
  end

  response 201 do
    object :post do
      string :id
      string :title

      object :author do
        use_entity(Shared::AuthorEntity)
      end
    end
  end

  delegate_to Posts::CreateService
end
```

### Constraints

When using `use_entity` in nested blocks:

1. **Must be the only statement** - You cannot mix `use_entity` with other attribute definitions in the same block
2. **Entity class only** - The argument must be a `Treaty::Entity` subclass
3. **Options preserved** - All attribute options from the Entity (validation, transformation) are preserved

```ruby
# WRONG: Cannot mix use_entity with other attributes
object :author do
  use_entity(Shared::AuthorEntity)
  string :extra_field  # Error!
end

# CORRECT: Only use_entity in the block
object :author do
  use_entity(Shared::AuthorEntity)
end
```

### When to Use

Use `use_entity` in nested blocks when:

- The same nested structure appears in multiple places
- You want to maintain a single source of truth for the structure
- The nested structure is complex enough to warrant its own class

## Internal Architecture

Understanding how Entity classes work internally:

### The DSL Module

All entity-like classes (Entity, Request::Entity, Response::Entity) include `Treaty::Attribute::DSL`, which provides:
- `attribute(name, type, *helpers, **options, &block)` - Define attributes
- `collection_of_attributes` - Access defined attributes
- `method_missing` - Support type-first syntax (`string :name`)

### Request and Response Blocks

When you write a request or response block:
```ruby
request do
  string :title
end
```

Treaty automatically:
1. Creates `Class.new(Request::Entity)` (or `Response::Entity` for responses)
2. Calls `instance_eval(&block)` on the anonymous class
3. Uses the class's `collection_of_attributes` for validation

This means **blocks and Entity classes are functionally equivalent** - they use the exact same validation and transformation logic!

### Default Behaviors

Different entity types have different defaults:

| Type | Default Required | Use Case |
|------|-----------------|----------|
| `Treaty::Entity` | `true` | User-defined entities |
| `Treaty::Request::Entity` | `true` | Request blocks |
| `Treaty::Response::Entity` | `false` | Response blocks |

This is why request blocks default to required and response blocks default to optional.

## Complete Example

**Entity Definitions:**

```ruby
# app/entities/application_entity.rb
class ApplicationEntity < Treaty::Entity
end

# app/entities/posts/create/request_entity.rb
module Posts
  module Create
    class RequestEntity < ApplicationEntity
      object :post do
        string :title
        string :content
        string :summary, :optional
        boolean :published, :optional

        object :author do
          string :name
          string :email
        end

        array :tags, :optional do
          string :_self
        end
      end
    end
  end
end

# app/entities/posts/create/response_entity.rb
module Posts
  module Create
    class ResponseEntity < ApplicationEntity
      object :post do
        string :id
        string :title
        string :content
        string :summary
        boolean :published
        time :created_at
        time :updated_at

        object :author do
          string :id
          string :name
          string :email
        end

        array :tags do
          string :_self
        end
      end
    end
  end
end
```

**Treaty Using Entities:**

```ruby
# app/treaties/posts/create_treaty.rb
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do

    request Posts::Create::RequestEntity
    response 201, Posts::Create::ResponseEntity

    delegate_to Posts::CreateService
  end

  version 2 do

    # Reuse the same entities in multiple versions
    request Posts::Create::RequestEntity
    response 201, Posts::Create::ResponseEntity

    delegate_to Posts::V2::CreateService
  end
end
```

## Attribute Options in Entities

Entity classes support all standard attribute options:

```ruby
class ProductEntity < Treaty::Entity
  string :id
  string :name
  string :sku, :optional

  # Default values
  integer :quantity, default: 0
  boolean :in_stock, default: true

  # Attribute transformation
  string :product_code, as: :code

  # Validation
  string :category, in: %w[electronics clothing food]

  # Computed values (derive from other attributes)
  string :display_name, :optional, computed: (lambda do |**attributes|
    "#{attributes.dig(:name)} (#{attributes.dig(:sku) || 'N/A'})"
  end)

  # Nested with options
  object :price, :optional do
    integer :amount
    string :currency, default: "USD"

    # Computed formatted price
    string :formatted, :optional, computed: (lambda do |**attributes|
      amount = attributes.dig(:price, :amount) || 0
      currency = attributes.dig(:price, :currency) || "USD"
      "#{currency} #{format('%.2f', amount / 100.0)}"
    end)
  end
end
```

## Introspection with .info Method

Entity classes provide a `.info` class method that returns metadata about the entity's structure. This is useful for:
- Auto-generating documentation
- Building introspection tools
- Creating web interfaces for API exploration
- Testing entity structure

### Usage

```ruby
module Posts
  module Show
    class ResponseEntity < Treaty::Entity
      string :id
      string :title
      string :content, :optional

      object :author do
        string :name
        string :email
      end

      array :tags, :optional do
        string :_self
      end
    end
  end
end

# Get entity information
info = Posts::Show::ResponseEntity.info
# => #<Treaty::Info::Entity::Result>

# Access attributes metadata
info.attributes
# => {
#   id: {
#     type: :string,
#     options: { required: { is: true, message: nil } },
#     attributes: {}
#   },
#   title: {
#     type: :string,
#     options: { required: { is: true, message: nil } },
#     attributes: {}
#   },
#   content: {
#     type: :string,
#     options: { required: { is: false, message: nil } },
#     attributes: {}
#   },
#   author: {
#     type: :object,
#     options: { required: { is: true, message: nil } },
#     attributes: {
#       name: {
#         type: :string,
#         options: { required: { is: true, message: nil } },
#         attributes: {}
#       },
#       email: {
#         type: :string,
#         options: { required: { is: true, message: nil } },
#         attributes: {}
#       }
#     }
#   },
#   tags: {
#     type: :array,
#     options: { required: { is: false, message: nil } },
#     attributes: {
#       _self: {
#         type: :string,
#         options: { required: { is: true, message: nil } },
#         attributes: {}
#       }
#     }
#   }
# }
```

### Return Structure

The `.info` method returns a `Treaty::Info::Entity::Result` object with:

**`attributes`** - Hash containing metadata for each attribute:
- **`type`** (Symbol) - Attribute type (`:string`, `:integer`, `:boolean`, `:datetime`, `:object`, `:array`)
- **`options`** (Hash) - Attribute options including:
  - `required: { is: Boolean, message: String|nil }` - Required validation
  - `inclusion: { in: Array, message: String|nil }` - Inclusion validation (when using `in:` option)
  - `default: Any` - Default value (when specified)
  - `as: Symbol` - Transformation alias (when using `as:` option)
- **`attributes`** (Hash) - Nested attributes (for `:object` and `:array` types, empty hash otherwise)

### Check if Class is a Treaty Entity

```ruby
Posts::Show::ResponseEntity.treaty?
# => true

String.respond_to?(:treaty?)
# => false
```

### Practical Examples

**Example 1: Generate API documentation**

```ruby
def document_entity(entity_class)
  return unless entity_class.respond_to?(:treaty?) && entity_class.treaty?

  info = entity_class.info

  puts "Entity: #{entity_class.name}"
  puts "Attributes:"

  info.attributes.each do |name, metadata|
    required = metadata[:options][:required][:is] ? "required" : "optional"
    puts "  - #{name} (#{metadata[:type]}, #{required})"

    if metadata[:attributes].any?
      puts "    Nested attributes: #{metadata[:attributes].keys.join(', ')}"
    end
  end
end

document_entity(Posts::Show::ResponseEntity)
# Output:
# Entity: Posts::Show::ResponseEntity
# Attributes:
#   - id (string, required)
#   - title (string, required)
#   - content (string, optional)
#   - author (object, required)
#     Nested attributes: name, email
#   - tags (array, optional)
#     Nested attributes: _self
```

**Example 2: Validate entity structure in tests**

```ruby
RSpec.describe Posts::Show::ResponseEntity do
  it "has expected structure" do
    info = described_class.info

    expect(info).to be_a(Treaty::Info::Entity::Result)
    expect(info.attributes.keys).to match_array([:id, :title, :content, :author, :tags])

    # Check specific attribute
    expect(info.attributes[:title]).to match(
      type: :string,
      options: hash_including(required: { is: true, message: nil }),
      attributes: {}
    )

    # Check nested structure
    expect(info.attributes[:author][:attributes].keys).to match_array([:name, :email])
  end
end
```

**Example 3: Compare Entity classes**

```ruby
def compare_entities(entity_a, entity_b)
  attrs_a = entity_a.info.attributes.keys
  attrs_b = entity_b.info.attributes.keys

  common = attrs_a & attrs_b
  only_a = attrs_a - attrs_b
  only_b = attrs_b - attrs_a

  puts "Common attributes: #{common.join(', ')}"
  puts "Only in #{entity_a.name}: #{only_a.join(', ')}"
  puts "Only in #{entity_b.name}: #{only_b.join(', ')}"
end

compare_entities(Posts::Create::RequestEntity, Posts::Create::ResponseEntity)
```

### Comparison with Treaty::Base.info

While `Treaty::Entity.info` returns entity attribute metadata, `Treaty::Base.info` (for REST API treaties) returns version-based contract information:

| Feature | Treaty::Entity.info | Treaty::Base.info |
|---------|---------------------|-------------------|
| **Returns** | `Treaty::Info::Entity::Result` | `Treaty::Info::Rest::Result` |
| **Primary attribute** | `.attributes` (Hash) | `.versions` (Array) |
| **Use case** | Entity structure introspection | API version and contract details |
| **Contains** | Attribute types, options, nesting | Versions, executors, request/response specs |

**Example of Treaty::Base.info:**

```ruby
class Posts::IndexTreaty < ApplicationTreaty
  version 1 do
    request { object :filters }
    response(200) { array :posts }
    delegate_to Posts::IndexService
  end
end

info = Posts::IndexTreaty.info
# => #<Treaty::Info::Rest::Result>

info.versions
# => [
#   {
#     version: "1",
#     segments: [1],
#     default: true,
#     summary: nil,
#     deprecated: false,
#     executor: { executor: Posts::IndexService, method: :call },
#     request: { attributes: { ... } },
#     response: { status: 200, attributes: { ... } }
#   }
# ]
```

## Best Practices

1. **One Entity Per File** - Keep entity definitions focused and manageable

2. **Namespace by Domain and Action** - Use domain-based structure
   ```ruby
   module Posts
     module Create
       class RequestEntity < ApplicationEntity
       end
     end
   end
   ```

3. **Use Descriptive Names** - Make entity purpose clear
   - Good: `Posts::Create::RequestEntity`, `Users::Profile::ResponseEntity`
   - Avoid: `PostEntity`, `Data`, `Params`

4. **Separate Request/Response** - Different entities for input and output
   - Request entities validate incoming data
   - Response entities define outgoing structure

5. **Keep Entities Simple** - Don't add business logic to entity classes
   ```ruby
   # Good - just structure
   module Posts
     module Create
       class ResponseEntity < Treaty::Entity
         string :title
         string :content
       end
     end
   end

   # Bad - business logic in entity
   module Posts
     module Create
       class ResponseEntity < Treaty::Entity
         string :title

         def formatted_title
           title.upcase
         end
       end
     end
   end
   ```

6. **Document Complex Structures** - Add comments for nested or complex entities
   ```ruby
   module Orders
     module Create
       class ResponseEntity < Treaty::Entity
         # Customer information
         object :customer do
           string :email
           string :name
         end

         # Array of order items
         array :items do
           string :product_id
           integer :quantity
         end
       end
     end
   end
   ```

## Migration from Blocks to Entities

If you have existing treaty definitions using blocks, you can gradually migrate to entities:

**Before (using blocks):**
```ruby
version 1 do
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
    end
  end
end
```

**After (using entities):**
```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 2 do
    request Posts::Create::RequestEntity
    response 201, Posts::Create::ResponseEntity
  end
end
```

## Next Steps

- [Attributes](./attributes.md) - Learn about attribute types and options
- [Nested Structures](./nested-structures.md) - Working with complex data
- [Validation](./validation.md) - Data validation system
- [Examples](./examples.md) - Practical usage examples

[← Back to Documentation](./README.md)