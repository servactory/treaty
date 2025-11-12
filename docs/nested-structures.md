# Nested Structures

[← Back to Documentation](./README.md)

## Overview

Treaty supports two types of nested structures:
- **Objects** - nested hash structures
- **Arrays** - collections of items

## Object Type

Objects represent nested hash structures with defined attributes.

### Basic Object

```ruby
object :author do
  string :name
  string :email
  string :bio
end
```

**Expected data:**
```ruby
{
  author: {
    name: "John Doe",
    email: "johndoe@example.com",
    bio: "Software engineer"
  }
}
```

### Required vs Optional Objects

```ruby
# Object itself is optional, but if provided, must have required attributes
object :author, :optional do
  string :name
  string :email
end

# Object itself is required
object :settings do
  string :theme, default: "light"
  string :language, default: "en"
end
```

### Deeply Nested Objects

```ruby
object :post do
  string :title

  object :author do
    string :name

    object :company do
      string :name
      string :website
    end
  end
end
```

**Expected data:**
```ruby
{
  post: {
    title: "Hello World",
    author: {
      name: "John Doe",
      company: {
        name: "Acme Corp",
        website: "acme.com"
      }
    }
  }
}
```

### Empty Objects

```ruby
# When object has no nested attributes defined
object :meta

# Equivalent to accepting any hash
# No validation of internal structure
```

## Array Type

Arrays represent collections of items.

### Simple Arrays (Primitives)

Arrays containing primitive values like strings, integers, or datetimes.

```ruby
array :tags do
  string :_self
end
```

**Expected data:**
```ruby
{
  tags: ["ruby", "rails", "api"]
}
```

**The `:_self` notation:**
- Indicates array contains primitive values
- Each array item is validated against the `:_self` attribute type

**Examples:**

```ruby
# Array of strings
array :tags do
  string :_self
end
# Data: ["ruby", "rails"]

# Array of integers
array :ratings do
  integer :_self
end
# Data: [4, 5, 3, 5]

# Array of booleans
array :flags do
  boolean :_self
end
# Data: [true, false, true]

# Array of datetimes
array :timestamps do
  datetime :_self
end
# Data: [Time.now, 1.day.ago]
```

### Complex Arrays (Objects)

Arrays containing hash objects with defined structure.

```ruby
array :authors do
  string :name
  string :email
  string :bio
end
```

**Expected data:**
```ruby
{
  authors: [
    { name: "John Doe", email: "johndoe@example.com", bio: "Engineer" },
    { name: "John Doe", email: "bob@example.com", bio: "Designer" }
  ]
}
```

**Each array item must be a hash** with the defined structure.

### Required vs Optional Arrays

```ruby
# Array itself is optional, can be missing or nil
array :tags, :optional do
  string :_self
end

# Array itself is required, must be present
# Can be empty [] but not nil
array :authors do
  string :name
  string :email
end
```

### Arrays with Nested Objects

```ruby
array :posts do
  string :title

  object :author do
    string :name
    string :email
  end

  array :comments do
    string :text
    string :author_name
  end
end
```

**Expected data:**
```ruby
{
  posts: [
    {
      title: "First Post",
      author: {
        name: "John Doe",
        email: "johndoe@example.com"
      },
      comments: [
        { text: "Great post!", author_name: "John Doe" }
      ]
    }
  ]
}
```

### Arrays with Options

```ruby
# Simple array with validation
array :tags, :optional do
  string :_self, in: %w[ruby rails api docker]
end

# Complex array with validation
array :socials, :optional do
  string :provider, in: %w[twitter linkedin github]
  string :handle, as: :value
  string :url
end
```

## Nesting Limits

Treaty limits nesting depth to prevent excessive complexity.

**Default limit:** 3 levels

**Configuration:**
```ruby
Treaty::Engine.configure do |config|
  config.treaty.attribute_nesting_level = 3
end
```

**Example of 3 levels:**
```ruby
# Level 1
object :post do
  # Level 2
  object :author do
    # Level 3
    array :socials do
      string :provider
      # Level 4 would raise error!
    end
  end
end
```

## Validation Rules

### Object Validation

For objects:
1. Value must be a Hash
2. All required attributes must be present
3. All attributes must match their types
4. Nested structures are validated recursively

### Array Validation

For arrays:
1. Value must be an Array
2. Each item is validated individually

**Simple arrays:**
- Each item must match the `:_self` type
- Each item goes through the same validation

**Complex arrays:**
- Each item must be a Hash
- Each item is validated against the defined structure

## Error Messages

Treaty provides contextual error messages:

**Simple array error:**
```
Error in array 'tags' at index 2: Item must match one of the defined types.
Errors: Attribute 'tags' must be a String, got Integer
```

**Complex array error:**
```
Error in array 'authors' at index 1: Attribute 'name' is required but was not provided or is empty
```

**Object error:**
```
Attribute 'author' must be a Hash (object), got String
```

## Practical Examples

### Blog Post with Everything

```ruby
request do
  object :post do
    string :title
    string :summary
    string :content

    # Simple array
    array :tags, :optional do
      string :_self
    end

    # Object with nested array
    object :author do
      string :name
      string :bio

      # Complex array
      array :socials, :optional do
        string :provider, in: %w[twitter linkedin github]
        string :handle, as: :value
      end
    end

    # Array of objects
    array :categories, :optional do
      string :name
      string :slug
    end
  end
end
```

**Expected data:**
```ruby
{
  post: {
    title: "Getting Started with Treaty",
    summary: "Learn how to use Treaty",
    content: "...",
    tags: ["ruby", "rails", "api"],
    author: {
      name: "John Doe",
      bio: "Software Engineer",
      socials: [
        { provider: "twitter", handle: "alice" },
        { provider: "github", handle: "alice_dev" }
      ]
    },
    categories: [
      { name: "Tutorial", slug: "tutorial" },
      { name: "Ruby", slug: "ruby" }
    ]
  }
}
```

### API Response Structure

```ruby
response 200 do
  # Array of posts
  array :posts do
    string :id
    string :title
    string :summary

    object :author do
      string :name
      string :email
    end

    array :tags do
      string :_self
    end

    integer :views
    datetime :created_at
  end

  # Pagination metadata
  object :meta do
    integer :count
    integer :page, default: 1
    integer :limit, default: 12
    integer :total_pages
  end
end
```

## Best Practices

### 1. Keep Nesting Shallow

```ruby
# Good - 2 levels
object :author do
  string :name
  object :company do
    string :name
  end
end

# Avoid - too deep nesting
object :post do
  object :author do
    object :company do
      object :address do  # Too deep!
        string :city
      end
    end
  end
end
```

### 2. Use `:_self` for Simple Arrays

```ruby
# Good - clear that it's an array of strings
array :tags do
  string :_self
end

# Wrong - trying to use array without defining structure
array :tags  # This declares empty object, not primitive array
```

### 3. Don't Use Default for Arrays/Objects

```ruby
# Wrong!
array :tags, default: []
object :meta, default: {}

# Correct - arrays and objects handle empty state automatically
array :tags
object :meta
```

### 4. Validate Array Items

```ruby
# Good - validate each item
array :statuses do
  string :_self, in: %w[draft published archived]
end

# Good - validate object structure
array :authors do
  string :name
  string :email
end
```

## Next Steps

- [Validation](./validation.md) - understand validation system
- [Transformation](./transformation.md) - data transformation
- [Examples](./examples.md) - more practical examples

[← Back: Attributes](./attributes.md) | [← Back to Documentation](./README.md) | [Next: Validation →](./validation.md)
