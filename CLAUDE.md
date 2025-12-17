# CLAUDE.md - Treaty Development Guide

## Project Overview

**Treaty** is a Ruby gem for defining and managing REST API contracts with versioning support in Ruby on Rails applications.

| Property | Value |
|----------|-------|
| Language | Ruby 3.2+ (tested: 3.2, 3.3, 3.4, 3.5.0-preview1) |
| Framework | Rails 7.1+ (tested: 7.1, 7.2, 8.0, 8.1) |
| Version | 0.17.0 |
| License | MIT |
| Repository | https://github.com/servactory/treaty |

### Core Features

1. **Type Safety** - Strict type checking for request/response data with 8 attribute types
2. **API Versioning** - Manage multiple concurrent API versions with semantic versioning support
3. **Unified Validation** - Same attribute system across requests, responses, and entities
4. **Entity Classes (DTOs)** - Reusable data transfer objects with inheritance support
5. **Built-in Validation** - 4 validators (required, type, inclusion, format) with 8 format types
6. **Data Transformation** - Transform data with computed values (`computed:`), custom lambdas (`transform:`), and automatic type casting (`cast:`)
7. **Type Casting** - 26 predefined type conversions between scalar types
8. **Conditional Attributes** - Include/exclude attributes dynamically with `if:` and `unless:` conditionals
9. **Inventory System** - Pass controller-specific data to services efficiently with lazy evaluation
10. **Deprecation Management** - Mark versions as deprecated with flexible conditions
11. **Internationalization** - Full I18n support with custom error messages
12. **Nested Structures** - Support for nested objects and arrays up to 5 levels deep
13. **Rails Integration** - Automatic setup via Rails Engine with zero configuration
14. **Servactory Integration** - Special error handling for Servactory services

## Repository Structure

```
treaty/
├── lib/treaty/
│   ├── attribute/          # Core attribute system (DSL, validation)
│   │   ├── option/         # Option processors (validators, modifiers)
│   │   └── validators/     # Type validators
│   ├── controller/         # Rails controller integration
│   ├── entity/             # DTO/Entity classes
│   ├── request/            # Request handling
│   ├── response/           # Response handling
│   ├── versions/           # Version management
│   ├── inventory/          # Inventory system
│   └── exceptions/         # Exception classes
├── spec/
│   ├── sandbox/app/        # Example implementations
│   │   ├── treaties/       # Treaty definitions (9 files)
│   │   ├── dtos/           # DTO definitions (10 files)
│   │   └── services/       # Services (16 files)
│   └── treaties/           # Treaty contract tests
└── docs/                   # Documentation (18 files)
```

## Development Commands

```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/path/file.rb  # Run specific test
bundle exec rubocop                  # Run linting
bundle exec rubocop -a               # Auto-fix issues
rake                                 # Run tests + rubocop

# Multi-version Rails testing
BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bundle exec rspec
bundle exec appraisal rspec          # Test all Rails versions
```

## Coding Standards

- **Frozen String Literals**: All files must start with `# frozen_string_literal: true`
- **RuboCop**: Enforced via `servactory-rubocop` gem
- **Naming**:
  - Classes/Modules: `PascalCase`
  - Methods/Variables: `snake_case`
  - Constants: `SCREAMING_SNAKE_CASE`
  - Files: `snake_case.rb`
- **Module structure mirrors file structure**: `lib/treaty/attribute/dsl.rb` → `Treaty::Attribute::DSL`

## Core Architecture

### Design Patterns

1. **Registry Pattern** - Central registry for all option processors (`Option::Registry`)
2. **Factory Pattern** - Factories for request, response, version, inventory creation
3. **DSL-Driven Design** - Expressive, declarative APIs via `method_missing`
4. **Lazy Evaluation** - Inventory items cached, evaluated only when accessed

### Three-Phase Processing

```
1. Schema Validation  → Validates DSL correctness (attribute definitions)
2. Value Validation   → Validates runtime data (required, type, inclusion, format)
3. Value Transformation → Applies defaults, transformations, casting, renaming
```

### Option Processing Pipeline

```
DSL Definition
    ↓
HelperMapper (Convert :required/:optional to options)
    ↓
OptionNormalizer (Convert simple mode to advanced mode)
    ↓
OptionOrchestrator (Coordinate processing phases)
    ↓
Result
```

## Treaty DSL

### Version Definition

```ruby
class Posts::CreateTreaty < ApplicationTreaty
  version 1, default: true do
    summary "Initial version"

    request do
      object :post do
        string :title, :required
        string :content
      end
    end

    response 201 do
      object :post do
        string :id
        string :title
        datetime :created_at
      end
    end

    delegate_to Posts::CreateService
  end

  version 2 do
    summary "Added tags support"
    deprecated { ENV["API_V2_DEPRECATED"] == "true" }
    # ...
  end
end
```

### Delegation Patterns

```ruby
# Class constant
delegate_to Posts::CreateService

# With custom method
delegate_to Posts::CreateService => :call!

# Lambda/Proc
delegate_to ->(params:) { params }
delegate_to(lambda do |params:, inventory:|
  { post: params[:post] }
end)

# Path-style string (auto-constantized)
delegate_to "posts/stable/create_service"  # → Posts::Stable::CreateService
```

### Controller Integration

```ruby
class PostsController < ApplicationController
  treaty :create do
    provide :current_user
    provide :posts, from: :load_posts
    provide :meta, from: -> { { timestamp: Time.current } }
  end
end
```

## Attribute System

### Types (8 types)

| Type | Ruby Class | Example |
|------|-----------|---------|
| `string` | String | `string :name` |
| `integer` | Integer | `integer :age` |
| `boolean` | TrueClass/FalseClass | `boolean :active` |
| `date` | Date | `date :published_on` |
| `time` | Time, TimeWithZone | `time :created_at` |
| `datetime` | DateTime, TimeWithZone | `datetime :scheduled_at` |
| `object` | Hash | `object :author do ... end` |
| `array` | Array | `array :tags do ... end` |

### Validators (4 options)

| Validator | Purpose | Example |
|-----------|---------|---------|
| `required:` | Presence validation | `string :title, :required` |
| `type:` | Type checking (auto-applied) | `integer :age, type: { message: "..." }` |
| `inclusion:` / `in:` | Value in allowed set | `string :status, in: %w[draft published]` |
| `format:` | String format validation | `string :email, format: :email` |

**Supported formats**: `:uuid`, `:email`, `:password`, `:date`, `:datetime`, `:time`, `:duration`, `:boolean`

```ruby
# Helper mode
string :title, :required
string :bio, :optional

# Simple mode
string :title, required: true

# Advanced mode with custom message
string :title, required: { is: true, message: "Title is required" }
string :email, required: {
  is: true,
  message: ->(attribute:, value:) { "#{attribute} must be provided" }
}
```

### Modifiers (5 options)

| Modifier | Purpose | Key | Example |
|----------|---------|-----|---------|
| `computed:` | Compute value from other attributes | `:is` | `string :slug, :optional, computed: ->(**attributes) { attributes.dig(:post, :title).downcase }` |
| `default:` | Set default value | `:is` | `integer :page, default: 1` |
| `transform:` | Custom lambda transformation | `:is` | `string :title, transform: ->(value:) { value.strip }` |
| `cast:` | Type conversion | `:to` | `string :date, cast: :datetime` |
| `as:` | Rename attribute | `:is` | `string :handle, as: :value` |

```ruby
# Computed (derive from other attributes)
string :full_name, :optional, computed: (lambda do |**attributes|
  "#{attributes.dig(:user, :first_name)} #{attributes.dig(:user, :last_name)}"
end)
integer :word_count, :optional, computed: (lambda do |**attributes|
  attributes.dig(:post, :content).to_s.split.size
end)

# Default values
integer :page, default: 1
datetime :created_at, default: -> { Time.current }

# Transform
string :email, transform: ->(value:) { value.downcase.strip }

# Cast (string → datetime, datetime → string, etc.)
string :published_at, cast: :datetime
datetime :created_at, cast: :string

# Rename
string :user_id, as: :id  # Request: client sends 'user_id', service gets 'id'
```

**Supported casts**: Between `string`, `integer`, `boolean`, `date`, `time`, `datetime`

**Note**: Computed attributes should be marked as `:optional` since the value comes from computation, not input

### Conditionals (2 options)

| Conditional | Purpose | When included |
|-------------|---------|---------------|
| `if:` | Include attribute conditionally | When lambda returns `true` |
| `unless:` | Exclude attribute conditionally | When lambda returns `false` |

```ruby
# Include when condition is true
integer :rating, if: ->(post:) { post[:status] == "published" }

# Exclude when condition is true
string :password, unless: ->(post:) { post[:visibility] == "public" }

# With nested structures
object :analytics, if: ->(product:) { product[:view_count].to_i > 0 } do
  integer :view_count
  integer :click_count
end
```

**Note**: Cannot use both `if` and `unless` on the same attribute.

### Option Execution Order

Treaty automatically sorts options for correct execution. Users can write options in any order.

**Execution order (automatic):**
1. Conditionals (`if:`, `unless:`) — processed separately in ValidationOrchestrator
2. Validators: `type:` → `required:` → `inclusion:` → `format:`
3. Modifiers: `transform:` → `cast:` → `computed:` → `default:` → `as:`

**Position values (internal):** type=100, required=200, inclusion=300, format=400, transform=500, cast=600, computed=700, default=800, as=900

```ruby
# Both are equivalent — Treaty sorts automatically
string :published_at, cast: :datetime, transform: ->(value:) { value.strip }
string :published_at, transform: ->(value:) { value.strip }, cast: :datetime
```

**Note:** Ensure `default:` values match the target type when using `cast:`.

## Entity Classes

**CRITICAL**: Attributes in Entity classes are **required by default** (opposite of request/response blocks).

```ruby
class PostDto < Treaty::Entity
  object :post do
    string :id              # required by default
    string :title           # required by default
    string :bio, :optional  # explicitly optional

    object :author do
      string :name
      string :email, format: :email
    end

    array :tags do
      string :_self  # _self represents array elements
    end
  end
end

# Usage in treaty
version 1 do
  request PostDto
  response 201, PostDto
end

# Reuse in nested blocks
object :author do
  use_entity(AuthorDto)
end
```

### Default Behavior Differences

| Context | Attributes default |
|---------|-------------------|
| Request blocks | **optional** (`required: false`) |
| Response blocks | **optional** (`required: false`) |
| Entity classes | **required** (`required: true`) |

## Inventory System

### Controller DSL

```ruby
class PostsController < ApplicationController
  treaty :index do
    provide :current_user                       # Shorthand: uses method with same name
    provide :posts, from: :load_posts           # Method source
    provide :meta, from: -> { build_metadata }  # Lambda source
    provide :api_version, from: 3               # Direct value
  end

  private

  def load_posts
    Post.where(user: current_user).published
  end
end
```

### Service Access

```ruby
class Posts::IndexService
  def self.call(inventory:, params:)
    current_user = inventory.current_user  # Lazy evaluation
    posts = inventory.posts

    # Or convert to hash (evaluates all items)
    data = inventory.to_h

    { posts: posts.map { |p| serialize(p) } }
  end
end
```

## Testing

### Test Structure

```
spec/
├── treaties/     # Treaty contract tests
├── dtos/         # Entity/DTO tests
├── controllers/  # Controller integration tests
└── support/      # Helpers, matchers, shared examples
```

### Example Test

```ruby
# frozen_string_literal: true

RSpec.describe Gate::API::Posts::CreateTreaty do
  subject(:perform) { described_class.call!(context:, inventory:, version:, params:) }

  let(:context) { instance_double(ApplicationController) }
  let(:inventory) { Treaty::Executor::Inventory.new(collection, context) }
  let(:collection) { Treaty::Inventory::Collection.new }

  context "when valid params" do
    let(:version) { "1" }
    let(:params) { { post: { title: "Title", content: "Content" } } }

    it { expect { perform }.not_to raise_error }

    it "returns expected structure" do
      result = perform
      expect(result.data).to include("post")
      expect(result.status).to eq(201)
    end
  end

  context "when invalid params" do
    let(:version) { "1" }
    let(:params) { {} }

    it "raises validation error", :aggregate_failures do
      expect { perform }.to raise_error do |error|
        expect(error).to be_a(Treaty::Exceptions::Validation)
        expect(error.message).to include("post")
      end
    end
  end
end
```

### Test Helpers

```ruby
# spec/support/request_helper.rb
include RequestHelper
assign_json_headers_with(version: 1)
```

## Common Pitfalls

### Required vs Optional

```ruby
# Entity: required by default
class UserDto < Treaty::Entity
  object :user do
    string :name       # required!
    string :bio, :optional
  end
end

# Request/Response: optional by default
request do
  object :user do
    string :name       # optional!
    string :email, :required
  end
end
```

### Modifier Order

```ruby
# WRONG: Default before cast with wrong type
string :published_at,
       cast: :datetime,
       default: "2024-01-15"  # String, but DateTime expected!

# CORRECT: Default matches target type
string :published_at,
       cast: :datetime,
       default: Time.current  # DateTime object
```

### Special `:_self` Object

```ruby
# _self merges attributes to root level
request do
  object :_self do
    string :signature
    integer :page
  end
end
# Expects: { signature: "...", page: 1 }
# NOT: { _self: { signature: "...", page: 1 } }

# _self in arrays represents elements
array :tags do
  string :_self
end
# Expects: ["tag1", "tag2"]
```

### Format Validation

Format validation **only works with string type**:
```ruby
string :email, format: :email  # Correct
integer :code, format: :uuid   # Will not work as expected
```

### Cast Limitations

- Only scalar types: `string`, `integer`, `boolean`, `date`, `time`, `datetime`
- Array and Object types do **NOT** support casting

### Never Use Mutable Defaults

```ruby
# WRONG
array :items, default: []   # Shared mutable object!
object :meta, default: {}   # Shared mutable object!

# CORRECT
array :items, default: -> { [] }
object :meta, default: -> { {} }
```

### Servactory Integration

Treaty automatically catches Servactory exceptions:
- `Servactory::Exceptions::Input` → `Treaty::Exceptions::Execution`
- `Servactory::Exceptions::Internal` → `Treaty::Exceptions::Execution`
- `Servactory::Exceptions::Output` → `Treaty::Exceptions::Execution`
- `Servactory::Exceptions::Failure` → `Treaty::Exceptions::Execution`

---

**Version**: 0.17.0 | **Last Updated**: 2025-12-02
