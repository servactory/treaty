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

Define the structure of incoming requests.

**Syntax:**
```ruby
request do
  # Scope and attribute definitions
end
```

**Example:**
```ruby
request do
  object :post do
    string :title, :required
    string :content, :required
  end
end
```

**Multiple request blocks:**
```ruby
# These will be merged
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

## Response Definition

### `response`

Define the structure of outgoing responses.

**Syntax:**
```ruby
response status_code do
  # Scope and attribute definitions
end
```

**Parameters:**
- `status_code` (Integer) - HTTP status code (200, 201, 404, etc.)

**Example:**
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

**Examples:**
```ruby
string :title
string :title, :required
string :title, :optional
string :title, required: true
string :title, default: "Untitled"
string :title, in: %w[draft published archived]
string :title, as: :post_title
string :category, required: { is: true, message: "Category is required" }
```

### `integer`

Define an integer attribute.

**Syntax:**
```ruby
integer :name, *modes, **options
```

**Examples:**
```ruby
integer :count
integer :page, :required
integer :limit, default: 12
integer :rating, in: [1, 2, 3, 4, 5]
integer :age, as: :user_age
```

### `boolean`

Define a boolean attribute.

**Syntax:**
```ruby
boolean :name, *modes, **options
```

**Examples:**
```ruby
boolean :published
boolean :active, :required
boolean :featured, :optional
boolean :archived, default: false
```

**Note:** Only accepts `true` or `false` (TrueClass/FalseClass). Does not perform type coercion.

### `datetime`

Define a datetime attribute.

**Syntax:**
```ruby
datetime :name, *modes, **options
```

**Examples:**
```ruby
datetime :created_at
datetime :published_at, :optional
datetime :expires_at, default: -> { Time.now + 1.day }
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

**Examples:**
```ruby
# Object with structure
object :author, :required do
  string :name, :required
  string :email, :required
  string :bio, :optional
end

# Empty object
object :metadata, :optional

# Deeply nested
object :post do
  string :title

  object :author, :required do
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

**Examples:**
```ruby
# Simple array of strings
array :tags, :optional do
  string :_self
end

# Complex array of objects
array :authors, :required do
  string :name, :required
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

## Attribute Options

### Helper Mode

Use symbols for simple definitions:

```ruby
:required  # Attribute must be present and not empty
:optional  # Attribute can be missing or nil
```

**Examples:**
```ruby
string :title, :required
string :summary, :optional
integer :count, :required
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

### Advanced Mode Options

For custom error messages and fine-grained control:

#### `required`

**Type:** Hash with `:is` and `:message`

```ruby
string :title, required: {
  is: true,
  message: "Post title cannot be empty"
}
```

#### `inclusion`

**Type:** Hash with `:in` and `:message`

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
              string :api_key, :required
            end

            # Post data
            object :post do
              string :title, :required
              string :content, :required
              string :summary, :optional
              string :category, :required, in: %w[tech business lifestyle]
              boolean :published, :optional

              # Simple array
              array :tags, :optional do
                string :_self
              end

              # Nested object
              object :author, :required do
                string :name, :required
                string :email, :required
                string :bio, :optional

                # Complex array
                array :socials, :optional do
                  string :provider, :required, in: %w[twitter linkedin github]
                  string :handle, :required, as: :value
                end
              end
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :content
              string :summary
              string :category
              boolean :published

              array :tags do
                string :_self
              end

              object :author do
                string :name
                string :email
                string :bio

                array :socials do
                  string :provider
                  string :value, as: :handle
                end
              end

              integer :views, default: 0
              datetime :created_at
              datetime :updated_at
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
