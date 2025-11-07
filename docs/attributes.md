# Attributes

[← Back to Documentation](./README.md)

## Attribute Types

Treaty supports the following attribute types:

### Primitive Types

#### String

```ruby
string :title
string :email, :required
string :bio, :optional
```

**Type validation:** Value must be a Ruby `String`

#### Integer

```ruby
integer :age
integer :count, :required
integer :page, default: 1
```

**Type validation:** Value must be a Ruby `Integer`

#### Boolean

```ruby
boolean :published
boolean :active, :required
boolean :featured, :optional
```

**Type validation:** Value must be `TrueClass` or `FalseClass`

**Important:** Only actual Ruby boolean values are accepted. Type coercion is not performed:
- ✅ Accepted: `true`, `false`
- ❌ Rejected: any other type (Integer, String, NilClass, etc.)

#### DateTime

```ruby
datetime :created_at
datetime :published_at, :required
```

**Type validation:** Value must be `DateTime`, `Time`, or `Date`

### Complex Types

#### Object

Represents a nested hash structure.

```ruby
object :author do
  string :name, :required
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
  string :name, :required
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
string :title, :required
integer :age, :required
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

# Response: expect 'value' from service, output as 'handle'
string :value, as: :handle
```

**Use case - Request (incoming data):**
```ruby
request do
  scope :social do
    string :user_id, as: :id  # Client sends 'user_id', service receives 'id'
  end
end
```

**Use case - Response (outgoing data):**
```ruby
response 200 do
  scope :social do
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

### Advanced Mode Options

All simple mode options can be extended with custom error messages:

```ruby
string :title, required: { is: true, message: "Title is mandatory" }
string :provider, inclusion: { in: %w[twitter linkedin], message: "Invalid provider" }
integer :age, required: { is: true, message: "Age must be provided" }
```

**Format:**
```ruby
option_name: { value_key: value, message: "Custom message" }
```

**Value keys:**
- Most options use `:is` as value key
- Inclusion uses `:in` as value key

## Default Behavior

### Request Attributes

By default, request attributes are **required**:

```ruby
request do
  scope :post do
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
  scope :post do
    string :id             # required: false (implicit)
    string :title          # required: false (implicit)
    string :rating, :required  # required: true (explicit)
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
  scope :post do
    string :title, :required
    string :content, :required
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
  scope :user do
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
  scope :meta do
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
  string :provider, :required, in: %w[twitter linkedin github]
  string :handle, :required, as: :value
  string :url
end
```

## Next Steps

- [Nested Structures](./nested-structures.md) - working with objects and arrays
- [Validation](./validation.md) - validation system details
- [Transformation](./transformation.md) - data transformation

[← Back: Defining Contracts](./defining-contracts.md) | [← Back to Documentation](./README.md) | [Next: Nested Structures →](./nested-structures.md)
