# Attributes

[← Back to Documentation](./README.md)

## Overview

Attributes are the building blocks of Treaty contracts. This guide covers all available attribute types (string, integer, boolean, date, time, datetime, object, array) and their options, including validation, defaults, and transformation rules.

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

#### Date

```ruby
date :birth_date
date :published_on
```

**Type validation:** Value must be a Ruby `Date`

#### Time

```ruby
time :created_at
time :updated_at
```

**Type validation:** Value must be a Ruby `Time` or `ActiveSupport::TimeWithZone`

#### DateTime

```ruby
datetime :scheduled_at
datetime :expires_at
```

**Type validation:** Value must be a Ruby `DateTime` or `ActiveSupport::TimeWithZone`

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

#### transform

Applies custom lambda-based transformations to attribute values.

```ruby
# Simple mode
string :title, transform: ->(value:) { value.strip }
string :email, transform: ->(value:) { value.downcase }

# Advanced mode with custom error message
string :slug, transform: {
  is: ->(value:) { value.parameterize },
  message: "Failed to generate slug"
}
```

**Important:**
- Lambda must accept a named `value:` parameter
- All exceptions raised in lambda are caught and converted to `Treaty::Exceptions::Validation`
- Only applied to non-nil values (nil values pass through unchanged)
- Applied after validation but before final output

**See:** [Transformation](./transformation.md#custom-transformations) for detailed examples

#### computed

Computes attribute values from other attributes in the data. Unlike `transform` which receives only the current attribute's value, `computed` receives all raw data from the root level.

```ruby
# Simple mode
string :full_name, :optional, computed: ->(**attrs) {
  "#{attrs.dig(:user, :first_name)} #{attrs.dig(:user, :last_name)}"
}

integer :word_count, :optional, computed: ->(**attrs) {
  attrs.dig(:post, :content).to_s.split.size
}

string :slug, :optional, computed: ->(**attrs) {
  attrs.dig(:post, :title).to_s.downcase.gsub(/\s+/, "-")
}

# Advanced mode with custom error message
integer :total, :optional, computed: {
  is: ->(**attrs) { attrs.dig(:order, :quantity).to_i * attrs.dig(:order, :price).to_i },
  message: "Failed to calculate total"
}

# Lambda message for dynamic error
string :formatted_total, :optional, computed: {
  is: ->(**attrs) { "$#{attrs.dig(:order, :total)}" },
  message: ->(attribute:, error:) { "Computation failed for #{attribute}: #{error}" }
}
```

**Important:**
- Lambda must accept keyword arguments (`**attrs`) to receive all raw data
- All exceptions raised in lambda are caught and converted to `Treaty::Exceptions::Validation`
- Computed always executes, ignoring any existing value for the attribute
- Computed attributes should be marked as `:optional` since the value comes from computation, not input
- Computed runs FIRST in the modifier chain (before transform, cast, default, as)
- Use `dig` to safely access nested values

**Computed vs Transform:**

| Aspect | `computed:` | `transform:` |
|--------|-------------|--------------|
| **Input** | All raw data (`**attrs`) | Current attribute value (`value:`) |
| **Purpose** | Derive value from other attributes | Transform the current value |
| **Execution** | Always runs, ignores existing value | Only runs on non-nil values |
| **Order** | First in modifier chain | After computed |

**See:** [Transformation: Computed Values](./transformation.md#computed-values) for detailed examples

#### cast

Automatically converts values between different types using predefined conversion rules.

```ruby
# Simple mode
string :published_on, cast: :date           # String to Date
string :created_at, cast: :time             # String to Time
string :scheduled_at, cast: :datetime       # String to DateTime
time :created_at, cast: :integer            # Time to Unix timestamp
date :published_on, cast: :string           # Date to string
boolean :active, cast: :integer             # Boolean to integer (1/0)
string :featured, cast: :boolean            # String to boolean

# Advanced mode with custom error message
string :published_at, cast: {
  to: :datetime,
  message: "Invalid date format provided"
}
```

**Supported conversions:**

**From Integer:**
- `integer -> string`: Converts to string representation
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

**Important:**
- Cast only works with scalar types (`integer`, `string`, `boolean`, `date`, `time`, `datetime`)
- Array and Object types do not support casting
- Casting to the same type is allowed (no-op)
- Only applied to non-nil values (nil values pass through unchanged)
- All conversion errors are caught and converted to `Treaty::Exceptions::Validation`

**Use cast when:**
- Converting between built-in types
- You want automatic, consistent type conversions
- You need standard date/time/timestamp conversions

**Use transform when:**
- You need custom transformation logic
- The transformation doesn't fit predefined casting rules

**Combining cast and transform:**
```ruby
# Transform cleans the string, then cast converts it to datetime
string :scheduled_at,
       transform: ->(value:) { value.strip },
       cast: :datetime
```

**Important:** When combining multiple modifiers (`computed`, `default`, `transform`, `cast`, `as`), their order matters. Options execute sequentially in the order they're defined. Always use this recommended order:

1. `computed:` - Compute value from other attributes (always runs first regardless of position)
2. `transform:` - Clean/prepare values
3. `cast:` - Convert types
4. `default:` - Apply default if still nil
5. `as:` - Rename attributes

```ruby
# ✅ Recommended order
string :published_at,
       transform: ->(value:) { value.strip },
       cast: :datetime,
       default: Time.current  # Already DateTime

# With computed (for derived values)
string :slug, :optional,
       computed: ->(**attrs) { attrs.dig(:post, :title) },
       transform: ->(value:) { value.downcase.gsub(/\s+/, "-") }

# ❌ Wrong type in default
string :published_at,
       cast: :datetime,
       default: "2024-01-15"  # String! Should be Time/DateTime
```

**See:** [Transformation: Option Execution Order](./transformation.md#option-execution-order) for comprehensive guide on ordering, conflicts, and troubleshooting.

**See:** [Transformation: Type Casting](./transformation.md#type-casting) for detailed examples

#### if / unless

Conditionally includes attributes based on runtime data evaluation. Unlike validators (which check data) and modifiers (which transform data), the `if` and `unless` options control whether an attribute should exist in the output at all.

```ruby
# Using if - include when condition is true
integer :rating, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }
array :tags, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }

# Using unless - include when condition is false
integer :draft_version, unless: ->(post:) { post[:published_at].present? }
string :draft_notes, unless: ->(post:) { post[:status] == "published" }

# Named argument pattern (cleaner for nested structures)
integer :views, if: ->(post:) { post[:published_at].present? }
string :admin_note, if: ->(user:, post:) { user[:role] == "admin" && post[:flagged] }
```

**How it works:**
- `if` - If condition evaluates to `true` → attribute is processed normally (validated and transformed)
- `if` - If condition evaluates to `false` → attribute is completely excluded from output
- `unless` - If condition evaluates to `false` → attribute is processed normally (validated and transformed)
- `unless` - If condition evaluates to `true` → attribute is completely excluded from output
- Lambda receives raw data as named arguments
- All exceptions in lambda are caught and wrapped in `Treaty::Exceptions::Validation`

**Important:**
- Does NOT support simple mode (`if: true`) or advanced mode (`if: { is: ..., message: ... }`)
- Only accepts Proc/Lambda directly
- Lambda must return truthy/falsy value
- Evaluated BEFORE validators and modifiers run
- Works with all attribute types (including nested objects and arrays)
- Cannot use both `if` and `unless` on the same attribute (mutual exclusivity error)

**Use cases:**

1. **Show fields only when published:**
```ruby
response 200 do
  object :post do
    string :id
    string :title
    datetime :published_at, :optional
    # Rating only visible for published posts
    integer :rating, if: ->(post:) { post[:published_at].present? }
    # Draft notes only for unpublished posts
    string :draft_notes, unless: ->(post:) { post[:published_at].present? }
  end
end
```

2. **Show analytics when data exists:**
```ruby
response 200 do
  object :product do
    string :name
    string :price
    # Analytics only shown when there are views
    object :analytics, if: ->(product:) { product[:view_count].to_i > 0 } do
      integer :view_count
      integer :click_count
      integer :conversion_rate
    end
  end
end
```

3. **Conditional metadata based on status:**
```ruby
response 200 do
  object :article do
    string :title
    string :status
    # Draft metadata only for unpublished articles (using unless)
    object :draft_data, unless: ->(article:) { article[:status] == "published" } do
      datetime :last_edited
      string :editor_notes
    end
    # Published metadata only for published articles (using if)
    object :publication_data, if: ->(article:) { article[:status] == "published" } do
      datetime :published_at
      integer :view_count
    end
  end
end
```

**Data access pattern:**
```ruby
# For data structure: { post: { title: "...", published_at: "..." } }

# Option 1: Keyword splat (accepts any structure)
if: ->(**attributes) { attributes.dig(:post, :published_at).present? }

# Option 2: Named arguments (type-safe for known structure)
if: ->(post:) { post[:published_at].present? }

# Option 3: Multiple named arguments
if: ->(user:, post:) { user[:role] == "admin" || post[:author_id] == user[:id] }
```

**Execution order:**
The `if` / `unless` conditional is evaluated FIRST, before any validation or transformation:
1. `if` / `unless` - Check condition (skip attribute if condition fails)
2. Validators - Validate value (`required`, `type`, `inclusion`, `format`)
3. Modifiers - Transform value (`default`, `transform`, `cast`, `as`)

**Common patterns:**
```ruby
# Conditional with validation (using if)
integer :rating,
        if: ->(post:) { post[:status] == "published" },
        in: [1, 2, 3, 4, 5]  # Validation only runs if condition is true

# Conditional with validation (using unless)
integer :draft_version,
        unless: ->(post:) { post[:status] == "published" },
        in: [1, 2, 3, 4, 5]  # Validation only runs if condition is true

# Conditional with transformation
string :public_url,
        if: ->(post:) { post[:status] == "published" },
        transform: ->(value:) { value.downcase }  # Transform only runs if condition is true

# Conditional with default
integer :priority,
        unless: ->(post:) { post[:status] == "published" },
        default: 0  # Default only applies if condition is true
```

**Error handling:**
```ruby
# If lambda raises exception
integer :rating, if: ->(post:) { post[:metadata][:status].upcase }  # NoMethodError if metadata is nil

# Treaty catches it and raises:
# Treaty::Exceptions::Validation: "Conditional evaluation failed for attribute 'rating': undefined method `[]' for nil:NilClass"
```

**Mutual exclusivity:**
```ruby
# ERROR: Cannot use both if and unless on the same attribute
integer :rating,
        if: ->(post:) { post[:status] == "published" },
        unless: ->(post:) { post[:draft] }

# Raises: Treaty::Exceptions::Validation
# "Attribute 'rating' cannot have both 'if' and 'unless' options"
```

**See:** [Validation: Conditional Attributes](./validation.md#conditional-attributes) for more examples

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

**Error handling:**
- All exceptions raised in message lambdas are caught and converted to `Treaty::Exceptions::Validation`
- Original error message is preserved and included in the validation error
- Ensures custom message logic errors don't crash your application

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

Type validation happens automatically:

```ruby
# If client sends: { "age": "25" } (string instead of integer)
# Treaty raises: Attribute 'age' must be an Integer, got String

integer :age, :required
```

**Supported type checks:**
- `string` → Ruby `String`
- `integer` → Ruby `Integer`
- `boolean` → Ruby `TrueClass` or `FalseClass`
- `date` → Ruby `Date`
- `time` → Ruby `Time` or `ActiveSupport::TimeWithZone`
- `datetime` → Ruby `DateTime` or `ActiveSupport::TimeWithZone`
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

- [Nested Structures](./nested-structures.md) - Working with objects and arrays
- [Validation](./validation.md) - Validation system details
- [Transformation](./transformation.md) - Data transformation

[← Back to Documentation](./README.md)
