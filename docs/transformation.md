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
    - Apply defaults
    - Custom transformations (transform:)
    - Rename attributes (as:)
    - Convert string keys → symbol keys
    ↓
Service (receives transformed Ruby hash)
    ↓
Response Transformation
    - Apply defaults
    - Custom transformations (transform:)
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

### 4. Custom Transformations

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

### 5. Type Casting

Automatically convert values between different types using the `cast` option. Unlike `transform`, which requires you to write custom lambdas, `cast` provides predefined conversions between types.

#### Simple Mode

```ruby
request do
  object :post do
    # Convert string timestamp to DateTime
    string :published_at, cast: :datetime

    # Convert boolean string to boolean
    string :featured, cast: :boolean

    # Convert Unix timestamp to DateTime
    integer :created_at, cast: :datetime
  end
end

response 200 do
  object :post do
    # Convert DateTime to string (ISO8601)
    datetime :published_at, cast: :string

    # Convert DateTime to Unix timestamp
    datetime :created_at, cast: :integer

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
- `integer -> datetime`: Treats as Unix timestamp

**From String:**
- `string -> integer`: Parses integer from string
- `string -> boolean`: Parses truthy/falsy strings (`"true"`, `"false"`, `"yes"`, `"no"`, `"1"`, `"0"`, `"on"`, `"off"`, case-insensitive)
- `string -> datetime`: Parses datetime string (ISO8601, RFC3339, etc.)

**From Boolean:**
- `boolean -> string`: Converts to `"true"` or `"false"`
- `boolean -> integer`: `true` = `1`, `false` = `0`

**From DateTime:**
- `datetime -> string`: Converts to ISO8601 format
- `datetime -> integer`: Converts to Unix timestamp

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
    datetime :published_at, cast: :string    # Cast to ISO8601 string
    datetime :created_at, cast: :integer     # Cast to Unix timestamp
    boolean :featured, cast: :integer        # Cast to 1 or 0
  end
end
```

**Service returns:**
```ruby
{
  post: {
    id: "123",
    title: "My Post",
    published_at: DateTime.parse("2024-01-15T10:30:00Z"),
    created_at: Time.current,
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
    "published_at" => "2024-01-15T10:30:00Z",  # ISO8601 string
    "created_at" => 1705320600,                # Unix timestamp
    "featured" => 1                            # Integer
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
- Cast only works with scalar types: `integer`, `string`, `boolean`, `datetime`
- Array and Object types do not support casting
- Casting to the same type is allowed (no-op)
- Cast is only applied to non-nil values
- Nil values are passed through unchanged (handled by `required` validation)

#### Cast vs Transform

Use `cast` when:
- Converting between built-in types
- You want automatic, consistent type conversions
- You need standard datetime/timestamp conversions

Use `transform` when:
- You need custom transformation logic
- The transformation doesn't fit predefined casting rules
- You want to apply business-specific transformations

**Example combining both:**
```ruby
request do
  object :post do
    # Transform cleans the string, then cast converts it to datetime
    string :published_at,
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

1. **Validate structure** - Ensure objects and types are correct
2. **Validate values** - Check required, inclusion, etc.
3. **Apply defaults** - Fill in missing values with defaults
4. **Rename attributes** - Apply `as:` transformations
5. **Convert keys** - String keys → Symbol keys
6. **Pass to service** - Service receives transformed data

### Response Transformation

1. **Receive from service** - Service returns Ruby hash
2. **Validate structure** - Ensure response matches definition
3. **Apply defaults** - Fill in missing values with defaults
4. **Rename attributes** - Apply `as:` transformations
5. **Convert keys** - Symbol keys → String keys
6. **Return to client** - Client receives JSON

## Option Execution Order

When multiple transformation options are defined on a single attribute, they execute **in the order they are written** in the DSL. This is critical when combining modifiers like `default`, `transform`, `cast`, and `as`.

### Why Order Matters

Transformation options (modifiers) are applied sequentially, with each modifier receiving the output of the previous one. Ruby hashes maintain insertion order, and Treaty preserves this order through the entire processing pipeline.

```ruby
# Options execute left-to-right as written:
string :title, transform: ->(value:) { value.strip }, cast: :datetime
#              ↑ First                                ↑ Second
```

**Processing flow:**
1. Input value received: `"  2024-01-15T10:30:00Z  "`
2. `transform` executes: `"2024-01-15T10:30:00Z"` (spaces removed)
3. `cast` executes: `DateTime` object (parsed from clean string)
4. Final value: `DateTime` object

### Recommended Order

For best results, define options in this order:

1. **`default:`** - Apply default values first if missing
2. **`transform:`** - Clean/prepare the value
3. **`cast:`** - Convert types
4. **`as:`** - Rename the attribute

```ruby
# Correct order
string :published_at,
       default: Time.current.iso8601,  # 1. Set default if nil
       transform: ->(value:) { value.strip },  # 2. Clean whitespace
       cast: :datetime,  # 3. Convert to DateTime
       as: :published_date  # 4. Rename for service
```

### Common Patterns

#### Pattern 1: Transform Before Cast

```ruby
# ✅ Correct: Clean string, then parse
string :published_at,
       transform: ->(value:) { value.strip },
       cast: :datetime

# ❌ Wrong: Cast fails on dirty string, transform fails on DateTime
string :published_at,
       cast: :datetime,  # Tries to parse "  2024-01-15  " (fails or inaccurate)
       transform: ->(value:) { value.strip }  # Receives DateTime, .strip fails
```

#### Pattern 2: Default Before Transform/Cast

```ruby
# ✅ Correct: Default value gets transformed and cast
string :published_at,
       default: "2024-01-15",
       transform: ->(value:) { value.strip },
       cast: :datetime

# ❌ Wrong: Default applied after cast, won't be converted
string :published_at,
       cast: :datetime,
       default: "2024-01-15"  # Remains string, type mismatch!
```

#### Pattern 3: Rename Last

```ruby
# ✅ Correct: Transform and cast work on original name, then rename
string :user_email,
       transform: ->(value:) { value.downcase },
       as: :email

# This works, but defining as 'email' initially is clearer
string :email,
       transform: ->(value:) { value.downcase }
```

### Conflict Examples

#### Conflict 1: Cast Before Transform

**Problem:**
```ruby
# String input with spaces
string :timestamp,
       cast: :datetime,  # Parses with spaces (might work but imprecise)
       transform: ->(value:) { value.strip }  # ERROR: DateTime doesn't have .strip
```

**Error:**
```
Treaty::Exceptions::Validation: Transform failed for attribute 'timestamp': undefined method 'strip' for DateTime
```

**Solution:**
```ruby
# Put transform first
string :timestamp,
       transform: ->(value:) { value.strip },  # Clean first
       cast: :datetime  # Then parse clean string
```

#### Conflict 2: Default After Cast

**Problem:**
```ruby
# If value is nil
string :published_at,
       cast: :datetime,  # Skip (nil value)
       default: "2024-01-15"  # Applied as string (wrong type!)

# Service receives: { published_at: "2024-01-15" } # String, not DateTime!
```

**Solution:**
```ruby
# Put default first
string :published_at,
       default: "2024-01-15",  # Applied first
       cast: :datetime  # Converts default to DateTime
```

#### Conflict 3: Multiple Transforms with Wrong Order

**Problem:**
```ruby
# Want to: strip → downcase → parse JSON
string :data,
       transform: ->(value:) { value.downcase },
       transform: ->(value:) { value.strip }  # Only this executes! (overwrites previous)
```

**Explanation:** Each option key can only appear once in a hash. The second `transform:` overwrites the first.

**Solution:**
```ruby
# Combine transformations in one lambda
string :data,
       transform: ->(value:) { value.strip.downcase }

# Or use nested approach
string :data,
       transform: ->(value:) { JSON.parse(value.strip.downcase) }
```

### Validators vs Modifiers

**Important:** Validators (like `required:`, `inclusion:`) execute **before** modifiers during the validation phase. The order discussed here applies only to **modifiers** during the transformation phase.

**Processing sequence:**
1. **Validation Phase:** `required:`, `type:`, `inclusion:`, `format:` (order doesn't matter)
2. **Transformation Phase:** `default:`, `transform:`, `cast:`, `as:` (order matters!)

```ruby
# All validators run first, then modifiers in order
string :status,
       required: true,  # ← Validation phase
       inclusion: { in: %w[draft published] },  # ← Validation phase
       default: "draft",  # → Transformation phase (1st)
       transform: ->(value:) { value.downcase }  # → Transformation phase (2nd)
```

### Debugging Order Issues

If you encounter unexpected behavior:

1. **Check type mismatches:**
   ```ruby
   # Is transform receiving the expected type?
   transform: ->(value:) { puts value.class; value.strip }
   ```

2. **Verify cast input:**
   ```ruby
   # Is cast receiving clean data?
   string :date,
          transform: ->(value:) { puts "Before cast: #{value.inspect}"; value.strip },
          cast: :datetime
   ```

3. **Test option isolation:**
   ```ruby
   # Remove options one by one to identify conflict
   string :field, transform: ..., cast: ...  # Both
   string :field, transform: ...  # Only transform
   string :field, cast: ...  # Only cast
   ```

### Best Practices

1. **Stick to recommended order:** default → transform → cast → as
2. **Combine multiple transforms** into a single lambda
3. **Clean before converting:** transform before cast
4. **Apply defaults early** so they get processed by other modifiers
5. **Rename last** with `as:` after all transformations
6. **Test combinations** thoroughly when mixing multiple modifiers
7. **Document non-obvious order** in code comments when necessary

```ruby
# Example: Well-ordered options with comments
request do
  object :post do
    string :published_at,
           default: Time.current.iso8601,  # Default if missing
           transform: ->(value:) { value.strip },  # Clean whitespace
           cast: :datetime  # Parse to DateTime
  end
end
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
datetime :birth_date, default: Time.now

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
