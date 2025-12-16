# Transformation

[← Back to Documentation](./README.md)

## Overview

Transformation modifies data as it flows through Treaty, including applying default values, renaming attributes, and converting keys. This guide covers the transformation pipeline, types of transformations, and best practices.

## Transformation Pipeline

Treaty transforms data at two points:

1. **Request Transformation** - After validating client input, before passing to service
2. **Response Transformation** - After service returns data, before sending to client

```
Client Request (JSON)
    ↓
Validation
    ↓
Request Transformation
    - Compute values (computed:)
    - Custom transformations (transform:)
    - Type casting (cast:)
    - Apply defaults (default:)
    - Rename attributes (as:)
    - Convert string keys → symbol keys
    ↓
Service (receives transformed Ruby hash)
    ↓
Response Transformation
    - Compute values (computed:)
    - Custom transformations (transform:)
    - Type casting (cast:)
    - Apply defaults (default:)
    - Rename attributes (as:)
    - Convert symbol keys → string keys
    ↓
Client Response (JSON)
```

## Types of Transformations

### 1. Default Values

Apply default values when attributes are missing or nil.

#### Request Defaults

```ruby
request do
  object :_self do
    integer :page, default: 1
    integer :limit, default: 12
  end

  object :post do
    string :status, default: "draft"
  end
end
```

**Client sends:**
```ruby
{ post: { title: "Hello" } }
```

**Service receives (with defaults applied):**
```ruby
{
  page: 1,           # Default applied
  limit: 12,         # Default applied
  post: {
    title: "Hello",
    status: "draft"  # Default applied
  }
}
```

#### Response Defaults

```ruby
response 200 do
  object :post do
    string :id
    string :title
    integer :views, default: 0
    string :status, default: "draft"
  end

  object :meta do
    integer :page, default: 1
    integer :limit, default: 12
  end
end
```

**Service returns:**
```ruby
{
  post: {
    id: "123",
    title: "Hello"
  },
  meta: {
    page: 2
  }
}
```

**Client receives (with defaults applied):**
```ruby
{
  "post" => {
    "id" => "123",
    "title" => "Hello",
    "views" => 0,        # Default applied
    "status" => "draft"  # Default applied
  },
  "meta" => {
    "page" => 2,
    "limit" => 12        # Default applied
  }
}
```

### 2. Attribute Renaming

Rename attributes between client and service using the `as:` option.

#### Request Renaming (Client → Service)

```ruby
request do
  object :social do
    string :handle, as: :value
  end
end
```

**Client sends:**
```ruby
{ social: { handle: "alice" } }
```

**Service receives (renamed):**
```ruby
{ social: { value: "alice" } }
```

#### Response Renaming (Service → Client)

```ruby
response 200 do
  object :social do
    string :value, as: :handle
  end
end
```

**Service returns:**
```ruby
{ social: { value: "alice" } }
```

**Client receives (renamed):**
```ruby
{ "social" => { "handle" => "alice" } }
```

#### Bidirectional Renaming

```ruby
# Request: client 'handle' → service 'value'
request do
  object :social do
    string :handle, as: :value
  end
end

# Response: service 'value' → client 'handle'
response 200 do
  object :social do
    string :value, as: :handle
  end
end
```

**Complete flow:**

1. **Client sends:**
   ```ruby
   { "social" => { "handle" => "alice" } }
   ```

2. **Service receives:**
   ```ruby
   { social: { value: "alice" } }
   ```

3. **Service returns:**
   ```ruby
   { social: { value: "alice" } }
   ```

4. **Client receives:**
   ```ruby
   { "social" => { "handle" => "alice" } }
   ```

### 3. Key Conversion

Treaty automatically converts between string and symbol keys.

#### Request Key Conversion

**Client sends (JSON with string keys):**
```ruby
{
  "post" => {
    "title" => "Hello",
    "content" => "World"
  }
}
```

**Service receives (symbols):**
```ruby
{
  post: {
    title: "Hello",
    content: "World"
  }
}
```

#### Response Key Conversion

**Service returns (symbols):**
```ruby
{
  post: {
    id: "123",
    title: "Hello"
  }
}
```

**Client receives (strings):**
```ruby
{
  "post" => {
    "id" => "123",
    "title" => "Hello"
  }
}
```

### 4. Computed Values

Compute attribute values from other attributes in the data using the `computed` option. Unlike `transform` which receives only the current attribute's value, `computed` receives all raw data from the root level, allowing derivation of values from multiple sources.

#### Basic Usage

```ruby
request do
  object :post do
    string :title
    string :content

    # Computed: slug derived from title
    string :slug, :optional, computed: ->(**attrs) {
      attrs.dig(:post, :title).to_s.downcase.gsub(/\s+/, "-").gsub(/[^a-z0-9\-]/, "")
    }

    # Computed: word count derived from content
    integer :word_count, :optional, computed: ->(**attrs) {
      attrs.dig(:post, :content).to_s.split.size
    }

    object :author do
      string :first_name
      string :last_name

      # Computed: full name from first_name and last_name
      string :full_name, :optional, computed: ->(**attrs) {
        "#{attrs.dig(:post, :author, :first_name)} #{attrs.dig(:post, :author, :last_name)}"
      }
    end
  end
end
```

**Client sends:**
```ruby
{
  "post" => {
    "title" => "Hello World Post",
    "content" => "This is a sample content with multiple words",
    "author" => {
      "first_name" => "John",
      "last_name" => "Doe"
    }
  }
}
```

**Service receives (with computed values):**
```ruby
{
  post: {
    title: "Hello World Post",
    content: "This is a sample content with multiple words",
    slug: "hello-world-post",      # Computed from title
    word_count: 8,                  # Computed from content
    author: {
      first_name: "John",
      last_name: "Doe",
      full_name: "John Doe"        # Computed from first_name + last_name
    }
  }
}
```

#### Advanced Mode with Custom Error Messages

```ruby
request do
  object :order do
    integer :quantity
    integer :unit_price

    integer :total, :optional, computed: {
      is: ->(**attrs) { attrs.dig(:order, :quantity).to_i * attrs.dig(:order, :unit_price).to_i },
      message: "Failed to calculate order total"
    }

    # Lambda message for dynamic error
    string :formatted_total, :optional, computed: {
      is: ->(**attrs) {
        total = attrs.dig(:order, :quantity).to_i * attrs.dig(:order, :unit_price).to_i
        "$#{format('%.2f', total / 100.0)}"
      },
      message: ->(attribute:, error:) { "Computation failed for #{attribute}: #{error}" }
    }
  end
end
```

#### Error Handling

All exceptions raised within computed lambdas are caught and converted to `Treaty::Exceptions::Validation`:

```ruby
request do
  object :post do
    string :data, :optional, computed: ->(**attrs) { attrs.fetch(:missing_key) }
  end
end
```

If the computation fails, Treaty raises:
```
Treaty::Exceptions::Validation: Computed failed for attribute 'data': key not found: :missing_key
```

**Important Notes:**
- Computed always executes, ignoring any existing value for the attribute
- The lambda receives ALL raw data from the root level as keyword arguments
- Use `dig` to safely access nested values
- Computed attributes should be marked as `:optional` since the value comes from computation, not input
- Computed runs FIRST in the modifier chain, before transform, cast, default, and as

#### Computed vs Transform

| Aspect | `computed:` | `transform:` |
|--------|-------------|--------------|
| **Input** | All raw data (`**attrs`) | Current attribute value (`value:`) |
| **Purpose** | Derive value from other attributes | Transform the current value |
| **Execution** | Always runs, ignores existing value | Only runs on non-nil values |
| **Order** | First in modifier chain | After computed |

**Example combining both:**
```ruby
request do
  object :post do
    string :title

    # Compute initial slug from title, then transform to ensure lowercase
    string :slug, :optional,
           computed: ->(**attrs) { attrs.dig(:post, :title).to_s.gsub(/\s+/, "-") },
           transform: ->(value:) { value.downcase }
  end
end
```

### 5. Custom Transformations

Apply custom lambda-based transformations to attribute values using the `transform` option.

#### Request Transformations

```ruby
request do
  object :post do
    string :title, transform: ->(value:) { value.strip.titleize }
    string :email, transform: ->(value:) { value.downcase.strip }
    integer :amount_cents, transform: ->(value:) { value * 100 }
  end
end
```

**Client sends:**
```ruby
{
  "post" => {
    "title" => "  hello world  ",
    "email" => "  USER@EXAMPLE.COM  ",
    "amount_cents" => 10
  }
}
```

**Service receives (with transformations applied):**
```ruby
{
  post: {
    title: "Hello World",
    email: "user@example.com",
    amount_cents: 1000
  }
}
```

#### Response Transformations

```ruby
response 200 do
  object :post do
    string :title, transform: ->(value:) { value.upcase }
    datetime :created_at, transform: ->(value:) { value.iso8601 }
  end
end
```

**Service returns:**
```ruby
{
  post: {
    title: "Hello World",
    created_at: Time.parse("2025-01-15 10:30:00 UTC")
  }
}
```

**Client receives (with transformations applied):**
```ruby
{
  "post" => {
    "title" => "HELLO WORLD",
    "created_at" => "2025-01-15T10:30:00Z"
  }
}
```

#### Advanced Mode with Custom Error Messages

```ruby
request do
  object :post do
    string :slug, transform: {
      is: ->(value:) { value.parameterize },
      message: "Failed to generate slug"
    }
  end
end
```

#### Error Handling

All exceptions raised within transform lambdas are caught and converted to `Treaty::Exceptions::Validation`:

```ruby
request do
  object :post do
    string :data, transform: ->(value:) { JSON.parse(value) }
  end
end
```

If JSON parsing fails, Treaty raises:
```
Treaty::Exceptions::Validation: Transform failed for attribute 'data': unexpected token at '...'
```

**Important Notes:**
- Transform is only applied to non-nil values
- Nil values are passed through unchanged (handled by `required` validation)
- This prevents unnecessary lambda execution and potential errors

### 6. Type Casting

Automatically convert values between different types using the `cast` option. Unlike `transform`, which requires you to write custom lambdas, `cast` provides predefined conversions between types.

#### Simple Mode

```ruby
request do
  object :post do
    # Convert string to Date
    string :published_on, cast: :date

    # Convert string to Time
    string :created_at, cast: :time

    # Convert string to DateTime
    string :scheduled_at, cast: :datetime

    # Convert boolean string to boolean
    string :featured, cast: :boolean
  end
end

response 200 do
  object :post do
    # Convert Date to string (ISO8601)
    date :published_on, cast: :string

    # Convert Time to Unix timestamp
    time :created_at, cast: :integer

    # Convert DateTime to string (ISO8601)
    datetime :scheduled_at, cast: :string

    # Convert boolean to integer (1/0)
    boolean :featured, cast: :integer
  end
end
```

#### Advanced Mode with Custom Error Messages

```ruby
request do
  object :post do
    string :published_at, cast: {
      to: :datetime,
      message: "Invalid date format provided"
    }
  end
end
```

#### Supported Conversions

**From Integer:**
- `integer -> string`: Converts to string representation (`"42"`)
- `integer -> boolean`: `0` = `false`, non-zero = `true`
- `integer -> date`: Treats as Unix timestamp, converts to Date
- `integer -> time`: Treats as Unix timestamp, converts to Time
- `integer -> datetime`: Treats as Unix timestamp, converts to DateTime

**From String:**
- `string -> integer`: Parses integer from string
- `string -> boolean`: Parses truthy/falsy strings (`"true"`, `"false"`, `"yes"`, `"no"`, `"1"`, `"0"`, `"on"`, `"off"`, case-insensitive)
- `string -> date`: Parses date string (ISO8601, etc.)
- `string -> time`: Parses time string (ISO8601, RFC3339, etc.)
- `string -> datetime`: Parses datetime string (ISO8601, RFC3339, etc.)

**From Boolean:**
- `boolean -> string`: Converts to `"true"` or `"false"`
- `boolean -> integer`: `true` = `1`, `false` = `0`

**From Date:**
- `date -> string`: Converts to ISO8601 format
- `date -> integer`: Converts to Unix timestamp
- `date -> time`: Converts to Time (start of day)
- `date -> datetime`: Converts to DateTime (start of day)

**From Time:**
- `time -> string`: Converts to ISO8601 format
- `time -> integer`: Converts to Unix timestamp
- `time -> date`: Converts to Date
- `time -> datetime`: Converts to DateTime

**From DateTime:**
- `datetime -> string`: Converts to ISO8601 format
- `datetime -> integer`: Converts to Unix timestamp
- `datetime -> date`: Converts to Date
- `datetime -> time`: Converts to Time

#### Request Casting Example

```ruby
request do
  object :post do
    string :title
    string :published_at, cast: :datetime
    string :featured, cast: :boolean
  end
end
```

**Client sends:**
```ruby
{
  "post" => {
    "title" => "My Post",
    "published_at" => "2024-01-15T10:30:00Z",
    "featured" => "true"
  }
}
```

**Service receives (with casting applied):**
```ruby
{
  post: {
    title: "My Post",
    published_at: DateTime.parse("2024-01-15T10:30:00Z"), # DateTime object
    featured: true                                         # Boolean
  }
}
```

#### Response Casting Example

```ruby
response 200 do
  object :post do
    string :id
    string :title
    date :published_on, cast: :string       # Cast to ISO8601 string
    time :created_at, cast: :integer        # Cast to Unix timestamp
    datetime :scheduled_at, cast: :string   # Cast to ISO8601 string
    boolean :featured, cast: :integer       # Cast to 1 or 0
  end
end
```

**Service returns:**
```ruby
{
  post: {
    id: "123",
    title: "My Post",
    published_on: Date.parse("2024-01-15"),
    created_at: Time.current,
    scheduled_at: DateTime.parse("2024-01-15T10:30:00Z"),
    featured: true
  }
}
```

**Client receives (with casting applied):**
```ruby
{
  "post" => {
    "id" => "123",
    "title" => "My Post",
    "published_on" => "2024-01-15",             # ISO8601 date string
    "created_at" => 1705320600,                 # Unix timestamp
    "scheduled_at" => "2024-01-15T10:30:00Z",   # ISO8601 datetime string
    "featured" => 1                             # Integer
  }
}
```

#### Error Handling

Casting errors are caught and converted to `Treaty::Exceptions::Validation`:

```ruby
request do
  object :post do
    string :count, cast: :integer
  end
end
```

If casting fails (e.g., `"not a number"`), Treaty raises:
```
Treaty::Exceptions::Validation: Cast failed for attribute 'count' from 'string' to 'integer'. Value: 'not a number'. Error: invalid value for Integer(): "not a number"
```

**Important Notes:**
- Cast only works with scalar types: `integer`, `string`, `boolean`, `date`, `time`, `datetime`
- Array and Object types do not support casting
- Casting to the same type is allowed (no-op)
- Cast is only applied to non-nil values
- Nil values are passed through unchanged (handled by `required` validation)

#### Cast vs Transform

Use `cast` when:
- Converting between built-in types
- You want automatic, consistent type conversions
- You need standard date/time/timestamp conversions

Use `transform` when:
- You need custom transformation logic
- The transformation doesn't fit predefined casting rules
- You want to apply business-specific transformations

**Example combining both:**
```ruby
request do
  object :post do
    # Transform cleans the string, then cast converts it to datetime
    string :scheduled_at,
           transform: ->(value:) { value.strip },
           cast: :datetime
  end
end
```

## Transformation in Nested Structures

### Objects

Transformations apply recursively to nested objects.

```ruby
request do
  object :post do
    object :author do
      string :display_name, as: :name
      string :email_address, as: :email
    end
  end
end
```

**Client sends:**
```ruby
{
  "post" => {
    "author" => {
      "display_name" => "John Doe",
      "email_address" => "johndoe@example.com"
    }
  }
}
```

**Service receives:**
```ruby
{
  post: {
    author: {
      name: "John Doe",
      email: "johndoe@example.com"
    }
  }
}
```

### Arrays

Transformations apply to each array item.

#### Simple Arrays

```ruby
response 200 do
  object :post do
    array :tags do
      string :_self
    end
  end
end
```

**Service returns:**
```ruby
{ post: { tags: [:ruby, :rails, :api] } }
```

**Client receives (symbols → strings):**
```ruby
{ "post" => { "tags" => ["ruby", "rails", "api"] } }
```

#### Complex Arrays

```ruby
request do
  object :post do
    array :socials do
      string :handle, as: :value
      string :provider
    end
  end
end
```

**Client sends:**
```ruby
{
  "post" => {
    "socials" => [
      { "handle" => "alice", "provider" => "twitter" },
      { "handle" => "alice_dev", "provider" => "github" }
    ]
  }
}
```

**Service receives:**
```ruby
{
  post: {
    socials: [
      { value: "alice", provider: "twitter" },
      { value: "alice_dev", provider: "github" }
    ]
  }
}
```

## Transformation Order

Transformations happen in this order:

### Request Transformation

1. **Conditional Evaluation** - Determine if attribute should be processed
   - Evaluate `if` / `unless` conditions using raw data
   - Skip attribute completely if condition fails
   - Continue to validation if condition succeeds
2. **Validate structure** - Ensure objects and types are correct
3. **Validate values** - Check required, inclusion, etc.
4. **Apply defaults** - Fill in missing values with defaults
5. **Custom transformations** - Apply `transform:` lambdas
6. **Type casting** - Apply `cast:` conversions
7. **Rename attributes** - Apply `as:` transformations
8. **Convert keys** - String keys → Symbol keys
9. **Pass to service** - Service receives transformed data

### Response Transformation

1. **Receive from service** - Service returns Ruby hash
2. **Conditional Evaluation** - Determine if attribute should be processed
   - Evaluate `if` / `unless` conditions using raw data
   - Skip attribute completely if condition fails
   - Continue to validation if condition succeeds
3. **Validate structure** - Ensure response matches definition
4. **Apply defaults** - Fill in missing values with defaults
5. **Custom transformations** - Apply `transform:` lambdas
6. **Type casting** - Apply `cast:` conversions
7. **Rename attributes** - Apply `as:` transformations
8. **Convert keys** - Symbol keys → String keys
9. **Return to client** - Client receives JSON

## Option Execution Order

Treaty automatically ensures options execute in the correct order, regardless of how you write them in the DSL.

**Processing phases:**

1. **Conditionals** (`if:`, `unless:`) — Evaluated first to determine if attribute is included
2. **Validators** (`type:` → `required:` → `inclusion:` → `format:`) — Check value constraints
3. **Modifiers** (`transform:` → `cast:` → `computed:` → `default:` → `as:`) — Transform value

You can write options in any order in your DSL — Treaty handles the rest.

```ruby
# These are equivalent - Treaty sorts automatically:
string :published_at, default: Time.current, cast: :datetime, transform: ->(value:) { value.strip }
string :published_at, transform: ->(value:) { value.strip }, cast: :datetime, default: Time.current
```

### Important Notes

- **Default values** should match the target type (after any `cast:` transformation)
- **Computed attributes** should be marked as `:optional` since they derive values from other attributes
- **Multiple transforms** must be combined in a single lambda (Ruby hash keys are unique)

```ruby
# Combine transformations in one lambda
string :data, transform: ->(value:) { value.strip.downcase }
```

## Practical Examples

### Example 1: Pagination with Defaults

```ruby
version 1, default: true do

  request do
    object :_self do
      integer :page, default: 1
      integer :limit, default: 12
    end
  end

  response 200 do
    array :posts do
      string :id
      string :title
    end

    object :meta do
      integer :count
      integer :page, default: 1
      integer :limit, default: 12
      integer :total_pages
    end
  end

  delegate_to Posts::IndexService
end
```

**Client request (empty):**
```ruby
GET /api/posts
{}
```

**Service receives (with defaults):**
```ruby
{ page: 1, limit: 12 }
```

**Service returns (partial meta):**
```ruby
{
  posts: [{ id: "1", title: "Hello" }],
  meta: { count: 100, total_pages: 9 }
}
```

**Client receives (with defaults applied):**
```ruby
{
  "posts" => [{ "id" => "1", "title" => "Hello" }],
  "meta" => {
    "count" => 100,
    "page" => 1,        # Default applied
    "limit" => 12,      # Default applied
    "total_pages" => 9
  }
}
```

### Example 2: Social Profiles with Renaming

```ruby
version 1, default: true do

  request do
    object :profile do
      array :socials do
        string :provider
        string :handle, as: :value
        string :display_url, :optional, as: :url
      end
    end
  end

  response 200 do
    object :profile do
      string :id, :required
      array :socials do
        string :provider, :required
        string :value, as: :handle
        string :url, as: :display_url
      end
    end
  end

  delegate_to Users::UpdateProfileService
end
```

**Complete transformation flow:**

1. **Client sends:**
   ```ruby
   {
     "profile" => {
       "socials" => [
         {
           "provider" => "twitter",
           "handle" => "alice",
           "display_url" => "https://twitter.com/alice"
         }
       ]
     }
   }
   ```

2. **Service receives (after transformation):**
   ```ruby
   {
     profile: {
       socials: [
         {
           provider: "twitter",
           value: "alice",              # Renamed from handle
           url: "https://twitter.com/alice"  # Renamed from display_url
         }
       ]
     }
   }
   ```

3. **Service returns:**
   ```ruby
   {
     profile: {
       id: "user-123",
       socials: [
         {
           provider: "twitter",
           value: "alice",
           url: "https://twitter.com/alice"
         }
       ]
     }
   }
   ```

4. **Client receives (after transformation):**
   ```ruby
   {
     "profile" => {
       "id" => "user-123",
       "socials" => [
         {
           "provider" => "twitter",
           "handle" => "alice",              # Renamed from value
           "display_url" => "https://twitter.com/alice"  # Renamed from url
         }
       ]
     }
   }
   ```

### Example 3: API Versioning with Different Structures

Use transformations to adapt between API versions:

```ruby
class Posts::ShowTreaty < ApplicationTreaty
  # Version 1: Flat structure
  version 1 do
    deprecated true

    response 200 do
      object :post do
        string :id
        string :title
        string :author_name      # Flat structure
        string :author_email
      end
    end

    delegate_to Posts::V1::ShowService
  end

  # Version 2: Nested structure
  version 2, default: true do

    response 200 do
      object :post do
        string :id
        string :title

        # Nested author object
        object :author do
          string :name
          string :email
        end
      end
    end

    delegate_to Posts::Stable::ShowService
  end
end
```

## Default Value Strategies

### When to Use Defaults

**Good use cases:**
- Pagination parameters (page, limit)
- Common settings (theme, language, timezone)
- Optional metadata (views, ratings)
- Status fields (draft, active, pending)

```ruby
# Good - sensible defaults
integer :page, default: 1
integer :limit, default: 12
string :theme, default: "light"
string :status, default: "draft"
integer :views, default: 0
```

### When to Avoid Defaults

**Avoid defaults for:**
- Business-critical data
- User-specific information
- Data that should be explicitly provided

```ruby
# Bad - should be explicitly provided
string :email, default: "unknown@example.com"
string :password, default: "changeme"
datetime :birth_date, default: Time.current

# Good - require explicit values
string :email, :required
string :password, :required
datetime :birth_date, :required
```

## Attribute Renaming Strategies

### Use Cases for Renaming

1. **Internal vs External Names**
   ```ruby
   # Client uses 'username', service uses 'login'
   string :username, as: :login
   ```

2. **API Evolution**
   ```ruby
   # Old API used 'desc', new API uses 'description'
   string :description, as: :desc
   ```

3. **Service Compatibility**
   ```ruby
   # Service expects specific key names
   string :user_email, as: :email
   string :user_name, as: :name
   ```

4. **Abbreviation Expansion**
   ```ruby
   # Client: abbreviated, Service: full names
   string :img_url, as: :image_url
   string :desc, as: :description
   ```

### Renaming Best Practices

```ruby
# Good - clear transformation
request do
  object :user do
    string :display_name, as: :name
    string :email_address, as: :email
  end
end

# Avoid - confusing transformations
request do
  object :user do
    string :name, as: :email     # Confusing!
    string :email, as: :username # Misleading!
  end
end
```

## Transformation vs Validation

**Validation** happens **before** transformation:

```ruby
request do
  object :post do
    string :status, :required, default: "draft", in: %w[draft published]
  end
end
```

**Processing order:**

1. **Validate required** - Check if `status` is present
2. **Apply default** - If missing, set to "draft"
3. **Validate inclusion** - Check if value is in list
4. **Apply transformation** - Convert keys, apply renaming

## Best Practices

### 1. Use Defaults Wisely

```ruby
# Good - safe defaults
integer :page, default: 1
integer :limit, default: 12
string :sort_direction, default: "desc"

# Avoid - dangerous defaults
string :email, default: ""
boolean :terms_accepted, default: false
```

### 2. Document Renaming

```ruby
# Good - clear and documented
request do
  object :profile do
    # Client sends 'handle', service expects 'value'
    string :handle, as: :value
  end
end

# Better - use consistent naming to avoid renaming
request do
  object :profile do
    string :handle  # Same name in client and service
  end
end
```

### 3. Keep Transformations Simple

```ruby
# Good - simple, clear transformations
string :page_number, as: :page
integer :items_per_page, as: :limit

# Avoid - complex transformation chains
string :a, as: :b  # Then service transforms b → c → d
```

### 4. Test Transformations

Always test that transformations work correctly:

```ruby
# In your specs
RSpec.describe Users::UpdateProfileTreaty do
  subject(:perform) { described_class.call!(version: version, params: params) }

  let(:version) { "2" }
  let(:params) { { social: { handle: "johndoe" } } }

  it "transforms handle to value" do
    expect(perform.data[:social][:value]).to eq("johndoe")
    expect(perform.data[:social][:handle]).to be_nil
  end
end
```

## Next Steps

- [Validation](./validation.md) - Understand validation system
- [Examples](./examples.md) - Practical examples

[← Back to Documentation](./README.md)
