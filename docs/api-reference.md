# API Reference

[← Back to Documentation](./README.md)

## Overview

This document provides a complete reference for all Treaty DSL methods and configuration options.

## Treaty Class Definition

### Basic Structure

```ruby
class MyTreaty < ApplicationTreaty
  version VERSION_NUMBER do
    # Version configuration
  end
end
```

### Introspection Methods

Treaty classes provide class methods for introspection and metadata access:

**`.info` - Get treaty metadata:**

```ruby
class Posts::IndexTreaty < ApplicationTreaty
  version 1 do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :filters do
        string :title, :optional
      end
    end

    response 200 do
      array :posts do
        string :id
        string :title
      end
    end

    delegate_to Posts::IndexService
  end
end

# Get treaty information
info = Posts::IndexTreaty.info
# => #<Treaty::Info::Rest::Result>

# Access versions metadata
info.versions
# => [
#   {
#     version: "1",
#     segments: [1],
#     default: true,
#     strategy: :adapter,
#     summary: nil,
#     deprecated: false,
#     executor: {
#       executor: Posts::IndexService,
#       method: :call
#     },
#     request: {
#       attributes: {
#         filters: {
#           type: :object,
#           options: { required: { is: false, message: nil } },
#           attributes: {
#             title: {
#               type: :string,
#               options: { required: { is: false, message: nil } },
#               attributes: {}
#             }
#           }
#         }
#       }
#     },
#     response: {
#       status: 200,
#       attributes: {
#         posts: {
#           type: :array,
#           options: { required: { is: false, message: nil } },
#           attributes: { ... }
#         }
#       }
#     }
#   }
# ]
```

**`.info` method returns:**
- `Treaty::Info::Rest::Result` object with `.versions` method
- Array of version objects, each containing:
  - `version` (String) - Version number
  - `segments` (Array) - Version segments
  - `default` (Boolean) - Whether this is the default version
  - `strategy` (Symbol) - Strategy (`:direct` or `:adapter`)
  - `summary` (String|nil) - Version summary text
  - `deprecated` (Boolean) - Deprecation status
  - `executor` (Hash) - Executor class and method
  - `request` (Hash) - Request attributes structure
  - `response` (Hash) - Response status and attributes structure

**`.treaty?` - Check if class is a Treaty:**

```ruby
Posts::IndexTreaty.treaty?
# => true

String.respond_to?(:treaty?)
# => false
```

**Use cases:**
- Auto-generating API documentation
- Building introspection tools and web interfaces
- Creating API explorers and test tools
- Validating treaty structure in tests

## Version Definition

### `version`

Define an API version.

**Syntax:**
```ruby
version number, options = {} do
  # Version configuration
end
```

**Parameters:**
- `number` - Version identifier (Integer, Float, String, or Array)
- `options` - Optional hash with:
  - `:default` (Boolean) - Mark as default version

**Examples:**
```ruby
# Numeric versions
version 1 do; end
version 2 do; end
version 3, default: true do; end

# Semantic versioning
version "1.0.0" do; end
version "2.0.0", default: true do; end

# Pre-release versions
version "1.0.0.rc1" do; end
version [1, 0, 0, :beta1] do; end
```

## Version Configuration

### `strategy`

Set the processing strategy for the version.

**Syntax:**
```ruby
strategy Treaty::Strategy::DIRECT
strategy Treaty::Strategy::ADAPTER
```

**Options:**
- `Treaty::Strategy::DIRECT` - No validation or transformation
- `Treaty::Strategy::ADAPTER` - Full validation and transformation

**Example:**
```ruby
version 1 do
  strategy Treaty::Strategy::ADAPTER
end
```

### `summary`

Add a human-readable description to the version.

**Syntax:**
```ruby
summary "Description of this version"
```

**Example:**
```ruby
version 1 do
  summary "Initial release with basic post management"
end
```

### `deprecated`

Mark a version as deprecated.

**Syntax:**
```ruby
deprecated boolean_or_proc
```

**Examples:**
```ruby
# Simple boolean
version 1 do
  deprecated true
end

# With block
version 1 do
  deprecated do
    Time.current > Time.zone.parse("2024-12-31")
  end
end

# With lambda
version 1 do
  deprecated lambda {
    Gem::Version.new(ENV.fetch("APP_VERSION", "0.0.0")) >= Gem::Version.new("3.0.0")
  }
end
```

### `delegate_to`

Specify the service or lambda to handle the request.

**Syntax:**
```ruby
delegate_to ServiceClass
delegate_to(lambda do |params:| ... end)
```

**Examples:**
```ruby
# Service class
version 1 do
  delegate_to Posts::CreateService
end

# Lambda
version 1 do
  delegate_to(lambda do |params:|
    { result: params[:a] + params[:b] }
  end)
end
```

## Request Definition

### `request`

Define the structure of incoming requests. Can use a block or an Entity class.

**Syntax with block:**
```ruby
request do
  # Attribute definitions
end
```

**Syntax with Entity class:**
```ruby
request EntityClassName
```

**Examples:**

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
request Deserialization::Posts::CreateDto
```

**Multiple request blocks (will be merged):**
```ruby
request do
  object :filters do
    string :category
  end
end

request do
  object :post do
    string :title
  end
end
```

**Note:** Attributes in request blocks are **required by default**.

## Response Definition

### `response`

Define the structure of outgoing responses. Can use a block or an Entity class.

**Syntax with block:**
```ruby
response status_code do
  # Attribute definitions
end
```

**Syntax with Entity class:**
```ruby
response status_code, EntityClassName
```

**Parameters:**
- `status_code` (Integer) - HTTP status code (200, 201, 404, etc.)

**Examples:**

**Using a block:**
```ruby
response 200 do
  object :post do
    string :id
    string :title
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

**Using an Entity class:**
```ruby
response 200, Serialization::Posts::IndexDto
response 201, Serialization::Posts::CreateDto
```

**Note:** Attributes in response blocks are **optional by default**.

## Entity Class Definition

### `Treaty::Entity`

Base class for creating reusable DTO (Data Transfer Object) classes.

**Syntax:**
```ruby
class MyEntity < Treaty::Entity
  # Attribute definitions
end
```

**Example:**
```ruby
class PostEntity < Treaty::Entity
  string :id
  string :title
  string :content, :optional
  datetime :created_at

  object :author do
    string :name
    string :email
  end

  array :tags, :optional do
    string :_self
  end
end
```

**Usage in treaties:**
```ruby
version 1 do
  request PostRequestEntity
  response 201, PostResponseEntity
end
```

**Features:**
- Attributes are **required by default** (like request blocks)
- Supports all attribute types (string, integer, boolean, datetime, object, array)
- Supports all attribute options (required, optional, default, as, in)
- Can be used in both request and response definitions
- Reusable across multiple versions and treaties

**Best Practices:**
- Place entities in `app/entities/` or `app/dtos/` directory
- Use descriptive names (e.g., `PostRequestEntity`, `UserResponseDto`)
- Separate request and response entities
- Use `ApplicationEntity` or `ApplicationDto` as base class

**Example structure:**
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
      end
    end
  end
end
```

**Introspection Methods:**

Entity classes provide class methods for introspection:

```ruby
# Get entity metadata
info = PostEntity.info
# => #<Treaty::Info::Entity::Result>

info.attributes
# => {
#   id: { type: :string, options: {...}, attributes: {} },
#   title: { type: :string, options: {...}, attributes: {} },
#   ...
# }

# Check if class is a Treaty entity
PostEntity.treaty?
# => true
```

**`.info` method returns:**
- `Treaty::Info::Entity::Result` object with `.attributes` method
- Attribute metadata including type, options, and nested attributes
- Useful for auto-generating documentation and introspection

See [Entity Classes (DTOs)](./entities.md) for detailed documentation, including the [Introspection with .info Method](./entities.md#introspection-with-info-method) section.

## Object Definition

### `object`

Define an object attribute to group related attributes.

**Syntax:**
```ruby
object :name do
  # Attribute definitions
end

# Empty object (no structure defined)
object :name
```

**Parameters:**
- `:name` - Symbol representing the object name
- Special object: `:_self` - Merges attributes to parent level

**Examples:**
```ruby
# Regular object
object :post do
  string :title
end

# Special :_self object
object :_self do
  integer :page, default: 1
  integer :limit, default: 12
end

# Empty object
object :metadata
```

## Attribute Types

### `string`

Define a string attribute.

**Syntax:**
```ruby
string :name, *modes, **options
```

**Examples (Request - required by default):**
```ruby
string :title
string :title, :optional
string :title, default: "Untitled"
string :title, in: %w[draft published archived]
string :title, as: :post_title
string :category, required: { is: true, message: "Category is required" }
```

**Examples (Response - optional by default):**
```ruby
string :title
string :title, :required
string :title, default: "Untitled"
```

### `integer`

Define an integer attribute.

**Syntax:**
```ruby
integer :name, *modes, **options
```

**Examples (Request - required by default):**
```ruby
integer :count
integer :page
integer :limit, default: 12
integer :rating, in: [1, 2, 3, 4, 5]
integer :age, as: :user_age
```

**Examples (Response - optional by default):**
```ruby
integer :count
integer :page, :required
integer :limit, default: 12
```

### `boolean`

Define a boolean attribute.

**Syntax:**
```ruby
boolean :name, *modes, **options
```

**Examples (Request - required by default):**
```ruby
boolean :published
boolean :active
boolean :featured, :optional
boolean :archived, default: false
```

**Examples (Response - optional by default):**
```ruby
boolean :published
boolean :active
boolean :archived, default: false
```

**Note:** Only accepts `true` or `false` (TrueClass/FalseClass). Does not perform type coercion.

### `datetime`

Define a datetime attribute.

**Syntax:**
```ruby
datetime :name, *modes, **options
```

**Examples (Request - required by default):**
```ruby
datetime :created_at
datetime :published_at, :optional
datetime :expires_at, default: -> { Time.now + 1.day }
```

**Examples (Response - optional by default):**
```ruby
datetime :created_at
datetime :published_at
datetime :updated_at, :required
```

### `object`

Define a nested object (hash) attribute.

**Syntax:**
```ruby
object :name, *modes, **options do
  # Nested attribute definitions
end

# Empty object (no structure defined)
object :name, *modes, **options
```

**Examples (Request - required by default):**
```ruby
# Object with structure
object :author do
  string :name
  string :email
  string :bio, :optional
end

# Empty object
object :metadata, :optional

# Deeply nested
object :post do
  string :title

  object :author do
    string :name

    object :company do
      string :name
    end
  end
end
```

**Examples (Response - optional by default):**
```ruby
# Object with structure
object :author do
  string :name
  string :email
  string :bio
end

# Empty object
object :metadata

# Deeply nested
object :post do
  string :title

  object :author do
    string :name

    object :company do
      string :name
    end
  end
end
```

### `array`

Define an array attribute.

**Syntax:**
```ruby
# Simple array (primitives)
array :name, *modes, **options do
  TYPE :_self, *modes, **options
end

# Complex array (objects)
array :name, *modes, **options do
  # Attribute definitions for each array item
end

# Empty array (no structure defined)
array :name, *modes, **options
```

**Examples (Request - required by default):**
```ruby
# Simple array of strings
array :tags, :optional do
  string :_self
end

# Complex array of objects
array :authors do
  string :name
  string :email
end

# Nested arrays
array :posts do
  string :title

  array :comments do
    string :text
    string :author_name
  end
end

# Empty array
array :items, :optional
```

**Examples (Response - optional by default):**
```ruby
# Simple array of strings
array :tags do
  string :_self
end

# Complex array of objects
array :authors do
  string :name
  string :email
end

# Empty array
array :items
```

## Attribute Options

### Helper Mode

Use symbols for simple definitions:

```ruby
:required  # Attribute must be present and not empty
:optional  # Attribute can be missing or nil
```

**Request examples (required by default):**
```ruby
string :title
string :summary, :optional
integer :count
```

**Response examples (optional by default):**
```ruby
string :title
string :summary, :required
integer :count
```

### Simple Mode Options

#### `required`

Make attribute required.

**Type:** Boolean
**Default:** Request = false, Response = false

```ruby
string :title, required: true
string :email, required: false
```

#### `optional`

Make attribute optional (explicit).

**Type:** Boolean
**Default:** Request = false, Response = false

```ruby
string :summary, optional: true
```

#### `default`

Set default value if attribute is missing.

**Type:** Any value or Proc
**Default:** nil

```ruby
integer :page, default: 1
string :status, default: "draft"
datetime :created_at, default: -> { Time.now }
```

**Note:** Cannot be used with `object` or `array` types.

#### `as`

Rename attribute during transformation.

**Type:** Symbol
**Default:** nil

```ruby
# Request: client 'username' → service 'login'
string :username, as: :login

# Response: service 'internal_id' → client 'id'
string :internal_id, as: :id
```

#### `in`

Restrict values to a list (inclusion validation).

**Type:** Array
**Default:** nil

```ruby
string :status, in: %w[draft published archived]
integer :rating, in: [1, 2, 3, 4, 5]
string :priority, in: %w[low medium high urgent]
```

#### `format`

Validate string values match specific formats. **Only works with string type.**

**Type:** Symbol
**Default:** nil

```ruby
string :email, format: :email
string :birth_date, format: :date
string :external_id, format: :uuid
string :session_duration, format: :duration
```

**Supported formats:**
- `:uuid` - UUID format (8-4-4-4-12 hexadecimal)
- `:email` - RFC 2822 email address
- `:password` - Password (8-16 chars, digit+lowercase+uppercase)
- `:date` - ISO 8601 date (e.g., "2025-01-15")
- `:datetime` - ISO 8601 datetime (e.g., "2025-01-15T10:30:00Z")
- `:time` - Time string (e.g., "10:30:00")
- `:duration` - ISO 8601 duration (e.g., "PT2H", "P1D")
- `:boolean` - Boolean string ("true", "false", "0", "1")

### Advanced Mode Options

For custom error messages (static or dynamic) and fine-grained control:

#### `required`

**Type:** Hash with `:is` and `:message` (String or Lambda)

**Static message:**
```ruby
string :title, required: {
  is: true,
  message: "Post title cannot be empty"
}
```

**Lambda message:**
```ruby
string :title, required: {
  is: true,
  message: lambda do |attribute:, value:, **|
    "The #{attribute} field is mandatory (received: #{value.inspect})"
  end
}
```

**Lambda arguments:**
- `attribute` - Symbol: The attribute name
- `value` - Object: The current value

#### `inclusion`

**Type:** Hash with `:in` and `:message` (String or Lambda)

**Static message:**
```ruby
string :category, inclusion: {
  in: %w[tech business lifestyle],
  message: "Please select a valid category"
}

integer :rating, inclusion: {
  in: [1, 2, 3, 4, 5],
  message: "Rating must be between 1 and 5 stars"
}
```

**Lambda message:**
```ruby
string :category, inclusion: {
  in: %w[tech business lifestyle],
  message: lambda do |attribute:, value:, allowed_values:, **|
    "Invalid #{attribute}: '#{value}'. Must be one of: #{allowed_values.join(', ')}"
  end
}
```

**Lambda arguments:**
- `attribute` - Symbol: The attribute name
- `value` - Object: The invalid value
- `allowed_values` - Array: List of valid values

#### `default` (Advanced Mode)

**Type:** Hash with `:is` and `:message`

```ruby
integer :limit, default: {
  is: 12,
  message: nil  # Message not used for defaults
}
```

**Note:** The `message` parameter is available but not used for error handling since default assignment cannot fail.

#### `as` (Advanced Mode)

**Type:** Hash with `:is` and `:message`

```ruby
string :username, as: {
  is: :login,
  message: nil  # Message not used for renaming
}
```

**Note:** The `message` parameter is available but not used for error handling since renaming cannot fail.

#### `format` (Advanced Mode)

**Type:** Hash with `:is` and `:message` (String or Lambda)

**Static message:**
```ruby
string :email, format: {
  is: :email,
  message: "Invalid email address"
}

string :password, format: {
  is: :password,
  message: "Password must be 8-16 characters with digit, lowercase, and uppercase"
}
```

**Lambda message:**
```ruby
string :password, format: {
  is: :password,
  message: lambda do |attribute:, value:, format_name:, **|
    "#{attribute.to_s.capitalize} must match #{format_name} format (got: #{value})"
  end
}
```

**Lambda arguments:**
- `attribute` - Symbol: The attribute name
- `value` - Object: The invalid value
- `format_name` - Symbol: The format name (e.g., :email, :uuid)

## Configuration

### Global Configuration

```ruby
# config/initializers/treaty.rb
Treaty::Engine.configure do |config|
  config.version = lambda do |controller|
    # Your logic for determining the version number
  end

  config.attribute_nesting_level = 3
end
```

### Nesting Level

Controls how deeply attributes can be nested.

**Default:** 5 levels

**Example:**
```ruby
# Level 1
object :post do
  # Level 2
  object :author do
    # Level 3
    array :socials do
      # Level 4
      object :metadata do
        string :provider
        # Level 5
        object :details do
          string :url
          # Level 6 would raise error!
        end
      end
    end
  end
end
```

## Controller Integration

### `treaty`

Define which action uses a treaty.

**Syntax:**
```ruby
treaty :action_name
```

**Examples:**
```ruby
class PostsController < ApplicationController
  # Uses Posts::IndexTreaty
  # Automatically creates the index action
  treaty :index

  # Uses Posts::CreateTreaty
  # Automatically creates the create action
  treaty :create
end
```

## Version Selection

Treaty determines the version from these sources (in priority order):

### 1. URL Parameter

```ruby
GET /api/posts?version=2
```

### 2. HTTP Header

```ruby
GET /api/posts
Headers:
  API-Version: 2
```

### 3. Accept Header

```ruby
GET /api/posts
Headers:
  Accept: application/vnd.api+json; version=2
```

### 4. Default Version

If no version is specified, uses the version marked with `default: true`.

## Exception Handling

### Validation Exceptions

**`Treaty::Exceptions::Validation`**

Raised when validation fails.

**Attributes:**
- `message` - Error description
- `attribute` - Attribute name (if applicable)
- `errors` - Array of error messages

**Example:**
```ruby
begin
  Posts::CreateTreaty.call!(version: treaty_version, params: params)
rescue Treaty::Exceptions::Validation => e
  puts e.message
  # => "Attribute 'title' is required but was not provided"
end
```

### Common Validation Errors

```ruby
# Required field missing
"Attribute 'title' is required but was not provided"

# Wrong type
"Attribute 'rating' must be an Integer, got String"

# Invalid inclusion
"Attribute 'status' must be one of: draft, published, archived. Got: 'deleted'"

# Invalid format
"Attribute 'email' has invalid email format: 'invalid-email'"
"Attribute 'external_id' has invalid uuid format: 'not-a-uuid'"
"Attribute 'birth_date' has invalid date format: 'not-a-date'"

# Object validation
"Attribute 'author' must be a Hash (object), got String"

# Array validation
"Error in array 'tags' at index 2: Attribute 'tags' must be a String, got Integer"

# Nested validation
"Error in array 'authors' at index 1: Attribute 'name' is required but was not provided"
```

## Complete Example

```ruby
module Gate
  module API
    module Posts
      class CreateTreaty < ApplicationTreaty
        # Version 1: Basic implementation
        version 1 do
          summary "Initial release"
          deprecated true
          strategy Treaty::Strategy::DIRECT

          request { object :post }
          response(201) { object :post }

          delegate_to Posts::V1::CreateService
        end

        # Version 2: Production-ready
        version 2, default: true do
          summary "Added validation and nested structures"
          strategy Treaty::Strategy::ADAPTER

          request do
            # Root-level attributes
            object :_self do
              string :api_key
            end

            # Post data
            object :post do
              string :title
              string :content
              string :summary, :optional
              string :category, in: %w[tech business lifestyle]
              boolean :published, :optional

              # Simple array
              array :tags, :optional do
                string :_self
              end

              # Nested object
              object :author do
                string :name
                string :email
                string :bio, :optional

                # Complex array
                array :socials, :optional do
                  string :provider, in: %w[twitter linkedin github]
                  string :handle, as: :value
                end
              end
            end
          end

          response 201 do
            object :post do
              string :id, :required
              string :title, :required
              string :content, :required
              string :summary
              string :category, :required
              boolean :published, :required

              array :tags, :required do
                string :_self
              end

              object :author, :required do
                string :name, :required
                string :email, :required
                string :bio

                array :socials do
                  string :provider, :required
                  string :value, as: :handle
                end
              end

              integer :views, default: 0
              datetime :created_at, :required
              datetime :updated_at, :required
            end

            object :meta do
              string :request_id
              datetime :requested_at
            end
          end

          delegate_to Posts::Stable::CreateService
        end
      end
    end
  end
end
```

## Best Practices Summary

### 1. Version Management
- Always have one default version
- Use semantic versioning for clarity
- Deprecate before removing
- Document changes in summary

### 2. Strategy Selection
- Use ADAPTER for production APIs
- Use DIRECT only for prototypes or trusted internal APIs
- Don't mix strategies without good reason

### 3. Attribute Definition
- Use helper mode (`:required`, `:optional`) for clarity
- Validate input strictly, keep output flexible
- Use `in:` for enum-like values
- Provide helpful custom error messages

### 4. Structure Organization
- Keep nesting shallow (max 5 levels)
- Use meaningful object names
- Use `:_self` sparingly
- Group related attributes in objects

### 5. Transformation
- Use defaults for safe, sensible values
- Document attribute renaming clearly
- Keep transformations simple
- Test transformation flows

## Next Steps

- [Getting Started](./getting-started.md) - start building with Treaty
- [Examples](./examples.md) - practical examples
- [Validation](./validation.md) - validation details
- [Transformation](./transformation.md) - transformation details

[← Back to Documentation](./README.md)
