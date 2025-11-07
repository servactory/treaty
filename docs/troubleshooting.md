# Troubleshooting

[← Back to Documentation](./README.md)

## Common Issues and Solutions

This guide helps you diagnose and fix common issues when working with Treaty.

## Validation Errors

### "Attribute 'X' is required but was not provided"

**Problem:** Required attribute is missing from request.

**Solution:**
1. Ensure attribute is present in request data
2. Check if attribute is empty string or nil
3. Verify scope structure matches definition

**Example:**
```ruby
# Treaty expects:
request do
  scope :post do
    string :title, :required
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

### "Attribute 'X' must be a Hash (object), got TYPE"

**Problem:** Expected nested object, received primitive value.

**Solution:**
1. Ensure nested objects are sent as hashes
2. Check JSON structure
3. Verify object is required/optional

**Example:**
```ruby
# Treaty expects:
object :author, :required do
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
  string :name, :required
end

# Send:
{ "authors" => [{ "name" => "John Doe" }, { "name" => "John Doe" }] }  # ✓ Correct

# Not:
{ "authors" => ["John Doe", "John Doe"] }  # ✗ Strings instead of objects
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

### "Version X not found"

**Problem:** Requested version doesn't exist.

**Solution:**
1. Check available versions in treaty
2. Verify version number format
3. Ensure version is defined

**Example:**
```ruby
# Treaty has:
version 1 do; end
version 2 do; end

# Client requests:
?version=3  # ✗ Version 3 doesn't exist
?version=2  # ✓ Version 2 exists
```

## Strategy Issues

### No validation happening (DIRECT strategy)

**Problem:** Expecting validation but none occurs.

**Solution:**
Check if DIRECT strategy is being used. DIRECT strategy skips all validation.

**Example:**
```ruby
# DIRECT - no validation
version 1 do
  strategy Treaty::Strategy::DIRECT
  # No validation will occur
end

# ADAPTER - full validation
version 2 do
  strategy Treaty::Strategy::ADAPTER
  # Full validation will occur
end
```

### Defaults not applying

**Problem:** Default values not being set.

**Solution:**
1. Check if ADAPTER strategy is used (defaults only work with ADAPTER)
2. Verify attribute definition has `default:` option
3. Ensure attribute is actually missing (not empty string)

**Example:**
```ruby
# ADAPTER required for defaults
version 1 do
  strategy Treaty::Strategy::ADAPTER

  request do
    scope :_self do
      integer :page, default: 1  # Will apply
    end
  end
end

# DIRECT - defaults won't apply
version 2 do
  strategy Treaty::Strategy::DIRECT
  # Defaults won't work
end
```

### Attribute renaming not working

**Problem:** `as:` option not renaming attributes.

**Solution:**
1. Check if ADAPTER strategy is used (renaming only works with ADAPTER)
2. Verify `as:` option is set correctly
3. Ensure transformation happens in correct direction

**Example:**
```ruby
version 1 do
  strategy Treaty::Strategy::ADAPTER

  # Request: client 'handle' → service 'value'
  request do
    scope :social do
      string :handle, as: :value
    end
  end

  # Response: service 'value' → client 'handle'
  response 200 do
    scope :social do
      string :value, as: :handle
    end
  end
end
```

## Scope Issues

### "Scope 'X' not found"

**Problem:** Request data doesn't match scope structure.

**Solution:**
1. Check scope names in treaty
2. Verify nested scope structure
3. Ensure data is wrapped in correct scopes

**Example:**
```ruby
# Treaty expects:
request do
  scope :post do
    string :title
  end
end

# Send:
{ "post" => { "title" => "Hello" } }  # ✓ Correct

# Not:
{ "title" => "Hello" }  # ✗ Missing :post scope
{ "article" => { "title" => "Hello" } }  # ✗ Wrong scope name
```

### :_self scope confusion

**Problem:** Not understanding how `:_self` scope works.

**Solution:**
`:_self` merges attributes into parent level instead of creating nested structure.

**Example:**
```ruby
# With :_self
request do
  scope :_self do
    integer :page
  end
  scope :post do
    string :title
  end
end

# Send:
{ "page" => 1, "post" => { "title" => "Hello" } }  # ✓ Correct

# Not:
{ "_self" => { "page" => 1 }, "post" => { "title" => "Hello" } }  # ✗ Wrong

# Without :_self (regular scope)
request do
  scope :pagination do
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
  string :name, :required
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
  scope :post do
    string :title, :required
    string :status, default: "draft"
  end
end

# Service receives:
def self.call(params:)
  params[:post][:title]   # "Hello"
  params[:post][:status]  # "draft" (default applied)
end
```

## Performance Issues

### Slow request processing

**Problem:** Treaty processing takes too long.

**Solution:**
1. Use DIRECT strategy if validation not needed (prototypes only)
2. Simplify nested structures
3. Reduce validation complexity
4. Profile application to find bottleneck

**Comparison:**
```ruby
# DIRECT: ~0.1ms - no validation
version 1 do
  strategy Treaty::Strategy::DIRECT
end

# ADAPTER: ~2-5ms - full validation
version 2 do
  strategy Treaty::Strategy::ADAPTER
end
```

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

- [API Reference](./api-reference.md) - complete API documentation
- [Examples](./examples.md) - practical examples
- [Validation](./validation.md) - validation system details
- [Internationalization](./internationalization.md) - I18n setup and configuration

[← Back to Documentation](./README.md)
