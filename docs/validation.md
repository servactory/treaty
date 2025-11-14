# Validation

[← Back to Documentation](./README.md)

## Overview

Treaty provides comprehensive validation for requests and responses, including type checking, required field validation, inclusion validation, and format validation. This guide covers all validation types, error messages, and custom validation messages with both static strings and dynamic lambda functions. Validation only applies when using the **ADAPTER** strategy.

## Validation Modes

Treaty supports three validation modes through its option system:

### 1. Helper Mode (Recommended)

Use Ruby symbols for simple, readable definitions:

```ruby
string :title, :required
string :summary, :optional
integer :rating, :required
```

**Available helpers:**
- `:required` - Attribute must be present and not empty
- `:optional` - Attribute can be missing or nil

### 2. Simple Mode

Use hash options for more control:

```ruby
string :title, required: true
string :summary, optional: true, default: "No summary"
integer :rating, required: true, in: [1, 2, 3, 4, 5]
```

### 3. Advanced Mode

Full control with custom error messages:

```ruby
string :title, required: { is: true, message: "Post title is required" }
string :category, inclusion: { in: %w[tech business], message: "Invalid category" }
```

## Validation Types

### Required Validation

Ensures an attribute is present and not empty.

```ruby
request do
  object :post do
    string :title
    string :content
  end
end
```

**Valid:**
```ruby
{ post: { title: "Hello", content: "World" } } ✓
```

**Invalid:**
```ruby
{ post: { title: "Hello" } } ✗
# Error: Attribute 'content' is required but was not provided

{ post: { title: "", content: "World" } } ✗
# Error: Attribute 'title' is required but was not provided or is empty

{ post: { title: nil, content: "World" } } ✗
# Error: Attribute 'title' is required but was not provided or is empty
```

### Optional Validation

Attribute can be missing or nil without causing errors.

```ruby
request do
  object :post do
    string :title
    string :summary, :optional
  end
end
```

**All valid:**
```ruby
{ post: { title: "Hello", summary: "Brief" } } ✓
{ post: { title: "Hello", summary: nil } } ✓
{ post: { title: "Hello" } } ✓
```

### Type Validation

Ensures attribute matches the declared type.

```ruby
request do
  object :post do
    string :title
    integer :rating
    datetime :published_at
  end
end
```

**Type checking:**
```ruby
# String validation
{ title: "Hello" } ✓
{ title: 123 } ✗  # Must be String, got Integer

# Integer validation
{ rating: 5 } ✓
{ rating: "5" } ✗  # Must be Integer, got String

# DateTime validation
{ published_at: Time.now } ✓
{ published_at: "2024-01-01" } ✗  # Must be DateTime/Time, got String
```

### Inclusion Validation

Restricts values to a predefined list.

```ruby
request do
  object :post do
    string :status, in: %w[draft published archived]
    integer :rating, in: [1, 2, 3, 4, 5]
  end
end
```

**Examples:**
```ruby
# String inclusion
{ status: "draft" } ✓
{ status: "deleted" } ✗
# Error: Attribute 'status' must be one of: draft, published, archived. Got: 'deleted'

# Integer inclusion
{ rating: 5 } ✓
{ rating: 6 } ✗
# Error: Attribute 'rating' must be one of: 1, 2, 3, 4, 5. Got: 6
```

### Format Validation

Validates that string values match specific formats using patterns and/or validators.

**Supported formats:**
- `:uuid` - UUID format (8-4-4-4-12 hexadecimal pattern)
- `:email` - RFC 2822 compliant email address
- `:password` - Password (8-16 chars, must contain digit, lowercase, and uppercase)
- `:date` - ISO 8601 date string (e.g., "2025-01-15")
- `:datetime` - ISO 8601 datetime string (e.g., "2025-01-15T10:30:00Z")
- `:time` - Time string (e.g., "10:30:00", "10:30 AM")
- `:duration` - ISO 8601 duration format (e.g., "PT2H" for 2 hours, "P1D" for 1 day, "PT30M" for 30 minutes)
- `:boolean` - Boolean string ("true", "false", "0", "1")

**Simple mode:**
```ruby
request do
  object :user do
    string :email, format: :email
    string :started_on, format: :date
    string :external_id, format: :uuid
  end
end
```

**Advanced mode with custom message:**
```ruby
request do
  object :user do
    string :email, format: { is: :email, message: "Invalid email address" }

    string :password, format: {
      is: :password,
      message: ->(attribute:, value:, **) {
        "#{attribute.to_s.capitalize} must be 8-16 characters with at least one digit, lowercase, and uppercase letter"
      }
    }

    string :started_on, format: { is: :date, message: "Invalid date format" }
  end
end
```

**Examples:**
```ruby
# UUID validation
{ external_id: "550e8400-e29b-41d4-a716-446655440000" } ✓
{ external_id: "not-a-uuid" } ✗
# Error: Attribute 'external_id' has invalid uuid format: 'not-a-uuid'

# Email validation
{ email: "user@example.com" } ✓
{ email: "invalid-email" } ✗
# Error: Attribute 'email' has invalid email format: 'invalid-email'

# Password validation
{ password: "SecurePass123" } ✓
{ password: "weak" } ✗
# Error: Attribute 'password' has invalid password format: 'weak'

# Date validation
{ started_on: "2025-01-15" } ✓
{ started_on: "not-a-date" } ✗
# Error: Attribute 'started_on' has invalid date format: 'not-a-date'

# DateTime validation
{ last_login_at: "2025-01-15T10:30:00Z" } ✓
{ last_login_at: "invalid" } ✗
# Error: Attribute 'last_login_at' has invalid datetime format: 'invalid'

# Time validation
{ notification_time: "10:30:00" } ✓
{ notification_time: "not-a-time" } ✗
# Error: Attribute 'notification_time' has invalid time format: 'not-a-time'

# Duration validation (ISO 8601 format)
{ session_duration: "PT2H" } ✓  # 2 hours
{ session_duration: "P1D" } ✓   # 1 day
{ session_duration: "invalid duration" } ✗
# Error: Attribute 'session_duration' has invalid duration format: 'invalid duration'

# Boolean validation
{ email_verified: "true" } ✓
{ email_verified: "1" } ✓
{ email_verified: "yes" } ✗
# Error: Attribute 'email_verified' has invalid boolean format: 'yes'
```

**Important notes:**
- Format validation only works with `:string` type attributes
- Using format with non-string types will raise a validation error
- Blank/empty values are handled by required/optional validation
- Custom messages support both static strings and lambda functions

### Nested Object Validation

Objects (hashes) are validated recursively.

```ruby
request do
  object :post do
    string :title

    object :author do
      string :name
      string :email
      string :bio, :optional
    end
  end
end
```

**Valid:**
```ruby
{
  post: {
    title: "Hello",
    author: {
      name: "John Doe",
      email: "johndoe@example.com",
      bio: "Engineer"
    }
  }
} ✓
```

**Invalid - missing required object:**
```ruby
{
  post: {
    title: "Hello"
  }
} ✗
# Error: Attribute 'author' is required but was not provided
```

**Invalid - object is not a hash:**
```ruby
{
  post: {
    title: "Hello",
    author: "John Doe"
  }
} ✗
# Error: Attribute 'author' must be a Hash (object), got String
```

**Invalid - missing required nested attribute:**
```ruby
{
  post: {
    title: "Hello",
    author: {
      name: "John Doe"
    }
  }
} ✗
# Error: Attribute 'email' is required but was not provided
```

### Array Validation

Arrays are validated item by item.

#### Simple Arrays (Primitives)

```ruby
array :tags do
  string :_self
end
```

**Valid:**
```ruby
{ tags: ["ruby", "rails", "api"] } ✓
{ tags: [] } ✓  # Empty array is valid
```

**Invalid:**
```ruby
{ tags: ["ruby", 123, "api"] } ✗
# Error in array 'tags' at index 1: Item must match one of the defined types.
# Errors: Attribute 'tags' must be a String, got Integer
```

#### Complex Arrays (Objects)

```ruby
array :authors do
  string :name
  string :email
end
```

**Valid:**
```ruby
{
  authors: [
    { name: "John Doe", email: "johndoe@example.com" },
    { name: "John Doe", email: "bob@example.com" }
  ]
} ✓
```

**Invalid - item is not a hash:**
```ruby
{
  authors: [
    { name: "John Doe", email: "johndoe@example.com" },
    "John Doe"
  ]
} ✗
# Error in array 'authors' at index 1: Item must be a Hash (object), got String
```

**Invalid - missing required attribute in item:**
```ruby
{
  authors: [
    { name: "John Doe", email: "johndoe@example.com" },
    { name: "John Doe" }
  ]
} ✗
# Error in array 'authors' at index 1: Attribute 'email' is required but was not provided
```

#### Array Inclusion Validation

```ruby
array :tags do
  string :_self, in: %w[ruby rails api docker kubernetes]
end
```

**Valid:**
```ruby
{ tags: ["ruby", "rails"] } ✓
```

**Invalid:**
```ruby
{ tags: ["ruby", "python"] } ✗
# Error: Attribute 'tags' must be one of: ruby, rails, api, docker, kubernetes. Got: 'python'
```

## Default Behavior

### Request vs Response

**Request (Input):**
- Attributes are **required by default** when using helper mode
- Use `:optional` to make them optional

```ruby
request do
  object :post do
    string :title        # Required by default
    string :summary, :optional  # Explicitly optional
  end
end
```

**Response (Output):**
- Attributes are **optional by default**
- All attributes defined in response will be included if service returns them

```ruby
response 200 do
  object :post do
    string :id          # Optional by default
    string :title       # Optional by default
    datetime :created_at  # Optional by default
  end
end
```

### Why This Design?

**For requests:**
- Clients should explicitly provide data
- Missing data usually indicates an error
- Required by default prevents accidental omissions

**For responses:**
- Services might return partial data
- Optional by default provides flexibility
- Supports gradual API evolution

## Validation Order

Treaty validates in this order:

1. **Schema Validation** - Is the structure correct?
   - Are objects present?
   - Are required attributes present?
   - Are values the right types?

2. **Value Validation** - Are the values valid?
   - Type checking (String, Integer, DateTime)
   - Inclusion validation (in: list)
   - Nested validation (objects and arrays)

3. **Transformation** - Apply transformations
   - Default values
   - Attribute renaming (as:)
   - Symbol/string key conversion

## Error Messages

Treaty provides detailed, contextual error messages:

### Simple Errors

```ruby
# Missing required field
Attribute 'title' is required but was not provided

# Wrong type
Attribute 'rating' must be an Integer, got String

# Invalid inclusion
Attribute 'status' must be one of: draft, published, archived. Got: 'deleted'
```

### Nested Errors

```ruby
# Object validation
Attribute 'author' must be a Hash (object), got String

# Nested attribute error
In object 'author': Attribute 'email' is required but was not provided
```

### Array Errors

```ruby
# Simple array error
Error in array 'tags' at index 2: Item must match one of the defined types.
Errors: Attribute 'tags' must be a String, got Integer

# Complex array error
Error in array 'authors' at index 1: Attribute 'name' is required but was not provided

# Array type error
Attribute 'tags' must be an Array, got String
```

## Custom Error Messages

Use advanced mode for custom error messages with both static strings and dynamic lambda functions.

### Static Messages

Simple string messages for straightforward error descriptions:

```ruby
request do
  object :post do
    string :title, required: {
      is: true,
      message: "Post title cannot be empty"
    }

    string :category, inclusion: {
      in: %w[tech business lifestyle],
      message: "Please select a valid category: tech, business, or lifestyle"
    }

    integer :rating, inclusion: {
      in: [1, 2, 3, 4, 5],
      message: "Rating must be between 1 and 5 stars"
    }
  end
end
```

**Error output:**
```ruby
# Custom required message
Post title cannot be empty

# Custom inclusion message
Please select a valid category: tech, business, or lifestyle

# Custom inclusion message for integer
Rating must be between 1 and 5 stars
```

### Lambda Messages (Dynamic)

Use lambda functions to create dynamic, context-aware error messages with access to validation context:

```ruby
request do
  object :post do
    # Required validation with lambda
    string :title, required: {
      is: true,
      message: lambda do |attribute:, value:, **|
        "The #{attribute} field is mandatory (received: #{value.inspect})"
      end
    }

    # Inclusion validation with lambda
    string :category, inclusion: {
      in: %w[tech business lifestyle],
      message: lambda do |attribute:, value:, allowed_values:, **|
        "Invalid #{attribute}: '#{value}'. Must be one of: #{allowed_values.join(', ')}"
      end
    }

    # Type validation with lambda
    integer :rating, required: {
      is: true,
      message: lambda do |attribute:, expected_type:, actual_type:, **|
        "Expected #{attribute} to be #{expected_type}, but got #{actual_type}"
      end
    }
  end
end
```

**Error output:**
```ruby
# Dynamic required message
The title field is mandatory (received: nil)

# Dynamic inclusion message
Invalid category: 'gaming'. Must be one of: tech, business, lifestyle

# Dynamic type message
Expected rating to be integer, but got String
```

### Available Lambda Arguments

Different validators provide different context arguments to lambda functions:

**Required Validator:**
- `attribute` - Symbol: The attribute name
- `value` - Object: The current value (nil or empty)

**Inclusion Validator:**
- `attribute` - Symbol: The attribute name
- `value` - Object: The invalid value
- `allowed_values` - Array: List of valid values

**Type Validator:**
- `attribute` - Symbol: The attribute name
- `value` - Object: The value being validated
- `expected_type` - Symbol: Expected type (`:integer`, `:string`, etc.)
- `actual_type` - Class: Actual class of the value

### Practical Lambda Examples

```ruby
response 200 do
  object :movie do
    # Contextual required message
    string :plot, required: {
      is: true,
      message: ->(attribute:, **) { "Movie #{attribute} is required for catalog" }
    }

    # Detailed inclusion message with range
    integer :rating, inclusion: {
      in: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      message: lambda do |attribute:, value:, allowed_values:, **|
        "Invalid #{attribute}: #{value}. Must be between #{allowed_values.min} and #{allowed_values.max}"
      end
    }

    # Array with custom inclusion message
    array :cast do
      string :role_type, inclusion: {
        in: %w[lead supporting cameo],
        message: ->(value:, **) { "Role type '#{value}' is not recognized" }
      }
    end
  end
end
```

### Best Practices for Custom Messages

**1. Use static messages for simple, unchanging errors:**
```ruby
# Good - clear and simple
string :email, required: { is: true, message: "Email is required" }
```

**2. Use lambda messages when you need context:**
```ruby
# Good - dynamic and informative
string :status, inclusion: {
  in: %w[draft published],
  message: lambda do |attribute:, value:, allowed_values:, **|
    "#{attribute.capitalize} '#{value}' is invalid. Choose: #{allowed_values.join(' or ')}"
  end
}
```

**3. Keep lambda messages concise:**
```ruby
# Good - concise but informative
message: ->(attribute:, value:, **) { "Invalid #{attribute}: #{value}" }

# Avoid - too verbose
message: lambda do |attribute:, value:, **|
  "An error has occurred with the attribute named #{attribute}. " \
  "The value that was provided is #{value}, which is not acceptable. " \
  "Please provide a valid value according to the rules."
end
```

**4. Use catch-all parameters (`**`) for forward compatibility:**
```ruby
# Good - handles future context additions
message: ->(attribute:, value:, **) { "Error in #{attribute}: #{value}" }

# Avoid - might break if new context is added
message: ->(attribute:, value) { "Error in #{attribute}: #{value}" }
```

## Validation Examples

### Complete Blog Post

```ruby
version 1, default: true do
  strategy Treaty::Strategy::ADAPTER

  request do
    object :post do
      string :title
      string :content
      string :summary, :optional
      string :category, in: %w[tech business lifestyle]

      array :tags, :optional do
        string :_self, in: %w[ruby rails api docker kubernetes react vue]
      end

      object :author do
        string :name
        string :email
        string :bio, :optional

        array :socials, :optional do
          string :provider, in: %w[twitter linkedin github]
          string :handle
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

      array :tags, :required do
        string :_self
      end

      object :author, :required do
        string :name, :required
        string :email, :required
        string :bio

        array :socials do
          string :provider, :required
          string :handle, :required
        end
      end

      integer :views
      datetime :created_at, :required
      datetime :updated_at, :required
    end
  end

  delegate_to Posts::CreateService
end
```

### API with Pagination and Filters

```ruby
version 1, default: true do
  strategy Treaty::Strategy::ADAPTER

  request do
    # Pagination at root level
    object :_self do
      integer :page, default: 1
      integer :limit, default: 12, in: [12, 24, 48, 96]
    end

    # Filters as separate object
    object :filters do
      string :title, :optional
      string :category, :optional, in: %w[tech business lifestyle]
      string :status, :optional, in: %w[draft published archived]
      datetime :created_after_at, :optional
      datetime :created_before_at, :optional

      array :tags, :optional do
        string :_self
      end
    end

    # Sorting options
    object :sort do
      string :by, default: "created_at", in: %w[created_at updated_at title]
      string :direction, default: "desc", in: %w[asc desc]
    end
  end

  response 200 do
    array :posts do
      string :id, :required
      string :title, :required
      string :summary, :required
      string :category, :required
      datetime :created_at, :required
    end

    object :meta do
      integer :count, :required
      integer :page, :required
      integer :limit, :required
      integer :total_pages, :required
    end
  end

  delegate_to Posts::IndexService
end
```

## Best Practices

### 1. Use Helper Mode for Clarity

```ruby
# Good - clear and readable
string :title
string :summary, :optional

# Acceptable but more verbose
string :title, required: true
string :summary, optional: true
```

### 2. Validate Input Strictly

```ruby
# Good - strict validation for requests
request do
  object :post do
    string :title
    string :status, in: %w[draft published]
  end
end
```

### 3. Keep Response Validation Flexible

```ruby
# Good - flexible response validation
response 200 do
  object :post do
    string :id
    string :title
    datetime :created_at
    # All optional by default - service decides what to include
  end
end
```

### 4. Use Inclusion for Enums

```ruby
# Good - use inclusion for predefined values
string :status, in: %w[draft published archived]
string :priority, in: %w[low medium high urgent]
integer :rating, in: [1, 2, 3, 4, 5]
```

### 5. Validate Nested Structures

```ruby
# Good - validate nested structures thoroughly
object :author do
  string :name
  string :email

  array :socials, :optional do
    string :provider, in: %w[twitter linkedin github]
    string :handle
  end
end
```

### 6. Provide Helpful Error Messages

```ruby
# Good - custom messages for better UX
string :email, required: {
  is: true,
  message: "Email address is required for account creation"
}

integer :age, inclusion: {
  in: (18..100).to_a,
  message: "Age must be between 18 and 100"
}
```

## Validation vs Transformation

**Validation** ensures data is correct:
- Type checking
- Required fields
- Inclusion validation
- Structure validation

**Transformation** modifies data:
- Default values
- Attribute renaming
- Key conversion (string → symbol)

Both happen in ADAPTER strategy, but validation happens **before** transformation.

## Next Steps

- [Transformation](./transformation.md) - Understand data transformation
- [Strategies](./strategies.md) - DIRECT vs ADAPTER strategies
- [Examples](./examples.md) - Practical examples

[← Back to Documentation](./README.md)
