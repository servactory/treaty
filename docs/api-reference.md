# API Reference

[← Back to Documentation](./README.md)

## Overview

This comprehensive API reference covers all Treaty DSL methods, configuration options, attribute types, validation rules, and exception handling. Use this as a complete reference for building Treaty contracts.

## Treaty Class Definition

### Basic Structure

```ruby
class MyTreaty < ApplicationTreaty
  version VERSION_NUMBER do
    # Version configuration
  end
end
```

## Treaty::Result Class

### Overview

Every successful treaty execution returns a `Treaty::Result` object containing the validated data, HTTP status code, and version information.

**Structure:**

```ruby
class Treaty::Result
  attr_reader :data, :status, :version
end
```

### Attributes

**`.data` - Validated response data:**

```ruby
result = Posts::CreateTreaty.call!(version: "1", params: params)

result.data
# => {
#   post: {
#     id: "123",
#     title: "Hello World",
#     content: "...",
#     created_at: DateTime object
#   }
# }
```

**`.status` - HTTP status code:**

```ruby
result.status
# => 201

# Status is determined by:
# 1. response block definition: response 201 do ... end
# 2. Default: 200 if no response block specified
```

**`.version` - API version used:**

```ruby
result.version
# => #<Gem::Version "1">

# The version attribute contains:
# - A Gem::Version object representing the API version
# - Useful for logging, debugging, and tracking which version was used
# - Same version format as defined in treaty (converted to Gem::Version)

result.version.to_s
# => "1"

result.version.segments
# => [1]
```

### Usage Examples

**Basic usage:**

```ruby
result = Posts::IndexTreaty.call!(version: "2", params: { filters: {} })

# Access individual attributes
posts = result.data[:posts]
status_code = result.status
api_version = result.version

# Controller usage
render json: result.data, status: result.status
```

**Testing:**

```ruby
RSpec.describe Posts::CreateTreaty do
  subject(:perform) { described_class.call!(version: "1", params: params) }

  context "when creating post successfully" do
    let(:params) { { post: { title: "Test" } } }

    it "returns expected result structure" do
      expect(perform).to be_a(Treaty::Result)
      expect(perform.data).to include(:post)
      expect(perform.status).to eq(201)
      expect(perform.version).to eq(Gem::Version.new("1"))
    end
  end
end
```

**Logging:**

```ruby
result = Posts::CreateTreaty.call!(version: version, params: params)

Rails.logger.info(
  "Treaty executed: version=#{result.version}, " \
  "status=#{result.status}, " \
  "data=#{result.data.inspect}"
)
```

**Version tracking:**

```ruby
result = Posts::IndexTreaty.call!(version: version, params: params)

# Track which version was actually used
Analytics.track(
  event: "api_request",
  version: result.version.to_s,
  status: result.status
)

# Compare versions
if result.version < Gem::Version.new("2")
  # Handle legacy version response
end
```

### Inspect Output

```ruby
result = Posts::CreateTreaty.call!(version: "1", params: params)

result.inspect
# => "#<Treaty::Result @data={...}, @status=201, @version=#<Gem::Version \"1\">>"
```

### Introspection Methods

Treaty classes provide class methods for introspection and metadata access:

**`.info` - Get treaty metadata:**

```ruby
class Posts::IndexTreaty < ApplicationTreaty
  version 1 do

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
  deprecated(lambda do
    Gem::Version.new(ENV.fetch("APP_VERSION", "0.0.0")) >= Gem::Version.new("3.0.0")
  end)
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
    time :created_at
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
  time :created_at

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
time :created_at
datetime :published_at, :optional
datetime :expires_at, default: -> { Time.current + 1.day }
```

**Examples (Response - optional by default):**
```ruby
time :created_at
datetime :published_at
time :updated_at, :required
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
time :created_at, default: -> { Time.current }
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

#### `transform`

Apply custom transformations to attribute values.

**Type:** Lambda (Proc)
**Default:** nil

```ruby
string :title, transform: ->(value:) { value.strip }
string :email, transform: ->(value:) { value.downcase }
```

**Requirements:**
- Lambda must accept a named `value:` parameter
- All exceptions are caught and converted to `Treaty::Exceptions::Validation`
- Only applied to non-nil values (nil values pass through unchanged)

#### `computed`

Compute attribute values from other attributes in the data.

**Type:** Lambda (Proc)
**Default:** nil

```ruby
# Derive value from other attributes
string :full_name, :optional, computed: (lambda do |**attributes|
  "#{attributes.dig(:user, :first_name)} #{attributes.dig(:user, :last_name)}"
end)

integer :word_count, :optional, computed: (lambda do |**attributes|
  attributes.dig(:post, :content).to_s.split.size
end)

string :slug, :optional, computed: (lambda do |**attributes|
  attributes.dig(:post, :title).to_s.downcase.gsub(/\s+/, "-")
end)
```

**Requirements:**
- Lambda must accept keyword arguments (`**attributes`) to receive all raw data
- All exceptions are caught and converted to `Treaty::Exceptions::Validation`
- Always executes, generating a new value from raw data
- Computed attributes should be marked as `:optional` since value comes from computation
- Use `dig` to safely access nested values

**Difference from transform:**
- `computed:` receives ALL raw data (`**attributes`) and derives a new value
- `transform:` receives only the current attribute's value (`value:`)

#### `cast`

Automatically convert values between different types using predefined conversion rules.

**Type:** Symbol (target type)
**Default:** nil

**Simple mode:**
```ruby
string :published_at, cast: :datetime
time :created_at, cast: :integer
integer :timestamp, cast: :datetime
boolean :active, cast: :integer
string :featured, cast: :boolean
```

**Advanced mode:**
```ruby
string :published_at, cast: {
  to: :datetime,
  message: "Invalid date format provided"
}
```

**Supported conversions:**

**From Integer:**
- `integer -> string` - Converts to string representation
- `integer -> boolean` - `0` = `false`, non-zero = `true`
- `integer -> datetime` - Treats as Unix timestamp

**From String:**
- `string -> integer` - Parses integer from string
- `string -> boolean` - Parses truthy/falsy strings (`"true"`, `"false"`, `"yes"`, `"no"`, `"1"`, `"0"`, `"on"`, `"off"`, case-insensitive)
- `string -> datetime` - Parses datetime string (ISO8601, RFC3339, etc.)

**From Boolean:**
- `boolean -> string` - Converts to `"true"` or `"false"`
- `boolean -> integer` - `true` = `1`, `false` = `0`

**From DateTime:**
- `datetime -> string` - Converts to ISO8601 format
- `datetime -> integer` - Converts to Unix timestamp

**Requirements:**
- Cast only works with scalar types (`integer`, `string`, `boolean`, `datetime`)
- Array and Object types do not support casting
- Casting to the same type is allowed (no-op)
- Only applied to non-nil values (nil values pass through unchanged)
- All conversion errors are caught and converted to `Treaty::Exceptions::Validation`

**Note:** Advanced mode uses `:to` key instead of `:is` (different from other options).

#### `if` / `unless`

Control whether an attribute should be processed based on runtime data evaluation.

**Type:** Lambda (Proc)
**Default:** nil

```ruby
# Using if - include when condition is true
string :published_at, if: ->(post:) { post[:status] == "published" }
integer :views, if: ->(post:) { post[:status] == "published" }

# Using unless - include when condition is false
string :draft_notes, unless: ->(post:) { post[:status] == "published" }
array :tags, unless: ->(post:) { post[:status] == "draft" } do
  string :_self
end
```

**Requirements:**
- Lambda must be a Proc or Lambda (no other types accepted)
- Lambda receives raw data as named arguments matching the parent object structure
- `if` - If condition returns truthy, attribute is processed; if falsy, attribute is excluded
- `unless` - If condition returns falsy, attribute is processed; if truthy, attribute is excluded
- All exceptions in lambda are caught and converted to `Treaty::Exceptions::Validation`
- Evaluation happens before validators and modifiers run
- Cannot use both `if` and `unless` on the same attribute (raises mutual exclusivity error)

**Lambda argument patterns:**
```ruby
# For root-level attributes in request/response
if: ->(**attributes) { attributes[:status] == "published" }

# For nested attributes (recommended - more explicit)
if: ->(post:) { post[:status] == "published" }
unless: ->(post:) { post[:status] == "draft" }

# Access parent data in nested structures
object :post do
  string :status
  string :published_at, if: ->(post:) { post[:status] == "published" }
  string :draft_notes, unless: ->(post:) { post[:status] == "published" }
end
```

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

### Custom Message Error Handling

Custom message lambdas are executed during validation. If a lambda raises an exception, Treaty catches it and raises a `Treaty::Exceptions::Validation` error with details about what went wrong.

**Example:**
```ruby
string :title, required: {
  is: true,
  message: lambda do |attribute:, **|
    # If this raises an exception, Treaty catches it
    raise "Something went wrong in custom message"
  end
}
```

**Error message format:**
```
Custom message evaluation failed for attribute 'title': Something went wrong in custom message
```

This ensures that:
- Errors in custom message logic don't crash your application
- You get clear feedback about which attribute's message failed
- The original error message is preserved for debugging

**Note:** This applies to all custom message lambdas across all options (`required`, `inclusion`, `format`, `transform`, `cast`, etc.).

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
treaty :action_name do
  # Inventory configuration
end
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

  # With inventory
  treaty :show do
    provide :current_user
    provide :permissions, from: :load_permissions
  end
end
```

### `provide`

Provide controller-specific data to services (used within `treaty` block).

**Syntax:**
```ruby
provide :name, from: source
provide :name  # Shorthand: uses :name as source
```

**Parameters:**
- `:name` - Symbol representing the inventory item name
- `from:` - Optional source (Symbol, Proc/Lambda, or direct value)

**Source Types:**

**Symbol (Controller Method):**
```ruby
treaty :index do
  provide :posts, from: :load_posts
end

private

def load_posts
  Post.where(user: current_user).limit(10)
end
```

**Proc/Lambda (Callable):**
```ruby
treaty :index do
  provide :meta, from: -> { { timestamp: Time.current } }
  provide :request_id, from: -> { request.uuid }
end
```

**Direct Value:**
```ruby
treaty :index do
  provide :welcome_message, from: "Welcome to our API"
  provide :api_version, from: 3
end
```

**Shorthand (omit `from:`):**
```ruby
treaty :index do
  provide :current_user  # Calls current_user method
end
```

See [Inventory System](./inventory.md) for detailed documentation.

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

### Version Resolution Exceptions

**`Treaty::Exceptions::SpecifiedVersionNotFound`**

Raised when no version is specified and no default version is configured.

**HTTP Status:** 400 Bad Request

**Example:**
```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do; end
  version 2 do; end
  # No default version
end

# Client doesn't specify version
begin
  Posts::CreateTreaty.call!(version: nil, params: {})
rescue Treaty::Exceptions::SpecifiedVersionNotFound => e
  puts e.message
  # => "Specified version is required for validation"
end
```

**Solutions:**
- Add a default version: `version 2, default: true do; end`
- Ensure clients always specify version
- Handle exception in controller

**`Treaty::Exceptions::VersionNotFound`**

Raised when a specific version is requested but doesn't exist in the treaty.

**HTTP Status:** 404 Not Found

**Example:**
```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do; end
  version 2, default: true do; end
end

# Client requests non-existent version
begin
  Posts::CreateTreaty.call!(version: "3", params: {})
rescue Treaty::Exceptions::VersionNotFound => e
  puts e.message
  # => "Version 3 not found in treaty definition"
end
```

**Common causes:**
- Version number mismatch: `version 1` vs `version "1.0.0"`
- Typos in version number
- Version removed but still requested
- Wrong format (integer vs string)

**`Treaty::Exceptions::Deprecated`**

Raised when attempting to use a deprecated API version.

**HTTP Status:** 410 Gone

**Example:**
```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    deprecated true
  end

  version 2, default: true do; end
end

# Client requests deprecated version
begin
  Posts::CreateTreaty.call!(version: "1", params: {})
rescue Treaty::Exceptions::Deprecated => e
  puts e.message
  # => "Version 1 is deprecated and cannot be used"
end
```

**`Treaty::Exceptions::VersionDefaultDeprecatedConflict`**

Raised when a version is configured with both `default: true` and `deprecated` - a logical contradiction.

**HTTP Status:** 500 Internal Server Error

**Example:**
```ruby
# INVALID CONFIGURATION - Will raise exception when class loads
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do
    deprecated true  # ERROR: Cannot be both default and deprecated
  end
end
# => Raises Treaty::Exceptions::VersionDefaultDeprecatedConflict
# => "Version 1.0.0 cannot be both default and deprecated. A default version
#     must be active and usable. Either remove 'default: true' or remove
#     the 'deprecated' declaration."
```

**Why this error exists:** A default version is used when clients don't specify a version, so it must be active and usable. A deprecated version should not be used. These requirements are mutually exclusive.

**Solutions:**
- Remove `default: true` if the version should be deprecated
- Remove the `deprecated` call if the version should be default
- Create a new version to be the default, and deprecate the old one

**Valid configurations:**
```ruby
# Option 1: Default without deprecation
version 1, default: true do
  # No deprecated - valid
end

# Option 2: Deprecated without default
version 1 do
  deprecated true
end
version 2, default: true do; end

# Option 3: Neither
version 1 do
  # Regular version
end
```

**`Treaty::Exceptions::VersionMultipleDefaults`**

Raised when multiple versions in the same treaty are marked as default.

**HTTP Status:** 500 Internal Server Error

**Example:**
```ruby
# INVALID CONFIGURATION - Will raise exception when class loads
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do
    # First default
  end

  version 2, default: true do
    # ERROR: Second default
  end
end
# => Raises Treaty::Exceptions::VersionMultipleDefaults
# => "Cannot have multiple versions marked as default. Only one version
#     can be the default. Please review your treaty definition and ensure
#     only one version has 'default: true'."
```

**Why this error exists:** When a client doesn't specify a version, Treaty needs to know which single version to use. Having multiple defaults creates ambiguity.

**Solutions:**
- Identify which version should truly be the default
- Remove `default: true` from all other versions
- Keep only one `default: true` declaration

**Best practice:** The newest stable version should typically be the default.

**Valid configuration:**
```ruby
version 1 do
  deprecated true  # Old version
end

version 2 do
  # Stable version, not default
end

version 3, default: true do
  # Only one default - valid
end
```

**Controller Integration:**
```ruby
class ApplicationController < ActionController::API
  rescue_from Treaty::Exceptions::SpecifiedVersionNotFound, with: :version_required
  rescue_from Treaty::Exceptions::VersionNotFound, with: :version_not_found
  rescue_from Treaty::Exceptions::Deprecated, with: :version_deprecated
  rescue_from Treaty::Exceptions::VersionDefaultDeprecatedConflict, with: :config_error
  rescue_from Treaty::Exceptions::VersionMultipleDefaults, with: :config_error

  private

  def version_required(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def version_not_found(exception)
    render json: {
      error: exception.message,
      available_versions: extract_versions
    }, status: :not_found
  end

  def version_deprecated(exception)
    render json: { error: exception.message }, status: :gone
  end

  def config_error(exception)
    render json: {
      error: exception.message,
      hint: "This is a configuration error. Contact the development team."
    }, status: :internal_server_error
  end
end
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

          request { object :post }
          response(201) { object :post }

          delegate_to Posts::V1::CreateService
        end

        # Version 2: Production-ready
        version 2, default: true do
          summary "Added validation and nested structures"

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
              time :created_at, :required
              time :updated_at, :required
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

### 2. Attribute Definition
- Use helper mode (`:required`, `:optional`) for clarity
- Validate input strictly, keep output flexible
- Use `in:` for enum-like values
- Provide helpful custom error messages

### 3. Structure Organization
- Keep nesting shallow (max 5 levels)
- Use meaningful object names
- Use `:_self` sparingly
- Group related attributes in objects

### 4. Transformation
- Use defaults for safe, sensible values
- Document attribute renaming clearly
- Keep transformations simple
- Test transformation flows

## Next Steps

- [Getting Started](./getting-started.md) - Start building with Treaty
- [Examples](./examples.md) - Practical examples
- [Validation](./validation.md) - Validation details
- [Transformation](./transformation.md) - Transformation details

[← Back to Documentation](./README.md)
