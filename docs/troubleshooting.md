# Troubleshooting

[← Back to Documentation](./README.md)

## Overview

This comprehensive troubleshooting guide helps you diagnose and resolve common issues when working with Treaty. Find solutions for validation errors, version selection, controller integration, service delegation, performance issues, and internationalization problems.

## Common Issues and Solutions

This guide helps you diagnose and fix common issues when working with Treaty.

## Validation Errors

### "Attribute 'X' is required but was not provided"

**Problem:** Required attribute is missing from request.

**Solution:**
1. Ensure attribute is present in request data
2. Check if attribute is empty string or nil
3. Verify object structure matches definition

**Example:**
```ruby
# Treaty expects:
request do
  object :post do
    string :title
  end
end

# Send:
{ "post" => { "title" => "Hello" } }  # ✓ Correct

# Not:
{ "post" => {} }  # ✗ Missing title
{ "post" => { "title" => "" } }  # ✗ Empty title
{ "post" => { "title" => nil } }  # ✗ Nil title
```

### "Attribute 'X' must be a TYPE, got TYPE"

**Problem:** Attribute type doesn't match definition.

**Solution:**
1. Check attribute type in request data
2. Ensure proper type conversion before sending
3. Verify JSON serialization doesn't change types

**Example:**
```ruby
# Treaty expects:
integer :rating

# Send:
{ "rating" => 5 }  # ✓ Correct (Integer)

# Not:
{ "rating" => "5" }  # ✗ String instead of Integer
```

**Common causes:**
- Query parameters are always strings: `?page=1` → `{ "page" => "1" }`
- JSON numbers without quotes: `{"count": 5}` → Integer ✓
- JSON numbers with quotes: `{"count": "5"}` → String ✗

### "Attribute 'X' must be one of: ..., Got: 'Y'"

**Problem:** Value not in allowed list (inclusion validation).

**Solution:**
1. Check allowed values in treaty definition
2. Ensure exact match (case-sensitive)
3. Verify value is the correct type

**Example:**
```ruby
# Treaty expects:
string :status, in: %w[draft published archived]

# Send:
{ "status" => "draft" }  # ✓ Correct

# Not:
{ "status" => "Draft" }  # ✗ Case mismatch
{ "status" => "pending" }  # ✗ Not in list
```

### "Attribute 'X' has invalid FORMAT format: 'Y'"

**Problem:** Value doesn't match expected format (format validation).

**Solution:**
1. Check format requirements in treaty definition
2. Ensure value matches the specific format
3. Verify format is supported for the type

**Example:**
```ruby
# Treaty expects:
string :email, format: :email
string :birth_date, format: :date
string :external_id, format: :uuid
string :session_duration, format: :duration

# Email format:
{ "email" => "user@example.com" }  # ✓ Valid email
{ "email" => "invalid-email" }  # ✗ Invalid format

# Date format (ISO 8601):
{ "birth_date" => "2025-01-15" }  # ✓ Valid date
{ "birth_date" => "01/15/2025" }  # ✗ Wrong format
{ "birth_date" => "not-a-date" }  # ✗ Invalid

# UUID format:
{ "external_id" => "550e8400-e29b-41d4-a716-446655440000" }  # ✓ Valid UUID
{ "external_id" => "not-a-uuid" }  # ✗ Invalid format

# Duration format (ISO 8601):
{ "session_duration" => "PT2H" }  # ✓ Valid (2 hours)
{ "session_duration" => "P1D" }  # ✓ Valid (1 day)
{ "session_duration" => "2 hours" }  # ✗ Wrong format

# Password format:
{ "password" => "SecurePass123" }  # ✓ Valid (8-16 chars, digit+lowercase+uppercase)
{ "password" => "weak" }  # ✗ Too short, no uppercase, no digit

# Boolean string format:
{ "verified" => "true" }  # ✓ Valid
{ "verified" => "1" }  # ✓ Valid
{ "verified" => "yes" }  # ✗ Invalid
```

**Common format issues:**
- Email: Must be RFC 2822 compliant
- Date: Must be ISO 8601 (YYYY-MM-DD)
- DateTime: Must be ISO 8601 (YYYY-MM-DDTHH:MM:SSZ)
- Time: HH:MM:SS format
- Duration: ISO 8601 (PT2H for 2 hours, P1D for 1 day)
- UUID: 8-4-4-4-12 hexadecimal pattern
- Password: 8-16 characters, at least one digit, lowercase, and uppercase
- Boolean: "true", "false", "0", or "1"

### "Option 'format' can only be used with String type"

**Problem:** Trying to use format validation on non-string attribute.

**Solution:**
Format validation only works with string attributes. Use the correct type or remove format option.

**Example:**
```ruby
# Correct:
string :email, format: :email  # ✓ Format works with string

# Incorrect:
integer :count, format: :number  # ✗ Format doesn't work with integer
time :created_at, format: :datetime  # ✗ Use datetime type, not format
```

### "Attribute 'X' must be a Hash (object), got TYPE"

**Problem:** Expected nested object, received primitive value.

**Solution:**
1. Ensure nested objects are sent as hashes
2. Check JSON structure
3. Verify object is required/optional

**Example:**
```ruby
# Treaty expects:
object :author do
  string :name
end

# Send:
{ "author" => { "name" => "John Doe" } }  # ✓ Correct

# Not:
{ "author" => "John Doe" }  # ✗ String instead of object
```

### "Error in array 'X' at index Y: ..."

**Problem:** Array item validation failed.

**Solution:**
1. Check array item structure
2. Ensure all items match the same structure
3. Verify array type (simple vs complex)

**Example:**
```ruby
# Simple array
array :tags do
  string :_self
end

# Send:
{ "tags" => ["ruby", "rails"] }  # ✓ Correct

# Not:
{ "tags" => ["ruby", 123] }  # ✗ Mixed types

# Complex array
array :authors do
  string :name
end

# Send:
{ "authors" => [{ "name" => "John Doe" }, { "name" => "John Doe" }] }  # ✓ Correct

# Not:
{ "authors" => ["John Doe", "John Doe"] }  # ✗ Strings instead of objects
```

### "Option 'type:' can only be used with 'object' attribute type"

**Problem:** Trying to use `type:` option on non-object attribute.

**Solution:**
The `type:` option is only valid for `object` attributes. Remove it from other attribute types.

**Example:**
```ruby
# Correct:
object :author, type: User do  # ✓ type: works with object
  string :name
end

# Incorrect:
string :name, type: String  # ✗ type: doesn't work with string
array :items, type: Array   # ✗ type: doesn't work with array
```

### "Option 'type:' for attribute 'X' must be a Class"

**Problem:** The value provided to `type:` option is not a Class.

**Solution:**
Ensure the `type:` option receives a Class constant, not a string, symbol, or instance.

**Example:**
```ruby
# Correct:
object :author, type: User do  # ✓ User is a Class
  string :name
end

# Incorrect:
object :author, type: "User" do  # ✗ String, not Class
  string :name
end

object :author, type: :user do  # ✗ Symbol, not Class
  string :name
end
```

### "Attribute 'X' must be CLASS, got TYPE"

**Problem:** Object value is not an instance of the expected class.

**Solution:**
Provide either a Hash or an instance of the specified class.

**Example:**
```ruby
# Treaty expects:
object :author, type: User do
  string :name
end

# Send:
{ "author" => User.new(name: "John") }  # ✓ User instance
{ "author" => { "name" => "John" } }    # ✓ Hash also works

# Not:
{ "author" => "John" }  # ✗ String instead of User or Hash
```

## Version Issues

### Treaty not using expected version

**Problem:** Different version is being used than expected.

**Solution:**
1. Check version priority order:
   - URL parameter: `?version=2`
   - HTTP Header: `API-Version: 2`
   - Accept header: `Accept: application/vnd.api+json; version=2`
   - Default version
2. Verify default version is set correctly
3. Check if version exists in treaty

**Example:**
```ruby
# Set default version
version 3, default: true do
  # ...
end

# Request with specific version
GET /api/posts?version=2
# or
Headers: API-Version: 2
```

### "Specified version is required for validation"

**Exception:** `Treaty::Exceptions::SpecifiedVersionNotFound`

**Problem:** No version was specified and no default version is configured.

**Solution:**
1. Add a default version to your treaty
2. OR ensure clients always specify a version
3. OR handle the exception in your controller

**Example:**
```ruby
# Problem: No default version
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do; end
  version 2 do; end
  # No default specified
end

# Client request without version
Posts::CreateTreaty.call!(version: nil, params: {})
# => Raises Treaty::Exceptions::SpecifiedVersionNotFound

# Solution 1: Add default version
version 2, default: true do; end

# Solution 2: Handle in controller
rescue_from Treaty::Exceptions::SpecifiedVersionNotFound do |e|
  render json: { error: e.message }, status: :bad_request
end
```

**HTTP Status:** 400 Bad Request

### "Version X not found in treaty definition"

**Exception:** `Treaty::Exceptions::VersionNotFound`

**Problem:** Requested version doesn't exist in the treaty.

**Solution:**
1. Check available versions in treaty
2. Verify version number format matches
3. Ensure version is defined
4. Check for typos in version number

**Example:**
```ruby
# Treaty has:
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do; end
  version 2 do; end
end

# Client requests non-existent version:
Posts::CreateTreaty.call!(version: "3", params: {})
# => Raises Treaty::Exceptions::VersionNotFound
# => "Version 3 not found in treaty definition"

# Solutions:
# 1. Use existing version
?version=2  # ✓ Version 2 exists

# 2. Add the version to treaty
version 3 do
  # ...
end

# 3. Handle in controller
rescue_from Treaty::Exceptions::VersionNotFound do |e|
  render json: {
    error: e.message,
    available_versions: ["1", "2"]
  }, status: :not_found
end
```

**Common causes:**
- Version number mismatch: `version 1` vs `version "1.0.0"`
- Typos: `version "v2"` instead of `version "2"`
- Version removed but still requested by clients
- Wrong format: sending integer when string expected or vice versa

**HTTP Status:** 404 Not Found

### "Version X is deprecated and cannot be used"

**Exception:** `Treaty::Exceptions::Deprecated`

**Problem:** Requested version is marked as deprecated.

**Solution:**
1. Migrate to a non-deprecated version
2. Contact API provider for migration guide
3. Check deprecation timeline

**Example:**
```ruby
# Treaty definition
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    deprecated true  # Version 1 is deprecated
  end

  version 2, default: true do
    # Current version
  end
end

# Client requests deprecated version:
Posts::CreateTreaty.call!(version: "1", params: {})
# => Raises Treaty::Exceptions::Deprecated
# => "Version 1 is deprecated and cannot be used"

# Solution: Use non-deprecated version
?version=2  # ✓ Version 2 is active

# Handle in controller
rescue_from Treaty::Exceptions::Deprecated do |e|
  render json: {
    error: e.message,
    recommended_version: "2",
    migration_guide: "/docs/v1-to-v2"
  }, status: :gone
end
```

**HTTP Status:** 410 Gone

### "Version X cannot be both default and deprecated"

**Exception:** `Treaty::Exceptions::VersionDefaultDeprecatedConflict`

**Problem:** A version is configured with both `default: true` and `deprecated` - a logical contradiction.

**Solution:**
1. Remove `default: true` if the version should be deprecated
2. Remove the `deprecated` call if the version should be default
3. Create a new version to be the default, and deprecate the old one

**Example:**
```ruby
# ✗ INVALID: Version cannot be both default and deprecated
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do
    deprecated true  # ERROR: Conflict!
  end
end
# => Raises Treaty::Exceptions::VersionDefaultDeprecatedConflict

# ✓ VALID: Option 1 - Default without deprecation
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do
    # No deprecated - correct
  end
end

# ✓ VALID: Option 2 - Deprecated without default
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    deprecated true  # Correct
  end

  version 2, default: true do
    # New default version
  end
end

# Handle in controller (configuration error)
rescue_from Treaty::Exceptions::VersionDefaultDeprecatedConflict do |e|
  render json: {
    error: e.message,
    hint: "Contact the development team to fix the configuration"
  }, status: :internal_server_error
end
```

**Why this error exists:** A default version is used when clients don't specify a version. It must be active and usable. A deprecated version should not be used. These requirements are mutually exclusive.

**HTTP Status:** 500 Internal Server Error

### "Cannot have multiple versions marked as default"

**Exception:** `Treaty::Exceptions::VersionMultipleDefaults`

**Problem:** Multiple versions in the same treaty have `default: true`.

**Solution:**
1. Identify which version should truly be the default
2. Remove `default: true` from all other versions
3. Keep only one `default: true` declaration

**Example:**
```ruby
# ✗ INVALID: Multiple default versions
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do  # First default
  end

  version 2, default: true do  # ERROR: Second default!
  end
end
# => Raises Treaty::Exceptions::VersionMultipleDefaults

# ✓ VALID: Single default version
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    deprecated true  # Old version
  end

  version 2 do
    # Stable version, not default
  end

  version 3, default: true do
    # Only one default - correct
  end
end

# Handle in controller (configuration error)
rescue_from Treaty::Exceptions::VersionMultipleDefaults do |e|
  render json: {
    error: e.message,
    hint: "Contact the development team to fix the configuration"
  }, status: :internal_server_error
end
```

**Best practice:** The newest stable version should typically be the default.

**Why this error exists:** When a client doesn't specify a version, Treaty needs to know which single version to use. Having multiple defaults creates ambiguity.

**HTTP Status:** 500 Internal Server Error

## Object Issues

### "Object 'X' not found"

**Problem:** Request data doesn't match object structure.

**Solution:**
1. Check object names in treaty
2. Verify nested object structure
3. Ensure data is wrapped in correct objects

**Example:**
```ruby
# Treaty expects:
request do
  object :post do
    string :title
  end
end

# Send:
{ "post" => { "title" => "Hello" } }  # ✓ Correct

# Not:
{ "title" => "Hello" }  # ✗ Missing :post object
{ "article" => { "title" => "Hello" } }  # ✗ Wrong object name
```

### :_self object confusion

**Problem:** Not understanding how `:_self` object works.

**Solution:**
`:_self` merges attributes into parent level instead of creating nested structure.

**Example:**
```ruby
# With :_self
request do
  object :_self do
    integer :page
  end
  object :post do
    string :title
  end
end

# Send:
{ "page" => 1, "post" => { "title" => "Hello" } }  # ✓ Correct

# Not:
{ "_self" => { "page" => 1 }, "post" => { "title" => "Hello" } }  # ✗ Wrong

# Without :_self (regular object)
request do
  object :pagination do
    integer :page
  end
end

# Send:
{ "pagination" => { "page" => 1 } }  # ✓ Correct
```

## Array Issues

### Simple array vs complex array confusion

**Problem:** Not understanding difference between simple and complex arrays.

**Solution:**
- **Simple arrays**: Primitive values (strings, integers) - use `:_self`
- **Complex arrays**: Hash objects - define attributes directly

**Example:**
```ruby
# Simple array - primitives
array :tags do
  string :_self  # Each item is a String
end
# Data: ["ruby", "rails", "api"]

# Complex array - objects
array :authors do
  string :name   # Each item is a Hash with :name
  string :email
end
# Data: [{ name: "John Doe", email: "..." }, { name: "John Doe", email: "..." }]
```

### "Array must contain items of type..."

**Problem:** Array items don't match expected structure.

**Solution:**
1. For simple arrays: ensure all items are primitives of same type
2. For complex arrays: ensure all items are hashes with required fields

**Example:**
```ruby
# Simple array
array :tags do
  string :_self
end

{ "tags" => ["ruby", "rails"] }  # ✓ All strings
{ "tags" => ["ruby", 123] }  # ✗ Mixed types

# Complex array
array :authors do
  string :name
end

{ "authors" => [{ "name" => "John Doe" }] }  # ✓ Valid hash
{ "authors" => ["John Doe"] }  # ✗ String instead of hash
```

## Nesting Issues

### "Maximum nesting level exceeded"

**Problem:** Nested structures too deep.

**Solution:**
1. Check default nesting limit (3 levels)
2. Flatten structure if possible
3. Increase limit in configuration if necessary

**Example:**
```ruby
# Default limit: 3 levels
object :post do           # Level 1
  object :author do       # Level 2
    array :socials do     # Level 3
      string :provider
      # Level 4 would raise error
    end
  end
end

# Increase limit if needed (not recommended)
Treaty::Engine.configure do |config|
  config.treaty.attribute_nesting_level = 4
end
```

## Use Entity Issues

### "use_entity expects a Treaty::Entity::Base subclass"

**Problem:** Argument passed to `use_entity` is not a valid Entity class.

**Solution:**
1. Ensure the class inherits from `Treaty::Entity::Base` (or `ApplicationEntity`)
2. Verify the class is loaded before the treaty definition
3. Check class name spelling

**Example:**
```ruby
# ✓ Correct: Class inherits from Treaty::Entity::Base
module Shared
  class AuthorEntity < ApplicationEntity
    string :name
  end
end

object :author do
  use_entity(Shared::AuthorEntity)  # Works
end

# ✗ Wrong: Regular class
class AuthorData
  attr_accessor :name
end

object :author do
  use_entity(AuthorData)  # Error: not a Treaty::Entity::Base subclass
end
```

### "use_entity must be the only statement in the block"

**Problem:** Attempting to define attributes alongside `use_entity`, or calling `use_entity` after defining other attributes.

**Solution:**
`use_entity` must be the sole statement within an object or array block. You cannot mix inline attribute definitions with Entity reuse.

**Example:**
```ruby
# ✓ Correct: use_entity is the only statement
object :author do
  use_entity(Shared::AuthorEntity)
end

# ✗ Wrong: Attributes defined before use_entity
object :author do
  string :name  # Error: Cannot call use_entity after defining attributes
  use_entity(Shared::AuthorEntity)
end

# ✗ Wrong: Attributes defined after use_entity
object :author do
  use_entity(Shared::AuthorEntity)
  string :extra_field  # Error: Cannot define attributes after use_entity
end

# ✓ Correct: If you need additional attributes, define them in the Entity
module Shared
  class AuthorEntity < ApplicationEntity
    string :name
    string :extra_field  # Add attributes here instead
  end
end

object :author do
  use_entity(Shared::AuthorEntity)
end
```

### Wrapper options with use_entity

**Problem:** Confusion about how `:optional`, `if:`, or `unless:` work with `use_entity`.

**Solution:**
Options like `:optional` apply to the wrapper object/array, not to the Entity's internal attributes. The Entity's attribute definitions (required/optional) are preserved.

**Example:**
```ruby
class AuthorEntity < ApplicationEntity
  string :name           # required (Entity default)
  string :bio, :optional # optional
end

# :optional applies to the wrapper object, not AuthorEntity's attributes
object :author, :optional do
  use_entity(AuthorEntity)
end

# Conditional applies to wrapper
object :author, if: ->(post:) { post[:has_author] } do
  use_entity(AuthorEntity)
end
```

## Transformation Issues

### Default value has wrong type

**Problem:** Default value type doesn't match what the service expects.

**Solution:**
Ensure default value matches the target type (after any `cast:` transformation).

**Example:**
```ruby
# ❌ Wrong: String default when expecting DateTime
string :published_at, cast: :datetime, default: "2024-01-15"

# ✅ Correct: Default matches target type
string :published_at, cast: :datetime, default: Time.current
```

### Multiple transforms only using last one

**Problem:** Defined multiple `transform:` options but only the last one executes.

**Cause:** Ruby hash keys must be unique. The second `transform:` key overwrites the first.

**Solution:**
Combine all transformations in a single lambda.

**Example:**
```ruby
# ❌ Wrong: Multiple transform keys
string :data,
       transform: ->(value:) { value.strip },  # Overwritten!
       transform: ->(value:) { value.downcase }  # Only this executes

# ✅ Correct: Combined transformations
string :data,
       transform: ->(value:) { value.strip.downcase }
```

### Conditional option errors

**Problem:** Errors when using the `if` / `unless` options for conditional attributes.

**Common issues:**

**1. "Option 'if' must be a Proc or Lambda" / "Option 'unless' must be a Proc or Lambda"**

```ruby
# ❌ Wrong: Boolean value instead of lambda
string :published_at, if: true
string :password, unless: false

# ❌ Wrong: Symbol instead of lambda
string :tags, if: :published?
string :internal_notes, unless: :public?

# ✅ Correct: Lambda
string :published_at, if: ->(post:) { post[:status] == "published" }
string :password, unless: ->(post:) { post[:visibility] == "public" }
```

**2. "Conditional evaluation failed for attribute 'X'"**

```ruby
# ❌ Wrong: Error in lambda (accessing nil)
string :views, if: ->(post:) { post[:metadata][:public] }
string :password, unless: ->(post:) { post[:settings][:public] }
# Error if metadata/settings is nil

# ✅ Correct: Safe navigation
string :views, if: ->(post:) { post.dig(:metadata, :public) == true }
string :password, unless: ->(post:) { post.dig(:settings, :public) == true }
```

**3. Wrong lambda arguments**

```ruby
# ❌ Wrong: Accessing wrong data structure
object :post do
  string :published_at, if: ->(user:) { user[:role] == "admin" }
  string :password, unless: ->(user:) { user[:role] == "admin" }
  # Error: 'user' doesn't exist in 'post' context
end

# ✅ Correct: Access parent object data
object :post do
  string :published_at, if: ->(post:) { post[:status] == "published" }
  string :password, unless: ->(post:) { post[:visibility] == "public" }
end
```

**4. Condition not evaluating as expected**

```ruby
# ❌ Wrong: String comparison instead of presence check
string :draft_notes, if: ->(post:) { post[:status] == "draft" }
string :meta_description, unless: ->(post:) { post[:visibility] == "private" }
# Won't evaluate correctly if status/visibility is missing

# ✅ Correct: Handle missing values
string :draft_notes, if: ->(post:) { post[:status].to_s == "draft" }
string :meta_description, unless: ->(post:) { post[:visibility].to_s == "private" }
```

**Tips:**
- Lambda receives raw data before validation
- Use named arguments matching parent object (e.g., `post:`, `user:`)
- Use safe navigation (`dig`, `&.`, `to_s`) to handle nil values
- Test conditionals with different data scenarios
- Remember: `if` / `unless` are evaluated BEFORE validators and modifiers
- `if` includes attribute when condition is truthy, `unless` includes when condition is falsy

**See:** [Attributes: Conditional Attributes](./attributes.md#conditional-attributes) for complete documentation.

### Custom message lambda errors

**Problem:** "Custom message evaluation failed for attribute 'X': ..."

This error occurs when a custom message lambda (in advanced mode) raises an exception during execution.

**Solution:**

1. **Check lambda logic for errors:**
   ```ruby
   # ❌ Wrong: Lambda raises exception
   string :title, required: {
     is: true,
     message: ->(attribute:, **) { attribute.metadata.upcase }  # Error: undefined method for Symbol
   }

   # ✅ Correct: Safe lambda
   string :title, required: {
     is: true,
     message: ->(attribute:, **) { "#{attribute.to_s.capitalize} is required" }
   }
   ```

2. **Use safe navigation:**
   ```ruby
   # ❌ Wrong: Accessing nil
   message: ->(value:, **) { value.dig(:data, :name).upcase }

   # ✅ Correct: Safe access
   message: ->(value:, **) { value.dig(:data, :name)&.upcase || "Value is invalid" }
   ```

3. **Handle edge cases:**
   ```ruby
   # ✅ Good: Handle all cases
   message: lambda do |attribute:, value:, **|
     if value.nil?
       "#{attribute} cannot be empty"
     else
       "#{attribute} has invalid value: #{value.inspect}"
     end
   end
   ```

**Note:** All exceptions in message lambdas are caught automatically and converted to validation errors with the original error message preserved. This ensures your application doesn't crash, but you should still fix the lambda logic.

## Controller Integration Issues

### Treaty not being invoked

**Problem:** Treaty not processing requests.

**Solution:**
1. Ensure `treaty :action_name` is called in controller
2. Check treaty class naming convention
3. Verify treaty file is loaded

**Example:**
```ruby
# Controller
class Posts::PostsController < ApplicationController
  treaty :create  # This line is required

  def create
    # Treaty handles request/response automatically
  end
end

# Treaty class must exist at:
# app/treaties/posts/create_treaty.rb
class Posts::CreateTreaty < ApplicationTreaty
  version 1 do
    # ...
  end
end
```

### Treaty class not found

**Problem:** Rails can't find treaty class.

**Solution:**
1. Check file location: `app/treaties/CONTROLLER_NAME/ACTION_NAME_treaty.rb`
2. Verify class name: `CONTROLLER_NAME::ACTION_NAMETreaty`
3. Ensure file is in autoload path

**Example:**
```ruby
# Controller: PostsController
# Action: create
# File: app/treaties/posts/create_treaty.rb
# Class: Posts::CreateTreaty

# Controller: API::V1::PostsController
# Action: index
# File: app/treaties/api/v1/posts/index_treaty.rb
# Class: API::V1::Posts::IndexTreaty
```

## Service Delegation Issues

### "Service not found"

**Problem:** Delegated service class doesn't exist.

**Solution:**
1. Verify service class exists
2. Check service class name spelling
3. Ensure service is in autoload path

**Example:**
```ruby
version 1 do
  delegate_to Posts::CreateService
end

# Service must exist at:
# app/services/posts/create_service.rb
class Posts::CreateService
  def self.call(params:)
    # ...
  end
end
```

### Service not receiving correct parameters

**Problem:** Service receives unexpected data structure.

**Solution:**
1. Check transformation in request definition
2. Verify service expects symbolized keys
3. Ensure defaults are applied

**Example:**
```ruby
request do
  object :post do
    string :title
    string :status, default: "draft"
  end
end

# Service receives:
def self.call(params:)
  params[:post][:title]   # "Hello"
  params[:post][:status]  # "draft" (default applied)
end
```

## Inventory Issues

### "Inventory item 'X' not found"

**Problem:** Service tries to access inventory item that wasn't provided.

**Solution:**
1. Check inventory items defined in controller
2. Verify inventory item names match
3. Ensure `provide` is called for required items

**Example:**
```ruby
# Controller
class PostsController < ApplicationController
  treaty :index do
    provide :current_user
  end
end

# Service
class Posts::IndexService
  def self.call(inventory:, params:)
    user = inventory.current_user  # ✓ Correct
    posts = inventory.posts  # ✗ Error: 'posts' not provided
  end
end

# Solution: Add missing inventory item
treaty :index do
  provide :current_user
  provide :posts, from: :load_posts
end
```

### "Invalid inventory name"

**Problem:** Inventory name is not a Symbol.

**Solution:**
Inventory names must be symbols.

**Example:**
```ruby
# Correct:
provide :current_user   # ✓ Symbol

# Incorrect:
provide "current_user"  # ✗ String
```

### "Inventory source cannot be nil"

**Problem:** Source for inventory item is nil or missing.

**Solution:**
1. Ensure source method exists in controller
2. Verify lambda is defined correctly
3. Check that direct values are not nil

**Example:**
```ruby
# Correct:
provide :user, from: :current_user  # ✓ Method exists

# Incorrect:
provide :user, from: :nonexistent_method  # ✗ Method not found
provide :user, from: nil  # ✗ Nil source
```

### Inventory evaluation errors

**Problem:** Error occurs when evaluating inventory source.

**Solution:**
1. Check that controller methods don't raise errors
2. Verify lambda executes without errors
3. Ensure dependencies are available

**Example:**
```ruby
# Controller
class PostsController < ApplicationController
  treaty :index do
    provide :current_user
  end

  private

  def current_user
    raise "User not authenticated"  # ✗ Raises error during evaluation
  end
end

# Solution: Handle errors properly
def current_user
  User.find_by(id: session[:user_id]) || Guest.new
end
```

## Performance Issues

### Slow request processing

**Problem:** Treaty processing takes too long.

**Solution:**
1. Simplify nested structures
2. Reduce validation complexity
3. Profile application to find bottleneck
4. Use inventory for expensive operations to benefit from lazy evaluation

## Debugging Tips

### Enable verbose logging

```ruby
# config/environments/development.rb
config.log_level = :debug

# In your code
Rails.logger.debug "Treaty params: #{params.inspect}"
```

### Check treaty structure

```ruby
# In rails console
treaty = Posts::CreateTreaty.new
treaty.versions  # See all versions
treaty.default_version  # See default version
```

### Test treaty directly

```ruby
# In rails console
# Create a mock controller for testing
version = "2"  # or use the actual version number
params = { post: { title: "Test" } }

begin
  result = Posts::CreateTreaty.call!(version: version, params: params)
  puts "Success: #{result.inspect}"
  puts "Data: #{result.data}"
  puts "Status: #{result.status}"
  puts "Version: #{result.version}"
rescue Treaty::Exceptions::Validation => e
  puts "Error: #{e.message}"
end
```

### Use debugger

```ruby
# In your service
def self.call(params:)
  debugger  # or debugger
  # Inspect params structure here
end
```

## Internationalization (I18n) Issues

### Wrong language in error messages

**Problem:** Error messages appear in wrong language.

**Solution:**
1. Check current locale: `I18n.locale`
2. Verify locale is set in controller or application
3. Check Accept-Language header
4. Ensure translation files are loaded

**Example:**
```ruby
# Set locale per request
class ApplicationController < ActionController::API
  before_action :assign_locale

  def assign_locale
    I18n.locale = params[:locale] || extract_locale_from_header || :en
  end
end
```

### Missing translations

**Problem:** Seeing "translation missing" warnings.

**Solution:**
1. Create translation file: `config/locales/treaty.de.yml`
2. Copy structure from `config/locales/en.yml` in Treaty gem
3. Translate messages to your language
4. Restart Rails server

**Example:**
```yaml
# config/locales/treaty.de.yml
de:
  treaty:
    attributes:
      validators:
        required:
          blank: "Attribut '%{attribute}' ist erforderlich"
```

See [Internationalization Guide](./internationalization.md) for complete setup.

## Getting Help

If you're still stuck:

1. **Check documentation**: Review relevant sections in [Documentation](./README.md)
2. **Review examples**: Look at [Examples](./examples.md) for similar use cases
3. **Check specs**: Look at `spec/sandbox` for working examples
4. **GitHub Issues**: Search or create issue at [GitHub](https://github.com/servactory/treaty/issues)

## Next Steps

- [API Reference](./api-reference.md) - Complete API documentation
- [Examples](./examples.md) - Practical examples
- [Validation](./validation.md) - Validation system details
- [Internationalization](./internationalization.md) - I18n setup and configuration

[← Back to Documentation](./README.md)
