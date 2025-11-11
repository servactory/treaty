# Transformation

[← Back to Documentation](./README.md)

## Overview

Transformation is the process of modifying data as it flows through Treaty. It only applies when using the **ADAPTER** strategy. With **DIRECT** strategy, no transformation occurs.

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
    - Rename attributes (as:)
    - Convert string keys → symbol keys
    ↓
Service (receives transformed Ruby hash)
    ↓
Response Transformation
    - Apply defaults
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

Within the ADAPTER strategy, transformations happen in this order:

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

## Practical Examples

### Example 1: Pagination with Defaults

```ruby
version 1, default: true do
  strategy Treaty::Strategy::ADAPTER

  request do
    object :_self do
      integer :page, default: 1
      integer :limit, default: 12
    end
  end

  response 200 do
    object :posts do
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
  strategy Treaty::Strategy::ADAPTER

  request do
    object :profile do
      array :socials do
        string :provider, :required
        string :handle, :required, as: :value
        string :display_url, :optional, as: :url
      end
    end
  end

  response 200 do
    object :profile do
      string :id
      array :socials do
        string :provider
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
    strategy Treaty::Strategy::ADAPTER

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
    strategy Treaty::Strategy::ADAPTER

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

## DIRECT vs ADAPTER Transformation

### DIRECT Strategy

**No transformation occurs:**

```ruby
version 1 do
  strategy Treaty::Strategy::DIRECT

  request { object :post }
  response(200) { object :post }

  delegate_to Posts::CreateService
end
```

**Client sends:**
```ruby
{ "post" => { "title" => "Hello" } }
```

**Service receives (unchanged):**
```ruby
{ "post" => { "title" => "Hello" } }
```

### ADAPTER Strategy

**Full transformation pipeline:**

```ruby
version 2 do
  strategy Treaty::Strategy::ADAPTER

  request do
    object :post do
      string :title, :required
      string :status, default: "draft"
    end
  end

  response 201 do
    object :post do
      string :id
      string :title
      string :status
      integer :views, default: 0
    end
  end

  delegate_to Posts::CreateService
end
```

**Client sends:**
```ruby
{ "post" => { "title" => "Hello" } }
```

**Service receives (transformed):**
```ruby
{
  post: {
    title: "Hello",
    status: "draft"  # Default applied, keys symbolized
  }
}
```

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

- [Validation](./validation.md) - understand validation system
- [Strategies](./strategies.md) - DIRECT vs ADAPTER
- [Examples](./examples.md) - practical examples

[← Back: Validation](./validation.md) | [← Back to Documentation](./README.md) | [Next: Examples →](./examples.md)
