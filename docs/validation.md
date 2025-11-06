# Validation

[← Back to Documentation](./README.md)

## Overview

Treaty provides comprehensive validation for both requests and responses. Validation only applies when using the **ADAPTER** strategy. With **DIRECT** strategy, no validation occurs.

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
string :category, in: { list: %w[tech business], message: "Invalid category" }
```

## Validation Types

### Required Validation

Ensures an attribute is present and not empty.

```ruby
request do
  scope :post do
    string :title, :required
    string :content, :required
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
  scope :post do
    string :title, :required
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
  scope :post do
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
  scope :post do
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

### Nested Object Validation

Objects (hashes) are validated recursively.

```ruby
request do
  scope :post do
    string :title, :required

    object :author, :required do
      string :name, :required
      string :email, :required
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
  string :_self, :required
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
  string :name, :required
  string :email, :required
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
  scope :post do
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
  scope :post do
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
   - Are scopes present?
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

Use advanced mode for custom error messages:

```ruby
request do
  scope :post do
    string :title, required: {
      is: true,
      message: "Post title cannot be empty"
    }

    string :category, in: {
      list: %w[tech business lifestyle],
      message: "Please select a valid category: tech, business, or lifestyle"
    }

    integer :rating, in: {
      list: [1, 2, 3, 4, 5],
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

## Validation Examples

### Complete Blog Post

```ruby
version 1, default: true do
  strategy Treaty::Strategy::ADAPTER

  request do
    scope :post do
      string :title, :required
      string :content, :required
      string :summary, :optional
      string :category, :required, in: %w[tech business lifestyle]

      array :tags, :optional do
        string :_self, in: %w[ruby rails api docker kubernetes react vue]
      end

      object :author, :required do
        string :name, :required
        string :email, :required
        string :bio, :optional

        array :socials, :optional do
          string :provider, :required, in: %w[twitter linkedin github]
          string :handle, :required
        end
      end
    end
  end

  response 201 do
    scope :post do
      string :id
      string :title
      string :content
      string :summary
      string :category

      array :tags do
        string :_self
      end

      object :author do
        string :name
        string :email
        string :bio

        array :socials do
          string :provider
          string :handle
        end
      end

      integer :views
      datetime :created_at
      datetime :updated_at
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
    scope :_self do
      integer :page, default: 1
      integer :limit, default: 12, in: [12, 24, 48, 96]
    end

    # Filters as separate scope
    scope :filters do
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
    scope :sort do
      string :by, default: "created_at", in: %w[created_at updated_at title]
      string :direction, default: "desc", in: %w[asc desc]
    end
  end

  response 200 do
    scope :posts do
      string :id
      string :title
      string :summary
      string :category
      datetime :created_at
    end

    scope :meta do
      integer :count
      integer :page
      integer :limit
      integer :total_pages
    end
  end

  delegate_to Posts::IndexService
end
```

## Best Practices

### 1. Use Helper Mode for Clarity

```ruby
# Good - clear and readable
string :title, :required
string :summary, :optional

# Acceptable but more verbose
string :title, required: true
string :summary, optional: true
```

### 2. Validate Input Strictly

```ruby
# Good - strict validation for requests
request do
  scope :post do
    string :title, :required
    string :status, :required, in: %w[draft published]
  end
end
```

### 3. Keep Response Validation Flexible

```ruby
# Good - flexible response validation
response 200 do
  scope :post do
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
object :author, :required do
  string :name, :required
  string :email, :required

  array :socials, :optional do
    string :provider, :required, in: %w[twitter linkedin github]
    string :handle, :required
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

integer :age, in: {
  list: (18..100).to_a,
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

- [Transformation](./transformation.md) - understand data transformation
- [Strategies](./strategies.md) - DIRECT vs ADAPTER
- [Examples](./examples.md) - practical examples

[← Back: Nested Structures](./nested-structures.md) | [← Back to Documentation](./README.md) | [Next: Transformation →](./transformation.md)
