# Entity Classes (DTOs)

[← Back to Documentation](./README.md)

## What are Entity Classes?

Entity classes (also known as DTOs - Data Transfer Objects) are reusable class definitions that can be used in multiple treaty definitions. They provide a way to define data structures once and reuse them across different versions and treaties.

**Important:** Entity classes and request/response blocks use the same underlying system. When you define a request or response with a block, Treaty creates an anonymous Entity class internally. This unified architecture ensures consistent behavior whether you use blocks or explicit Entity classes.

## Benefits of Entity Classes

1. **Reusability** - Define once, use in multiple places
2. **Maintainability** - Update in one place, changes propagate everywhere
3. **Organization** - Keep related data structures together
4. **Type Safety** - Enforce consistent data structures across your API
5. **Testing** - Test data structures independently

## Creating Entity Classes

Entity classes inherit from `Treaty::Entity`:

```ruby
class PostEntity < Treaty::Entity
  string :id
  string :title
  string :content
  datetime :created_at
end
```

Place entity classes in `app/entities/` or `app/dtos/` directory.

## Attribute Defaults in Entities

**Important:** Entity attributes have different defaults than request/response blocks:

- **Entities**: All attributes are **required by default**
- **Request blocks**: All attributes are **required by default**
- **Response blocks**: All attributes are **optional by default**

```ruby
class UserEntity < Treaty::Entity
  string :name        # required by default
  string :email       # required by default
  string :bio, :optional  # explicitly optional
end
```

## Using Entity Classes in Treaties

Entity classes can be used directly in request and response definitions:

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    strategy Treaty::Strategy::ADAPTER

    request PostRequestEntity
    response 201, PostResponseEntity

    delegate_to Posts::CreateService
  end
end
```

## Request and Response Entities

It's common to have separate entities for requests and responses:

```ruby
# Request entity - what client sends
class PostRequestEntity < Treaty::Entity
  string :title
  string :content
  string :summary, :optional
end

# Response entity - what server returns
class PostResponseEntity < Treaty::Entity
  string :id
  string :title
  string :content
  string :summary
  datetime :created_at
  datetime :updated_at
end
```

## Organizing Entity Classes

### By Direction (Recommended)

```
app/dtos/
├── serialization/         # Response DTOs (outgoing data)
│   └── posts/
│       ├── index_dto.rb
│       └── show_dto.rb
└── deserialization/       # Request DTOs (incoming data)
    └── posts/
        ├── create_dto.rb
        └── update_dto.rb
```

**Example:**

```ruby
# app/dtos/deserialization/posts/create_dto.rb
module Deserialization
  module Posts
    class CreateDto < ApplicationDto
      object :post do
        string :title
        string :content
        string :summary, :optional
      end
    end
  end
end

# app/dtos/serialization/posts/show_dto.rb
module Serialization
  module Posts
    class ShowDto < ApplicationDto
      object :post do
        string :id
        string :title
        string :content
        string :summary
        datetime :created_at
      end
    end
  end
end
```

### By Domain

```
app/entities/
├── posts/
│   ├── post_entity.rb
│   ├── comment_entity.rb
│   └── author_entity.rb
└── users/
    ├── user_entity.rb
    └── profile_entity.rb
```

## Nested Structures

Entity classes support nested objects and arrays:

```ruby
class PostEntity < Treaty::Entity
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
```

## Combining Blocks and Entities

You can mix entity classes with inline block definitions:

```ruby
version 1 do
  strategy Treaty::Strategy::ADAPTER

  # Use entity class for request
  request PostRequestEntity

  # Use block definition for response
  response 201 do
    object :post do
      string :id
      string :title
    end
  end

  delegate_to Posts::CreateService
end
```

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
| `Treaty::Entity` | `true` | User-defined DTOs |
| `Treaty::Request::Entity` | `true` | Request blocks |
| `Treaty::Response::Entity` | `false` | Response blocks |

This is why request blocks default to required and response blocks default to optional.

## Complete Example

**Entity Definitions:**

```ruby
# app/dtos/application_dto.rb
class ApplicationDto < Treaty::Entity
end

# app/dtos/deserialization/posts/create_dto.rb
module Deserialization
  module Posts
    class CreateDto < ApplicationDto
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

# app/dtos/serialization/posts/create_dto.rb
module Serialization
  module Posts
    class CreateDto < ApplicationDto
      object :post do
        string :id
        string :title
        string :content
        string :summary
        boolean :published
        datetime :created_at
        datetime :updated_at

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
    strategy Treaty::Strategy::ADAPTER

    request Deserialization::Posts::CreateDto
    response 201, Serialization::Posts::CreateDto

    delegate_to Posts::CreateService
  end

  version 2 do
    strategy Treaty::Strategy::ADAPTER

    # Reuse the same DTOs in multiple versions
    request Deserialization::Posts::CreateDto
    response 201, Serialization::Posts::CreateDto

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

  # Nested with options
  object :price, :optional do
    integer :amount
    string :currency, default: "USD"
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
class PostEntity < Treaty::Entity
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

# Get entity information
info = PostEntity.info
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
PostEntity.treaty?
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

document_entity(PostEntity)
# Output:
# Entity: PostEntity
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
RSpec.describe PostEntity do
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

compare_entities(PostRequestEntity, PostResponseEntity)
```

### Comparison with Treaty::Base.info

While `Treaty::Entity.info` returns entity attribute metadata, `Treaty::Base.info` (for REST API treaties) returns version-based contract information:

| Feature | Treaty::Entity.info | Treaty::Base.info |
|---------|---------------------|-------------------|
| **Returns** | `Treaty::Info::Entity::Result` | `Treaty::Info::Rest::Result` |
| **Primary attribute** | `.attributes` (Hash) | `.versions` (Array) |
| **Use case** | DTO structure introspection | API version and contract details |
| **Contains** | Attribute types, options, nesting | Versions, strategies, executors, request/response specs |

**Example of Treaty::Base.info:**

```ruby
class Posts::IndexTreaty < ApplicationTreaty
  version 1 do
    strategy Treaty::Strategy::ADAPTER
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
#     strategy: :adapter,
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

2. **Namespace by Domain** - Group related entities together
   ```ruby
   module Posts
     class CreateRequestDto < ApplicationDto
     end
   end
   ```

3. **Use Descriptive Names** - Make entity purpose clear
   - Good: `PostCreateRequestDto`, `UserProfileResponseDto`
   - Avoid: `PostDto`, `Data`, `Params`

4. **Separate Request/Response** - Different entities for input and output
   - Request entities validate incoming data
   - Response entities define outgoing structure

5. **Keep Entities Simple** - Don't add business logic to entity classes
   ```ruby
   # Good - just structure
   class PostEntity < Treaty::Entity
     string :title
     string :content
   end

   # Bad - business logic in entity
   class PostEntity < Treaty::Entity
     string :title

     def formatted_title
       title.upcase
     end
   end
   ```

6. **Document Complex Structures** - Add comments for nested or complex entities
   ```ruby
   class OrderEntity < Treaty::Entity
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
version 2 do
  request Deserialization::Posts::CreateDto
  response 201, Serialization::Posts::CreateDto
end
```

## Next Steps

- [Attributes](./attributes.md) - learn about attribute types and options
- [Nested Structures](./nested-structures.md) - working with complex data
- [Validation](./validation.md) - data validation system
- [Examples](./examples.md) - practical usage examples

[← Back to Documentation](./README.md) | [Next: Validation →](./validation.md)
