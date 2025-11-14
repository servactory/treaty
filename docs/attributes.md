# Attributes

[← Back to Documentation](./README.md)

## Attribute Types

Treaty supports the following attribute types:

### Primitive Types

#### String

```ruby
string :title
string :email
string :bio, :optional
```

**Type validation:** Value must be a Ruby `String`

#### Integer

```ruby
integer :age
integer :count
integer :page, default: 1
```

**Type validation:** Value must be a Ruby `Integer`

#### Boolean

```ruby
boolean :published
boolean :active
boolean :featured, :optional
```

**Type validation:** Value must be `TrueClass` or `FalseClass`

**Important:** Only actual Ruby boolean values are accepted. Type coercion is not performed:
- ✅ Accepted: `true`, `false`
- ❌ Rejected: any other type (Integer, String, NilClass, etc.)

#### DateTime

```ruby
datetime :created_at
datetime :published_at
```

**Type validation:** Value must be `DateTime`, `Time`, or `Date`

### Complex Types

#### Object

Represents a nested hash structure.

```ruby
object :author do
  string :name
  string :email
end
```

**Type validation:** Value must be a Ruby `Hash`

**See:** [Nested Structures](./nested-structures.md) for detailed information

#### Array

Represents an array of items.

```ruby
# Simple array (primitives)
array :tags do
  string :_self
end

# Complex array (objects)
array :authors do
  string :name
  string :email
end
```

**Type validation:** Value must be a Ruby `Array`

**See:** [Nested Structures](./nested-structures.md) for detailed information

## Attribute Options

### Helpers (Shorthand Syntax)

#### :required

Marks attribute as required (must be present and non-empty).

```ruby
string :title
integer :age
```

**Equivalent to:**
```ruby
string :title, required: true
integer :age, required: true
```

#### :optional

Marks attribute as optional (can be nil or missing).

```ruby
string :bio, :optional
integer :rating, :optional
```

**Equivalent to:**
```ruby
string :bio, required: false
integer :rating, required: false
```

### Simple Mode Options

#### required

```ruby
string :title, required: true   # Must be present
string :bio, required: false    # Can be missing
```

**Validation:**
- `true` - value must be present and non-empty
- `false` - value can be nil or missing

**Default values:**
- Request attributes: `required: true`
- Response attributes: `required: false`

#### default

Sets a default value when attribute is nil.

```ruby
integer :page, default: 1
integer :limit, default: 12
string :format, default: "json"
```

**With Proc:**
```ruby
datetime :created_at, default: -> { Time.current }
string :uuid, default: -> { SecureRandom.uuid }
```

**Important:** Default is applied ONLY when value is `nil`. Empty strings, empty arrays, and `false` are NOT replaced.

**NEVER use** `default: []` or `default: {}` for arrays/objects:

```ruby
# Wrong!
array :tags, default: []
object :meta, default: {}

# Correct - arrays and objects automatically handle empty state
array :tags
object :meta
```

#### as

Renames attribute during transformation.

```ruby
# Request: expect 'handle', output as 'value'
string :handle, as: :value

# Response: expect 'value', output as 'handle'
string :value, as: :handle
```

**Use case - Request (incoming data):**
```ruby
request do
  object :social do
    string :user_id, as: :id  # Client sends 'user_id', service receives 'id'
  end
end
```

**Use case - Response (outgoing data):**
```ruby
response 200 do
  object :social do
    string :id, as: :user_id  # Service returns 'id', client receives 'user_id'
  end
end
```

#### in (inclusion)

Validates that value is in allowed set.

```ruby
string :provider, in: %w[twitter linkedin github]
string :status, in: %w[draft published archived]
integer :rating, in: [1, 2, 3, 4, 5]
```

**Validation:** Value must be one of the specified values.

#### format

Validates that string values match specific formats. **Only works with string type attributes.**

```ruby
# Simple mode
string :email, format: :email
string :birth_date, format: :date
string :external_id, format: :uuid

# Advanced mode with custom message
string :email, format: { is: :email, message: "Invalid email address" }
string :password, format: {
  is: :password,
  message: "Password must be 8-16 characters with at least one digit, lowercase, and uppercase"
}
```

**Supported formats:**
- `:uuid` - UUID format (8-4-4-4-12 hexadecimal pattern)
- `:email` - RFC 2822 compliant email address
- `:password` - Password (8-16 chars, must contain digit, lowercase, and uppercase)
- `:date` - ISO 8601 date string (e.g., "2025-01-15")
- `:datetime` - ISO 8601 datetime string (e.g., "2025-01-15T10:30:00Z")
- `:time` - Time string (e.g., "10:30:00", "10:30 AM")
- `:duration` - ISO 8601 duration format (e.g., "PT2H", "P1D", "PT30M")
- `:boolean` - Boolean string ("true", "false", "0", "1")

**See:** [Format Validation](./validation.md#format-validation) for detailed examples

### Advanced Mode Options

All simple mode options can be extended with custom error messages using either static strings or dynamic lambda functions:

#### Static Messages

```ruby
string :title, required: { is: true, message: "Title is mandatory" }
string :provider, inclusion: { in: %w[twitter linkedin], message: "Invalid provider" }
integer :age, required: { is: true, message: "Age must be provided" }
```

#### Lambda Messages

Use lambda functions for dynamic, context-aware error messages:

```ruby
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

# Format validation with lambda
string :password, format: {
  is: :password,
  message: lambda do |attribute:, value:, format_name:, **|
    "#{attribute.to_s.capitalize} must match #{format_name} format (got: #{value})"
  end
}
```

**Format:**
```ruby
option_name: { value_key: value, message: "String" | lambda }
```

**Value keys:**
- Most options use `:is` as value key
- Inclusion uses `:in` as value key

**Lambda arguments** vary by validator (see [Validation](./validation.md#available-lambda-arguments) for details):
- Required: `attribute`, `value`
- Inclusion: `attribute`, `value`, `allowed_values`
- Type: `attribute`, `value`, `expected_type`, `actual_type`
- Format: `attribute`, `value`, `format_name`

## Default Behavior

### Request Attributes

By default, request attributes are **required**:

```ruby
request do
  object :post do
    string :title          # required: true (implicit)
    string :content        # required: true (implicit)
    string :bio, :optional # required: false (explicit)
  end
end
```

### Response Attributes

By default, response attributes are **optional**:

```ruby
response 200 do
  object :post do
    string :id             # required: false (implicit)
    string :title          # required: false (implicit)
    string :rating, :required  # required: true (explicit, in response)
  end
end
```

## Attribute Naming

Attribute names should be:
- Symbols (`:title`, not `"title"`)
- Snake case (`:created_at`, not `:createdAt`)
- Descriptive (`:bio`, not `:b`)

## Combining Options

You can combine multiple options:

```ruby
string :status, :required, in: %w[draft published], default: "draft"
integer :limit, :optional, default: 12
string :handle, :required, as: :value
```

**With block (for nested structures):**
```ruby
object :author, :required do
  string :name, :required
  string :email
end

array :tags, :optional do
  string :_self, :required
end
```

## Type Validation

Type validation happens automatically with ADAPTER strategy:

```ruby
# If client sends: { "age": "25" } (string instead of integer)
# Treaty raises: Attribute 'age' must be an Integer, got String

integer :age, :required
```

**Supported type checks:**
- `string` → Ruby `String`
- `integer` → Ruby `Integer`
- `boolean` → Ruby `TrueClass` or `FalseClass`
- `datetime` → Ruby `DateTime`, `Time`, or `Date`
- `object` → Ruby `Hash`
- `array` → Ruby `Array`

## Presence Validation

With `required: true`, value is considered present if:
- It is not `nil`
- It is not empty (for `String`, `Array`, `Hash`)

```ruby
# These fail presence validation:
nil
""
[]
{}

# These pass presence validation:
"text"
[1, 2, 3]
{ key: "value" }
false  # boolean false is considered present!
```

## Examples

### Simple Blog Post

```ruby
request do
  object :post do
    string :title
    string :content
    string :summary, :optional
    boolean :published, :optional
    array :tags, :optional do
      string :_self
    end
  end
end
```

### User Profile

```ruby
response 200 do
  object :user do
    string :id
    string :email
    string :name
    integer :age
    string :bio
    datetime :created_at
    datetime :updated_at
  end
end
```

### Pagination

```ruby
response 200 do
  object :meta do
    integer :count
    integer :page, default: 1
    integer :limit, default: 12
    integer :total_pages
  end
end
```

### Social Profile

```ruby
object :social do
  string :provider, in: %w[twitter linkedin github]
  string :handle, as: :value
  string :url
end
```

## Next Steps

- [Nested Structures](./nested-structures.md) - working with objects and arrays
- [Validation](./validation.md) - validation system details
- [Transformation](./transformation.md) - data transformation

[← Back: Defining Contracts](./defining-contracts.md) | [← Back to Documentation](./README.md) | [Next: Nested Structures →](./nested-structures.md)
