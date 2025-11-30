# CLAUDE.md - AI Assistant Guide for Treaty

This document provides comprehensive guidance for AI assistants working with the Treaty codebase. It covers the repository structure, development workflows, coding conventions, and best practices.

## Table of Contents

- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Core Architecture](#core-architecture)
- [Complete Feature Reference](#complete-feature-reference)
- [Development Workflow](#development-workflow)
- [Coding Conventions](#coding-conventions)
- [Testing Guidelines](#testing-guidelines)
- [Adding New Features](#adding-new-features)
- [Common Patterns](#common-patterns)
- [Advanced Features](#advanced-features)
- [Documentation](#documentation)
- [CI/CD](#cicd)
- [Internal Architecture Deep Dive](#internal-architecture-deep-dive)

## Project Overview

**Treaty** is a Ruby gem (v0.14.0) for defining and managing REST API contracts with versioning support in Ruby on Rails applications.

### Key Information

- **Language**: Ruby 3.2+ (currently tested on 3.2, 3.3, 3.4, 3.5.0-preview1)
- **Framework**: Rails 7.1+ (tested on 7.1, 7.2, 8.0, 8.1)
- **Status**: Active development (0.x series) - breaking changes may occur between minor versions
- **License**: MIT
- **Author**: Anton Sokolov (Servactory ecosystem)
- **Repository**: https://github.com/servactory/treaty
- **Codebase Size**: ~3,028 lines of Ruby code across 82 files

### Core Features

1. **Type Safety** - Strict type checking for request/response data with 8 attribute types
2. **API Versioning** - Manage multiple concurrent API versions with semantic versioning support
3. **Unified Validation** - Same attribute system across requests, responses, and entities
4. **Entity Classes (DTOs)** - Reusable data transfer objects with inheritance support
5. **Built-in Validation** - 4 validators (required, type, inclusion, format) with 8 format types
6. **Data Transformation** - Transform data with custom lambdas (`transform:`) and automatic type casting (`cast:`)
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
├── .github/
│   └── workflows/          # CI/CD workflows (test, rubocop, code-review)
├── docs/                   # Comprehensive documentation (18 files)
│   ├── getting-started.md
│   ├── core-concepts.md
│   ├── defining-contracts.md
│   ├── attributes.md
│   ├── objects.md
│   ├── nested-structures.md
│   ├── validation.md
│   ├── transformation.md
│   ├── entities.md
│   ├── versioning.md
│   ├── inventory.md
│   ├── examples.md
│   ├── internationalization.md
│   ├── api-reference.md
│   ├── cheatsheet.md
│   ├── migration-guide.md
│   ├── troubleshooting.md
│   └── README.md
├── lib/                    # Main source code (82 files)
│   └── treaty/
│       ├── attribute/      # Core attribute system (DSL, validation, transformation)
│       │   ├── dsl.rb
│       │   ├── base.rb
│       │   ├── collection.rb
│       │   ├── option_orchestrator.rb
│       │   ├── option/     # Option processing system
│       │   │   ├── base.rb
│       │   │   ├── registry.rb
│       │   │   ├── registry_initializer.rb
│       │   │   ├── helper_mapper.rb
│       │   │   ├── option_normalizer.rb
│       │   │   ├── validators/  # 4 validators
│       │   │   ├── modifiers/   # 4 modifiers
│       │   │   └── conditionals/ # 2 conditionals
│       │   └── validators/  # Type validators for 8 types
│       ├── controller/     # Rails controller integration
│       │   └── dsl.rb
│       ├── entity/         # DTO/Entity classes
│       │   ├── entity.rb
│       │   └── attribute/
│       ├── request/        # Request handling
│       │   ├── factory.rb
│       │   ├── validator.rb
│       │   ├── entity.rb
│       │   └── attribute/
│       ├── response/       # Response handling
│       │   ├── factory.rb
│       │   ├── validator.rb
│       │   ├── entity.rb
│       │   └── attribute/
│       ├── versions/       # Version management
│       │   ├── dsl.rb
│       │   ├── factory.rb
│       │   ├── semantic.rb
│       │   ├── resolver.rb
│       │   ├── executor.rb
│       │   └── workspace.rb
│       ├── inventory/      # Inventory system
│       │   ├── factory.rb
│       │   ├── inventory.rb
│       │   └── collection.rb
│       ├── executor/       # Execution layer
│       │   └── inventory.rb  # Lazy evaluation wrapper
│       ├── context/        # Context DSL
│       ├── info/           # Introspection
│       ├── exceptions/     # 15 exception classes
│       ├── base.rb         # Base class with DSL mixins
│       ├── configuration.rb
│       ├── engine.rb       # Rails engine for auto-loading
│       └── ...
├── spec/                   # Test suite (77 files)
│   ├── controllers/        # Controller tests
│   ├── dtos/              # Entity/DTO tests
│   ├── sandbox/           # Full Rails integration test app
│   │   └── app/
│   │       ├── controllers/
│   │       ├── services/   # Example services (16 files)
│   │       ├── treaties/   # Example treaty definitions (9 files)
│   │       └── dtos/       # Example DTO definitions (10 files)
│   ├── support/           # Test helpers, matchers, shared examples
│   └── treaties/          # Treaty contract tests
├── .rubocop.yml           # RuboCop configuration (inherits from servactory-rubocop)
├── .rspec                 # RSpec configuration
├── .ruby-version          # Ruby version (3.4.7)
├── Appraisals             # Multi-version Rails testing
├── Gemfile
├── Rakefile               # Default task: spec + rubocop
├── treaty.gemspec
└── README.md
```

### Key Files (Absolute Paths)

| Purpose | Path |
|---------|------|
| Entry Point | `/home/user/treaty/lib/treaty.rb` |
| Base Class | `/home/user/treaty/lib/treaty/base.rb` |
| Attribute DSL | `/home/user/treaty/lib/treaty/attribute/dsl.rb` |
| Attribute Base | `/home/user/treaty/lib/treaty/attribute/base.rb` |
| Option Orchestrator | `/home/user/treaty/lib/treaty/attribute/option_orchestrator.rb` |
| Option Registry | `/home/user/treaty/lib/treaty/attribute/option/registry.rb` |
| Version DSL | `/home/user/treaty/lib/treaty/versions/dsl.rb` |
| Version Workspace | `/home/user/treaty/lib/treaty/versions/workspace.rb` |
| Controller DSL | `/home/user/treaty/lib/treaty/controller/dsl.rb` |
| Entity Base | `/home/user/treaty/lib/treaty/entity.rb` |
| Configuration | `/home/user/treaty/lib/treaty/configuration.rb` |
| Rails Engine | `/home/user/treaty/lib/treaty/engine.rb` |
| Test Helper | `/home/user/treaty/spec/spec_helper.rb` |
| RuboCop Config | `/home/user/treaty/.rubocop.yml` |
| Gem Spec | `/home/user/treaty/treaty.gemspec` |

## Core Architecture

### Design Patterns

1. **DSL-Driven Design** - Expressive, declarative APIs for defining contracts
2. **Modular Organization** - Clear separation between request/response/version/entity concerns
3. **Reusable Components** - Unified attribute system across all definitions
4. **Rails Integration** - Automatic ActionController inclusion via Rails Engine
5. **Method Missing Magic** - Type methods (string, integer, etc.) via `method_missing`
6. **Factory Pattern** - Factories for request, response, version, and inventory creation
7. **Registry Pattern** - Central registry for all option processors
8. **Lazy Evaluation** - Inventory items and validators cached for performance
9. **Three-Phase Processing** - Schema validation → Value validation → Value transformation
10. **Orchestrator Pattern** - Coordinates entire validation/transformation flow

### The 8 Main Systems

#### 1. Attribute System (`lib/treaty/attribute/`)

**THE HEART OF TREATY** - Unified validation/transformation across request, response, and entities.

**Architecture**:
- `Treaty::Attribute::DSL` - Provides attribute definition methods via `method_missing`
- `Treaty::Attribute::Base` - Base attribute class with nesting support (max 5 levels)
- `Treaty::Attribute::Collection` - Manages collection of attributes
- `Treaty::Attribute::OptionOrchestrator` - Orchestrates all option processors through 3 phases

**Option Processing System**:
- `Option::Registry` - Central registry for all processors (validators, modifiers, conditionals)
- `Option::Base` - Base class for all option processors
- `Option::RegistryInitializer` - Auto-registers all built-in options on load
- `OptionNormalizer` - Converts simple mode to advanced mode internally
- `HelperMapper` - Maps DSL helpers (`:required`, `:optional`) to options

**Three Processing Phases**:
1. **Phase 1: Schema Validation** - Validates DSL correctness (attribute definitions)
2. **Phase 2: Value Validation** - Validates runtime data (required, type, inclusion, format)
3. **Phase 3: Value Transformation** - Applies defaults, transformations, casting, renaming

**Attribute Types** (8 types):
- `string` - Ruby String
- `integer` - Ruby Integer
- `boolean` - TrueClass/FalseClass
- `date` - Ruby Date
- `time` - Ruby Time or ActiveSupport::TimeWithZone
- `datetime` - Ruby DateTime or ActiveSupport::TimeWithZone
- `object` - Ruby Hash with nested attributes
- `array` - Ruby Array with element type definition

**Option Categories**:

**Validators (4 options)**:
1. `required:` - Presence validation (RequiredValidator)
2. `type:` - Type checking (TypeValidator, auto-applied)
3. `inclusion:` / `in:` - Inclusion validation (InclusionValidator)
4. `format:` - Format validation for strings (FormatValidator)
   - Supported formats: `:uuid`, `:email`, `:password`, `:date`, `:datetime`, `:time`, `:duration`, `:boolean`

**Modifiers (4 options)**:
1. `default:` - Default values (DefaultModifier)
2. `transform:` - Custom lambda transformations (TransformModifier)
3. `cast:` - Automatic type conversion (CastModifier)
4. `as:` - Attribute renaming (AsModifier)

**Conditionals (2 options)**:
1. `if:` - Include attribute when condition is true (IfConditional)
2. `unless:` - Exclude attribute when condition is true (UnlessConditional)

**Helpers (2 shortcuts)**:
1. `:required` - Maps to `required: true`
2. `:optional` - Maps to `required: false`

**Option Modes**:
All options (except conditionals) support three syntaxes:
- **Helper Mode**: `string :title, :required`
- **Simple Mode**: `string :title, required: true`
- **Advanced Mode**: `string :title, required: { is: true, message: "Custom error" }`

**Special Features**:
- **Maximum Nesting**: 5 levels (configurable via `Treaty.config.attribute_nesting_level`)
- **Special `:_self` Attribute**: Represents array elements or root-level object
- **Lambda Messages**: All validators support lambda-based custom error messages
- **Exception Handling**: All lambda exceptions caught and wrapped as `Treaty::Exceptions::Validation`

#### 2. Versioning System (`lib/treaty/versions/`)

Manages multiple concurrent API versions with deprecation support.

**Key Classes**:
- `Versions::DSL` - Provides `version` method for defining API versions
- `Versions::Factory` - Factory for building version configurations
- `Versions::Semantic` - Semantic version handling using `Gem::Version`
- `Versions::Resolver` - Resolves requested version or default version
- `Versions::Executor` - Stores delegated service class/proc and method
- `Versions::Workspace` - Main execution flow coordinator

**Version Support**:
- **Integer**: `1`, `2`, `3`
- **Semantic String**: `"1.0"`, `"1.0.0"`, `"2.1.0"`
- **Release Candidates**: `"1.0.0.rc1"`, `"2.0.0.beta1"`
- **Array Format**: `[1, 0, 0, :rc1]`

**Version DSL**:
```ruby
version 1, default: true do
  summary "Description of this version"
  deprecated { condition }
  request { ... }
  response(201) { ... }
  delegate_to ServiceClass
end
```

**Deprecation Strategies**:
- Boolean: `deprecated true`
- Proc with block: `deprecated { condition }`
- Lambda: `deprecated(lambda { condition })`

**Version Resolution Flow**:
1. If version specified → find exact match or raise `VersionNotFound`
2. If no version → use default version or raise `SpecifiedVersionNotFound`
3. If deprecated → raise `Deprecated` exception

#### 3. Request Handling (`lib/treaty/request/`)

Parses and validates incoming request data.

**Key Classes**:
- `Request::Factory` - Factory for building request definitions
- `Request::Validator` - Validates request parameters against definition
- `Request::Entity` - Request entity wrapper
- `Request::Attribute::Builder` - Builds request attributes
- `Request::Attribute::Attribute` - Request attribute implementation

**Default Behavior**: Attributes are **optional by default** in request blocks

**Supports**:
- Block-based definitions (creates anonymous RequestEntity)
- Entity class references
- Multiple request blocks (merged together)
- Root-level attributes via `:_self` object

#### 4. Response Handling (`lib/treaty/response/`)

Validates and formats outgoing response data.

**Key Classes**:
- `Response::Factory` - Factory for building response definitions (includes status code)
- `Response::Validator` - Validates service response against definition
- `Response::Entity` - Response entity wrapper
- `Response::Attribute::Builder` - Builds response attributes
- `Response::Attribute::Attribute` - Response attribute implementation

**Default Behavior**: Attributes are **optional by default** in response blocks

**Supports**:
- Block-based definitions (creates anonymous ResponseEntity)
- Entity class references
- Multiple status codes per version
- Status code defaults to 200 if not specified

#### 5. Controller Integration (`lib/treaty/controller/`)

Simple DSL for Rails controllers with automatic setup.

**Key Classes**:
- `Controller::DSL` - Provides `treaty` method for controller actions
- Automatically included in `ActionController::Base` and `ActionController::API` via Rails Engine

**Treaty DSL**:
```ruby
class PostsController < ApplicationController
  treaty :action_name do
    provide :current_user
    provide :posts, from: :load_posts
    provide :meta, from: -> { build_metadata }
  end
end
```

**Automatic Processing**:
1. Validates incoming parameters
2. Calls delegated service
3. Validates service response
4. Returns `Treaty::Result` object

**Treaty::Result** contains:
- `data` - Validated and transformed response data
- `status` - HTTP status code (default: 200, or as defined in response block)
- `version` - The API version that was used (e.g., "1", "2.0.0")

#### 6. Entity/DTOs (`lib/treaty/entity/`)

Reusable data transfer objects using same attribute system.

**Key Classes**:
- `Treaty::Entity` - Base class for DTOs
- Includes `Info::Entity::DSL` and `Attribute::DSL`
- `Entity::Attribute::Builder` - Builds entity attributes
- `Entity::Attribute::Attribute` - Entity attribute implementation

**CRITICAL DIFFERENCE**: Attributes in Entity classes are **required by default** (opposite of request/response)

**Usage**:
```ruby
class UserDto < Treaty::Entity
  object :user do
    string :id              # required by default
    string :email, format: :email
    string :bio, :optional  # explicitly optional
  end
end
```

**Benefits**:
- DRY principle
- Reusable across versions
- Centralized schema definitions
- Better organization

#### 7. Inventory System (`lib/treaty/inventory/`)

Passes controller-specific data to services with lazy evaluation.

**Key Classes**:
- `Inventory::Factory` - DSL factory for building inventory via `provide` method
- `Inventory::Inventory` - Single inventory item with source (symbol, lambda, or value)
- `Inventory::Collection` - Collection of inventory items
- `Executor::Inventory` - Wrapper with lazy evaluation and caching

**Controller DSL**:
```ruby
treaty :index do
  provide :current_user              # Shorthand - uses current_user method
  provide :posts, from: :load_posts  # Method source
  provide :meta, from: -> { build_metadata }  # Lambda source
  provide :api_version, from: 3      # Direct value
end
```

**Service Access**:
```ruby
class Posts::IndexService
  def self.call(inventory:, params:)
    current_user = inventory.current_user  # Lazy evaluation
    posts = inventory.posts
    meta = inventory.meta

    # Or convert to hash (evaluates all)
    data = inventory.to_h
  end
end
```

**Features**:
- Lazy evaluation (only when accessed)
- Result caching (evaluated once, cached)
- Method-based access (inventory.item_name)
- Hash conversion (to_h)

#### 8. Supporting Systems

**Configuration** (`lib/treaty/configuration.rb`):
- `version` - Lambda for version extraction (default: `->(controller) { controller }`)
- `attribute_nesting_level` - Max nesting depth (default: 5)

**Engine** (`lib/treaty/engine.rb`):
- Rails Engine for auto-loading
- Registers option processors before config initializers
- Auto-includes Controller DSL in ActionController
- Validates configuration on initialization

**Context** (`lib/treaty/context/`):
- `Context::Callable` - Provides `call!` class method
- `Context::Workspace` - Instance-level workspace

**Info System** (`lib/treaty/info/`):
- `Info::Rest::DSL` - Provides `info` method for treaty introspection
- `Info::Entity::DSL` - Entity info support

**Exceptions** (`lib/treaty/exceptions/`):
15 specific exception classes:
- `Treaty::Exceptions::Base` - Base exception
- `Treaty::Exceptions::Validation` - Validation errors
- `Treaty::Exceptions::Execution` - Service execution errors
- `Treaty::Exceptions::Inventory` - Inventory errors
- `Treaty::Exceptions::VersionNotFound` - Version resolution errors
- `Treaty::Exceptions::Deprecated` - Deprecated version accessed
- `Treaty::Exceptions::NestedAttributes` - Nesting level exceeded
- And 8 more specific exceptions

## Complete Feature Reference

### Attribute Types (8 Types)

| Type | Ruby Class | Example | Notes |
|------|-----------|---------|-------|
| `string` | String | `string :name` | Text values |
| `integer` | Integer | `integer :age` | Whole numbers |
| `boolean` | TrueClass/FalseClass | `boolean :active` | true/false only |
| `date` | Date | `date :published_on` | Date objects (not DateTime) |
| `time` | Time, ActiveSupport::TimeWithZone | `time :created_at` | Time with zone support |
| `datetime` | DateTime, ActiveSupport::TimeWithZone | `datetime :scheduled_at` | DateTime objects |
| `object` | Hash | `object :author do ... end` | Nested hash structure |
| `array` | Array | `array :tags do ... end` | Array with element types |

### Validators (4 Options)

#### 1. Required Validator

**Purpose**: Validates presence of attribute

**Modes**:
```ruby
# Helper mode
string :title, :required
string :bio, :optional

# Simple mode
string :title, required: true
string :bio, required: false

# Advanced mode
string :title, required: { is: true, message: "Title is required" }
string :email, required: {
  is: true,
  message: ->(attribute:, value:) { "#{attribute} must be provided" }
}
```

**Default Values**:
- Request attributes: `required: true`
- Response attributes: `required: false`
- Entity attributes: `required: true`

**Presence Rules**:
- `nil` - NOT present
- `""` - NOT present (empty string)
- `[]` - NOT present (empty array)
- `{}` - NOT present (empty hash)
- `false` - IS present (boolean false is valid)

#### 2. Type Validator

**Purpose**: Validates runtime value matches declared type

**Auto-applied** to all attributes

**Custom Messages**:
```ruby
integer :age, type: {
  message: ->(attribute:, expected_type:, actual_type:) {
    "Expected #{attribute} to be #{expected_type}, got #{actual_type}"
  }
}
```

#### 3. Inclusion Validator

**Purpose**: Validates value is in allowed set

**Modes**:
```ruby
# Simple mode
string :provider, in: %w[twitter linkedin github]
string :status, in: %w[draft published archived]
integer :rating, in: [1, 2, 3, 4, 5]

# Advanced mode
string :provider, inclusion: {
  in: %w[twitter linkedin github],
  message: "Invalid provider"
}

# Lambda message
string :category, inclusion: {
  in: %w[tech business lifestyle],
  message: ->(attribute:, value:, allowed_values:) {
    "Invalid #{attribute}: '#{value}'. Must be one of: #{allowed_values.join(', ')}"
  }
}
```

**Note**: Uses `:in` as value key (not `:is`)

#### 4. Format Validator

**Purpose**: Validates string values match specific formats

**Only works with string type attributes**

**Supported Formats**:

| Format | Pattern | Example |
|--------|---------|---------|
| `:uuid` | 8-4-4-4-12 hex | `"550e8400-e29b-41d4-a716-446655440000"` |
| `:email` | RFC 2822 email | `"user@example.com"` |
| `:password` | 8-16 chars, digit+lower+upper | `"Password123"` |
| `:date` | ISO 8601 date | `"2025-01-15"` |
| `:datetime` | ISO 8601 datetime | `"2025-01-15T10:30:00Z"` |
| `:time` | Time string | `"10:30:00"`, `"10:30 AM"` |
| `:duration` | ActiveSupport::Duration | `"1 day"`, `"2 hours"` |
| `:boolean` | Boolean string | `"true"`, `"false"`, `"0"`, `"1"` |

**Modes**:
```ruby
# Simple mode
string :email, format: :email
string :external_id, format: :uuid
string :birth_date, format: :date

# Advanced mode
string :email, format: { is: :email, message: "Invalid email address" }
string :password, format: {
  is: :password,
  message: "Password must be 8-16 characters with digit, lowercase, and uppercase"
}

# Lambda message
string :password, format: {
  is: :password,
  message: ->(attribute:, value:, format_name:) {
    "#{attribute} must meet complexity requirements"
  }
}
```

### Modifiers (4 Options)

#### 1. Default Modifier

**Purpose**: Sets default value when attribute is nil

**Applied ONLY when value is `nil`**

**Modes**:
```ruby
# Static value
integer :page, default: 1
integer :limit, default: 12
string :format, default: "json"

# Proc (evaluated lazily)
datetime :created_at, default: -> { Time.current }
string :uuid, default: -> { SecureRandom.uuid }

# Advanced mode
integer :page, default: { is: 1, message: nil }
```

**Important**:
- Default is NOT applied to empty strings, empty arrays, or `false`
- Procs receive no arguments
- NEVER use `default: []` or `default: {}` for arrays/objects

#### 2. Transform Modifier

**Purpose**: Applies custom lambda-based transformations

**Modes**:
```ruby
# Simple mode
string :title, transform: ->(value:) { value.strip }
string :email, transform: ->(value:) { value.downcase }
integer :amount_cents, transform: ->(value:) { value * 100 }

# Advanced mode
string :slug, transform: {
  is: ->(value:) { value.parameterize },
  message: "Failed to generate slug"
}
```

**Requirements**:
- Lambda must accept `value:` named argument
- Only applied to non-nil values
- All exceptions caught and converted to `Treaty::Exceptions::Validation`

**Examples**:
```ruby
# String transformations
string :title, transform: ->(value:) { value.strip.titleize }
string :email, transform: ->(value:) { value.downcase.strip }

# Numeric transformations
integer :amount_cents, transform: ->(value:) { value * 100 }
integer :percentage, transform: ->(value:) { (value * 100).round(2) }

# Complex transformations
string :data, transform: ->(value:) { JSON.parse(value) }
```

#### 3. Cast Modifier

**Purpose**: Automatically converts values between different types

**Only for scalar types** (integer, string, boolean, date, time, datetime)

**Modes**:
```ruby
# Simple mode
string :published_on, cast: :date
string :created_at, cast: :time
string :scheduled_at, cast: :datetime
string :featured, cast: :boolean
time :created_at, cast: :integer
date :published_on, cast: :string

# Advanced mode
string :published_at, cast: {
  to: :datetime,
  message: "Invalid date format provided"
}
```

**Note**: Uses `:to` key (not `:is`)

**Comprehensive Conversion Matrix**:

**From Integer**:
- `integer -> string`: `42` → `"42"`
- `integer -> boolean`: `0` → `false`, non-zero → `true`
- `integer -> date`: Unix timestamp → Date
- `integer -> time`: Unix timestamp → Time
- `integer -> datetime`: Unix timestamp → DateTime

**From String**:
- `string -> integer`: `"42"` → `42`
- `string -> boolean`: `"true"`, `"yes"`, `"1"`, `"on"` → `true` (case-insensitive)
- `string -> date`: ISO8601 string → Date
- `string -> time`: ISO8601 string → Time
- `string -> datetime`: ISO8601 string → DateTime

**From Boolean**:
- `boolean -> string`: `true` → `"true"`, `false` → `"false"`
- `boolean -> integer`: `true` → `1`, `false` → `0`

**From Date**:
- `date -> string`: Date → ISO8601 format
- `date -> integer`: Date → Unix timestamp
- `date -> time`: Date → Time (start of day)
- `date -> datetime`: Date → DateTime (start of day)

**From Time**:
- `time -> string`: Time → ISO8601 format
- `time -> integer`: Time → Unix timestamp
- `time -> date`: Time → Date
- `time -> datetime`: Time → DateTime

**From DateTime**:
- `datetime -> string`: DateTime → ISO8601 format
- `datetime -> integer`: DateTime → Unix timestamp
- `datetime -> date`: DateTime → Date
- `datetime -> time`: DateTime → Time

**Limitations**:
- Array and Object types do NOT support casting
- Casting to same type is allowed (no-op)
- Only applied to non-nil values

**Use Cases**:

**Request Casting** (Convert client data to service-friendly types):
```ruby
request do
  string :published_at, :optional, cast: :datetime    # String → DateTime
  string :featured, cast: :boolean                    # "true" → true
  integer :timestamp, cast: :datetime                 # Unix → DateTime
  string :published_on, cast: :date                   # String → Date
end
```

**Response Casting** (Convert service data to client-friendly types):
```ruby
response 200 do
  datetime :created_at, cast: :string      # DateTime → ISO8601 string
  datetime :published_at, cast: :integer   # DateTime → Unix timestamp
  boolean :active, cast: :integer          # true → 1
  date :published_on, cast: :string        # Date → ISO8601 string
end
```

#### 4. As Modifier

**Purpose**: Renames attributes during transformation

**Modes**:
```ruby
# Simple mode
string :handle, as: :value
string :user_id, as: :id

# Advanced mode
string :handle, as: { is: :value, message: nil }
```

**Direction**:
- **Request**: expects original name, outputs as new name
  - `string :handle, as: :value` → Client sends "handle", service receives "value"
- **Response**: expects new name, outputs as original name
  - `string :value, as: :handle` → Service returns "value", client receives "handle"

**Examples**:
```ruby
# Request renaming
request do
  object :social do
    string :user_id, as: :id  # Client sends 'user_id', service receives 'id'
  end
end

# Response renaming
response 200 do
  object :social do
    string :id, as: :user_id  # Service returns 'id', client receives 'user_id'
  end
end
```

### Conditionals (2 Options)

#### 1. If Conditional

**Purpose**: Conditionally includes attribute when lambda returns true

**Only accepts Proc/Lambda** (no simple/advanced mode)

**Syntax**:
```ruby
# Include when condition is true
integer :rating, if: ->(post:) { post[:status] == "published" }
array :tags, if: ->(post:) { post[:status] != "draft" } do
  string :_self
end

# Keyword splat (accepts any structure)
integer :views, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }

# Multiple named arguments
string :admin_note, if: ->(user:, post:) { user[:role] == "admin" && post[:flagged] }
```

**How it works**:
- If condition evaluates to `true` → attribute is processed normally (validated and transformed)
- If condition evaluates to `false` → attribute is completely excluded from output
- Lambda receives raw data as named arguments
- All exceptions in lambda are caught and wrapped in `Treaty::Exceptions::Validation`

**Execution Order**:
Evaluated BEFORE validators and modifiers run:
1. `if` - Check condition (skip attribute if condition fails)
2. Validators - Validate value
3. Modifiers - Transform value

**Use Cases**:

**Status-based visibility**:
```ruby
response 200 do
  object :post do
    string :id
    string :title
    datetime :published_at, :optional
    # Rating only visible for published posts
    integer :rating, if: ->(post:) { post[:published_at].present? }
    # Draft notes only for unpublished posts
    string :draft_notes, if: ->(post:) { post[:status] == "draft" }
  end
end
```

**Analytics when data exists**:
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

#### 2. Unless Conditional

**Purpose**: Conditionally excludes attribute when lambda returns true (opposite of `if`)

**Only accepts Proc/Lambda** (no simple/advanced mode)

**Syntax**:
```ruby
# Exclude when condition is true
string :password, :optional, unless: ->(post:) { post[:visibility] == "public" }
array :tags, unless: ->(post:) { post[:visibility] == "private" } do
  string :_self
end

# Complex condition
string :meta_description, :optional, unless: lambda { |post:|
  %w[private internal].include?(post[:visibility])
}
```

**How it works**:
- If condition evaluates to `false` → attribute is processed normally (validated and transformed)
- If condition evaluates to `true` → attribute is completely excluded from output
- Lambda receives raw data as named arguments
- All exceptions in lambda are caught and wrapped

**Use Cases**:

**Visibility control**:
```ruby
response 200 do
  object :post do
    string :id
    string :title
    string :visibility
    # password visible unless public
    string :password, unless: ->(post:) { post[:visibility] == "public" }
    # Tags excluded for private posts
    array :tags, unless: ->(post:) { post[:visibility] == "private" } do
      string :_self
    end
  end
end
```

**Mutual Exclusivity**:
Cannot use both `if` and `unless` on the same attribute - raises `Treaty::Exceptions::Validation`

### Modifier Order (CRITICAL!)

When combining modifiers, they execute **in the order they are written**.

**Processing Sequence**:
0. **Conditional Evaluation Phase**: `if` / `unless` (determines if attribute should exist)
1. **Validation Phase**: `required:`, `type:`, `inclusion:`, `format:` (order doesn't matter)
2. **Transformation Phase**: `default:`, `transform:`, `cast:`, `as:` (order matters!)

**Recommended Order**:
1. `transform:` - Clean/prepare the value
2. `cast:` - Convert types
3. `default:` - Apply default if value is still nil
4. `as:` - Rename the attribute

**Example**:
```ruby
string :published_at,
       transform: ->(value:) { value.strip },  # 1. Clean whitespace
       cast: :datetime,                        # 2. Convert to DateTime
       default: Time.current,                  # 3. Use default if still nil
       as: :published_date                     # 4. Rename for service
```

**Why This Order?**
- Transform and cast skip `nil` values automatically
- Default values are usually already in the correct format
- Renaming should happen last after all transformations

**Common Conflicts**:

**❌ Cast Before Transform** (wrong type):
```ruby
# Wrong: Cast creates DateTime, then transform tries .strip on DateTime (error)
string :timestamp,
       cast: :datetime,
       transform: ->(value:) { value.strip }  # ERROR: DateTime doesn't have .strip
```

**✅ Transform Before Cast** (correct):
```ruby
# Correct: Transform cleans string, then cast converts it
string :timestamp,
       transform: ->(value:) { value.strip },
       cast: :datetime
```

**❌ Wrong Default Type**:
```ruby
# Wrong: Default is string but we expect DateTime after cast
string :published_at,
       cast: :datetime,
       default: "2024-01-15"  # String, but we expect DateTime!
```

**✅ Correct Default Type**:
```ruby
# Correct: Default matches target type
string :published_at,
       transform: ->(value:) { value.strip },
       cast: :datetime,
       default: Time.current  # DateTime object, not string!
```

## Development Workflow

### Prerequisites

```bash
# Ruby 3.2+
ruby -v  # Should show 3.2 or higher

# Install dependencies
bundle install
```

### Common Commands

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/treaties/gate/api/posts/create_treaty_spec.rb

# Run linting
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Run both tests and linting (default rake task)
rake

# Test specific Rails version
BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bundle exec rspec

# Test all Rails versions via Appraisal
bundle exec appraisal install
bundle exec appraisal rspec
```

### Git Workflow

1. **Branch Naming**: Use descriptive names (e.g., `fix-validation-bug`, `add-logging-support`)
2. **Commits**: Clear, concise messages describing what changed and why
3. **Pull Requests**: Describe changes, reference issues, explain approach
4. **Code Review**: All PRs require review before merging

### Development Setup

The repository includes a full Rails integration test app at `/home/user/treaty/spec/sandbox/` that demonstrates real-world usage with:
- 9 treaty definitions showing all features
- 10 DTO definitions (serialization and deserialization)
- 16 service implementations
- Full controller integration

## Coding Conventions

### Ruby Style

- **Frozen String Literals**: All files start with `# frozen_string_literal: true`
- **RuboCop**: Code style enforced by servactory-rubocop gem
  - Inherits from `servactory-rubocop: rubocop-gem.yml`
  - Plugins: `rubocop-rspec_rails`
  - Style/Documentation: Disabled
  - Naming/VariableNumber: normalcase
- **Ruby Version**: Minimum 3.2, currently 3.4.7 in development

### File Organization

1. **Lib Structure**: Mirror the module structure
   ```
   lib/treaty/attribute/dsl.rb → Treaty::Attribute::DSL
   ```

2. **Spec Structure**: Mirror lib structure
   ```
   spec/treaty/attribute/dsl_spec.rb → tests for Treaty::Attribute::DSL
   ```

3. **Namespacing**: Use modules for organization
   ```ruby
   module Treaty
     module Attribute
       class DSL
         # ...
       end
     end
   end
   ```

### Naming Conventions

- **Classes**: PascalCase (e.g., `CreateTreaty`)
- **Modules**: PascalCase (e.g., `Treaty::Attribute`)
- **Methods**: snake_case (e.g., `collection_of_attributes`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `VERSION::STRING`)
- **Files**: snake_case (e.g., `create_treaty.rb`)

### Method Conventions

- Use `!` suffix for methods that raise exceptions (e.g., `call!`)
- Use `?` suffix for predicate methods (e.g., `valid?`)
- Private methods should be marked with `private` keyword

### Module Structure

```ruby
# frozen_string_literal: true

module Treaty
  module MyModule
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Class-level DSL methods
      end
    end
  end
end
```

## Testing Guidelines

### Test Framework

- **RSpec** 3.13+
- **RSpec Rails** 7.0+
- Configuration: `/home/user/treaty/spec/spec_helper.rb`
- Status persistence: `.rspec_status`

### Test Organization

1. **Unit Tests**: `spec/treaty/` - Test individual classes
2. **Contract Tests**: `spec/treaties/` - Test treaty definitions
3. **DTO Tests**: `spec/dtos/` - Test entity/DTO classes
4. **Controller Tests**: `spec/controllers/` - Test controller integration
5. **Integration Tests**: `spec/sandbox/` - Full Rails app integration

### Test Structure

```ruby
# frozen_string_literal: true

RSpec.describe Gate::API::Posts::CreateTreaty do
  # Note: Treaty API signature includes context and inventory
  subject(:perform) { described_class.call!(context:, inventory:, version:, params:) }

  let(:context) { instance_double(ApplicationController) }
  let(:inventory) { Treaty::Executor::Inventory.new(collection, context) }
  let(:collection) { Treaty::Inventory::Collection.new }

  context "when required data for work is valid" do
    context "when version is 1" do
      let(:version) { "1" }
      let(:params) { { post: { title: "Title" } } }

      it { expect { perform }.not_to raise_error }
    end
  end

  context "when required data for work is invalid" do
    let(:version) { "1" }
    let(:params) { {} }

    it :aggregate_failures do
      expect { perform }.to(
        raise_error do |exception|
          expect(exception).to be_a(Treaty::Exceptions::Validation)
          expect(exception.message).to eq("Error message")
        end
      )
    end
  end
end
```

### Custom Matchers and Helpers

Located in `spec/support/`:
- `matchers/have_json_body.rb` - JSON response matcher
- `matchers/not_change.rb` - No-change matcher
- `request_helper.rb` - Helper for API version headers
- `shared_examples/check_class_info.rb` - Shared examples for treaty structure

### Test Helpers

```ruby
# In controller specs
include RequestHelper

assign_json_headers_with(version: 1)
```

### Testing Best Practices

1. **Use `let` blocks** for test data setup
2. **Use `subject`** for the method under test
3. **Use contexts** to organize different scenarios
4. **Test both success and failure paths**
5. **Use `aggregate_failures`** for multiple expectations
6. **Test edge cases** (empty data, invalid types, missing attributes)
7. **Use shared examples** for common behavior testing
8. **Keep tests focused** - one concept per test

## Adding New Features

### Adding a New Treaty

1. Create treaty file in `app/treaties/`
   ```ruby
   # app/treaties/posts/create_treaty.rb
   module Posts
     class CreateTreaty < ApplicationTreaty
       version 1, default: true do
         request do
           object :post do
             string :title
             string :content
           end
         end

         response 201 do
           object :post do
             string :id
             string :title
             string :content
             datetime :created_at
           end
         end

         delegate_to Posts::CreateService
       end
     end
   end
   ```

2. Create corresponding spec in `spec/treaties/`
3. Use in controller:
   ```ruby
   class PostsController < ApplicationController
     treaty :create
   end
   ```

### Adding a New Entity/DTO

1. Create entity class:
   ```ruby
   # app/dtos/post_dto.rb
   class PostDto < Treaty::Entity
     object :post do
       string :id
       string :title
       string :content, :optional
       datetime :created_at
     end
   end
   ```

2. Use in treaty:
   ```ruby
   version 1 do
     request PostDto
     response 201, PostDto
   end
   ```

### Adding New Attribute Types

1. Create attribute class in `lib/treaty/attribute/types/`
2. Register type in attribute system
3. Add validation logic
4. Add tests in `spec/treaty/attribute/types/`
5. Document in `docs/attributes.md`

### Adding New Validators

1. Create validator in `lib/treaty/attribute/option/validators/`
2. Inherit from `Treaty::Attribute::Option::Base`
3. Implement `call!` method
4. Register in `Option::RegistryInitializer`
5. Add tests
6. Update documentation

## Common Patterns

### Version Management

```ruby
# Simple version
version 1 do
  # ...
end

# Semantic version
version "2.1.0" do
  # ...
end

# With deprecation
version 1 do
  deprecated do
    Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
      Gem::Version.new("2.0.0")
  end
end

# With summary
version 2 do
  summary "Added new fields for enhanced functionality"
end

# Default version
version 3, default: true do
  # ...
end
```

### Attribute Patterns

```ruby
# Basic types
string :name
integer :age
boolean :active
date :published_on
time :created_at
datetime :scheduled_at

# Optional attributes
string :bio, :optional

# Required with explicit marker
string :email, :required

# With default value
string :role, default: "user"
integer :page, default: 1

# With inclusion validation
string :status, in: %w[active inactive pending]
integer :rating, in: [1, 2, 3, 4, 5]

# With format validation
string :email, format: :email
string :uuid, format: :uuid
string :password, format: :password

# With custom validation message
string :username,
       required: { is: true, message: "Username is required" }

# With custom transformation
string :title, transform: ->(value:) { value.strip.titleize }
string :email, transform: ->(value:) { value.downcase.strip }
integer :amount_cents, transform: ->(value:) { value * 100 }

# With type casting - Request (client → service)
string :published_at, cast: :datetime    # String → DateTime
string :featured, cast: :boolean         # String → Boolean
integer :timestamp, cast: :datetime      # Unix timestamp → DateTime
string :published_on, cast: :date        # String → Date

# With type casting - Response (service → client)
datetime :created_at, cast: :string      # DateTime → ISO8601 string
datetime :published_at, cast: :integer   # DateTime → Unix timestamp
boolean :active, cast: :integer          # Boolean → Integer (1/0)
date :published_on, cast: :string        # Date → ISO8601 string

# With attribute renaming
string :first_name, as: :firstName
string :handle, as: :value

# Combining multiple modifiers (recommended order)
string :published_at,
       transform: ->(value:) { value.strip },
       cast: :datetime,
       default: Time.current,
       as: :publishedAt

# Advanced casting with custom error message
string :published_at, cast: {
  to: :datetime,
  message: "Invalid date format provided"
}

# Conditional attributes with 'if'
integer :stock_count, if: ->(product:) { product[:status] == "active" }
datetime :published_at, :optional, cast: :string, if: ->(post:) { post[:status] == "published" }
array :tags, :optional, if: ->(post:) { post[:status] != "draft" } do
  string :_self
end

# Conditional attributes with 'unless'
string :password, :optional, unless: ->(post:) { post[:visibility] == "public" }
array :tags, :optional, unless: ->(post:) { post[:visibility] == "private" } do
  string :_self
end
string :meta_description, :optional, unless: lambda { |post:|
  %w[private internal].include?(post[:visibility])
}

# Nested objects
object :author do
  string :name
  string :email
  object :address do
    string :city
    string :country
  end
end

# Arrays
array :tags do
  string :_self  # _self represents array elements
end

# Arrays of objects
array :comments do
  string :id
  string :text
  datetime :created_at
end
```

### Entity Patterns

```ruby
# Basic entity
class UserDto < Treaty::Entity
  object :user do
    string :id
    string :email, format: :email
    string :name
    datetime :created_at
  end
end

# Nested entities
class PostDto < Treaty::Entity
  object :post do
    string :id
    string :title
    object :author do
      string :name
      string :email
    end
    array :tags do
      string :_self
    end
  end
end

# Remember: Entity attributes are required by default!
class FlexibleDto < Treaty::Entity
  object :data do
    string :id              # required
    string :name            # required
    string :bio, :optional  # optional
  end
end

# Entity with casting
class PostResponseDto < Treaty::Entity
  object :post do
    string :id
    string :title
    datetime :published_at, cast: :string  # Cast to ISO8601
    time :created_at, cast: :integer       # Cast to Unix timestamp
  end
end
```

### Delegation Patterns

```ruby
# Class constant
delegate_to Posts::CreateService

# String (will be constantized)
delegate_to "Posts::CreateService"

# Path-style string (converts to constant)
delegate_to "posts/stable/create_service"  # → Posts::Stable::CreateService

# Lambda/Proc
delegate_to ->(params:) { params }
delegate_to lambda { |params:, inventory:|
  # Process locally
  { post: params[:post] }
}

# With custom method
delegate_to Posts::CreateService => :call!

# With return value transformation
delegate_to Posts::CreateService => :call, return: lambda(&:data)
```

### Inventory Patterns

```ruby
# Controller DSL
class PostsController < ApplicationController
  treaty :index do
    # Shorthand - uses method with same name
    provide :current_user

    # Method source
    provide :posts, from: :load_posts

    # Lambda source
    provide :meta, from: -> { { timestamp: Time.current } }

    # Direct value
    provide :api_version, from: 3
  end

  private

  def load_posts
    Post.where(user: current_user).published
  end
end

# Service receives inventory
class Posts::IndexService
  def self.call(inventory:, params:)
    # Access inventory items (lazy evaluation)
    current_user = inventory.current_user
    posts = inventory.posts
    meta = inventory.meta

    # Or convert to hash (evaluates all items)
    data = inventory.to_h
  end
end
```

## Advanced Features

### 1. Multiple Request/Response Blocks

You can define multiple request or response blocks - they get merged:

```ruby
version 3 do
  # Query parameters
  request do
    object :_self do
      string :signature
    end
  end

  # Body parameters
  request do
    object :post do
      string :title
      string :content
    end
  end

  # Combined: { signature: "...", post: { title: "...", content: "..." } }
end
```

### 2. Special `:_self` Object

When `object :_self` is used, attributes merge to root level:

```ruby
request do
  object :_self do
    string :signature
    integer :page
  end
end

# Expects: { signature: "...", page: 1 }
# NOT: { _self: { signature: "...", page: 1 } }
```

### 3. Nested Transformer System

Treaty uses separate transformers for nested structures:
- `NestedTransformer` handles object/array transformation
- `NestedObjectValidator` validates nested objects
- `NestedArrayValidator` validates nested arrays
- Recursive validation for deeply nested structures

### 4. Service Integration Patterns

**Regular Class**:
```ruby
class Posts::CreateService
  def self.call(params:, inventory: nil)
    # Service logic
    { post: { id: "123", title: "Hello" } }
  end
end
```

**Servactory Service** (special support):
```ruby
class Posts::CreateService < ApplicationService::Base
  input :inventory, type: Treaty::Executor::Inventory, required: false
  input :params, type: Hash

  output :data, type: Hash

  private

  def call
    outputs.data = { post: { id: "123", title: "Hello" } }
  end
end
```

**Servactory Error Handling**:
Treaty automatically catches and converts Servactory exceptions:
- `Servactory::Exceptions::Input` → `Treaty::Exceptions::Execution`
- `Servactory::Exceptions::Internal` → `Treaty::Exceptions::Execution`
- `Servactory::Exceptions::Output` → `Treaty::Exceptions::Execution`
- `Servactory::Exceptions::Failure` → `Treaty::Exceptions::Execution`

### 5. Lambda Message Support

All validators support lambda-based custom messages:

```ruby
string :password, format: {
  is: :password,
  message: ->(attribute:, value:, format_name:) {
    "#{attribute} must meet complexity requirements"
  }
}

string :category, inclusion: {
  in: %w[tech business lifestyle],
  message: ->(attribute:, value:, allowed_values:) {
    "Invalid #{attribute}: '#{value}'. Must be one of: #{allowed_values.join(', ')}"
  }
}
```

**Exception Handling**: If lambda raises exception, caught and wrapped with attribute name

### 6. Complete Request Lifecycle

```
1. HTTP Request → Controller
2. Treaty.call! invoked with version, params, inventory
3. Version Resolution (Versions::Resolver)
   - Find version factory
   - Check deprecation status
4. Inventory Preparation (if provided)
   - Lazy evaluation setup
5. Request Validation (Request::Validator)
   - Phase 1: Conditional evaluation (if/unless)
   - Phase 2: Value validation (required, type, inclusion, format)
6. Request Transformation (Request::Transformer)
   - Phase 3: Apply defaults
   - Phase 3: Apply transformations (transform, cast, as)
   - Key conversion (string → symbol)
7. Service Delegation (Versions::Executor)
   - Call service with params and inventory
8. Response Validation (Response::Validator)
   - Phase 1: Conditional evaluation (if/unless)
   - Phase 2: Value validation
9. Response Transformation (Response::Transformer)
   - Phase 3: Apply defaults
   - Phase 3: Apply transformations (transform, cast, as)
   - Key conversion (symbol → string)
10. Return Treaty::Result
    - data: transformed response
    - status: HTTP status code
    - version: API version used
11. HTTP Response → Client
```

### 7. Version Resolution Strategy

```ruby
# Priority order:
1. Explicitly requested version (via header/param)
   - Exact match required or raises VersionNotFound
2. Default version (marked with default: true)
   - First default version found
3. If no match → raises SpecifiedVersionNotFound

# Deprecation check:
- If version found and deprecated condition is true
  → raises Deprecated exception
```

### 8. Zeitwerk Auto-Loading

Custom Zeitwerk loader with inflections:
- "dsl" → "DSL"
- "version" → "VERSION"
- Tag: "treaty"

## Documentation

### Primary Documentation

All documentation is in `/home/user/treaty/docs/`:

- `getting-started.md` - Installation and basic setup
- `core-concepts.md` - Fundamental concepts
- `defining-contracts.md` - How to define treaties
- `attributes.md` - Attribute types and options (comprehensive)
- `objects.md` - Object grouping and the `:_self` object
- `nested-structures.md` - Nested objects and arrays guide
- `validation.md` - Validation system (all 4 validators)
- `transformation.md` - Data transformation (modifiers, casting, order)
- `entities.md` - Entity/DTO classes
- `versioning.md` - Version management
- `inventory.md` - Inventory system for controller data
- `examples.md` - Real-world examples
- `internationalization.md` - I18n support
- `api-reference.md` - Complete API documentation
- `cheatsheet.md` - Quick reference
- `migration-guide.md` - Version migration guide
- `troubleshooting.md` - Common issues and solutions
- `README.md` - Documentation index

### Code Documentation

- Inline comments for complex logic
- YARD-style documentation for public APIs
- Examples in module/class comments

### When Adding Features

1. Update relevant documentation in `docs/`
2. Add examples to `docs/examples.md`
3. Update `docs/api-reference.md` if adding new API
4. Update `docs/cheatsheet.md` for quick reference items
5. Consider adding troubleshooting entries

## CI/CD

### GitHub Actions Workflows

Located in `.github/workflows/`:

#### 1. Test Workflow (`test.yml`)

- **Triggers**: Push to main, PRs to main, manual dispatch
- **Matrix Testing**:
  - Ruby versions: 3.2, 3.3, 3.4, 3.5.0-preview1
  - Rails versions: 7.1, 7.2, 8.0, 8.1
  - Total: 16 test combinations
- **Steps**:
  1. Checkout code
  2. Setup Ruby with bundler caching
  3. Run RSpec tests

#### 2. RuboCop Workflow (`rubocop.yml`)

- **Triggers**: Push to main, PRs to main
- **Purpose**: Code quality and security scanning
- **Steps**:
  1. Checkout code
  2. Setup Ruby 3.4
  3. Install code-scanning-rubocop
  4. Run RuboCop with SARIF output
  5. Upload to GitHub Code Scanning
- **Permissions**: security-events: write

#### 3. Code Review Workflow (`code-review.yml`)

- **Purpose**: Claude AI code review
- **Access**: Maintainers only

### Pre-commit Checks

Before committing, ensure:
```bash
# Tests pass
bundle exec rspec

# RuboCop passes
bundle exec rubocop

# Or run both
rake
```

### Versioning Strategy

- **Current**: 0.14.0 (0.x series)
- **Breaking Changes**: Allowed between minor versions (0.x)
- **Stability**: Will stabilize with 1.0 release
- **Recommendation**: Pin to specific patch versions (e.g., `gem "treaty", "~> 0.14.0"`)

## Internal Architecture Deep Dive

### Option Processing Pipeline

**Registry System**:
```
Option::Registry (Central registry)
  ↓
Option::RegistryInitializer (Auto-registers on load)
  ↓
12 Registered Options:
  - Validators: RequiredValidator, TypeValidator, InclusionValidator, FormatValidator
  - Modifiers: DefaultModifier, TransformModifier, CastModifier, AsModifier
  - Conditionals: IfConditional, UnlessConditional
  - Helpers: :required, :optional
```

**Processing Flow**:
```
1. DSL Definition
   ↓
2. HelperMapper (Convert :required/:optional to options)
   ↓
3. OptionNormalizer (Convert simple mode to advanced mode)
   ↓
4. OptionOrchestrator (Coordinate processing)
   ↓
5. Phase 1: Build validators (cached)
6. Phase 2: Build conditionals (cached)
7. Phase 3: Evaluate conditionals
8. Phase 4: Validate attributes
9. Phase 5: Transform attributes
10. Phase 6: Assemble result
```

### Entity System Architecture

**Unified Entity Base**:
```
Treaty::Attribute::DSL
  ↓
├── Treaty::Entity (required: true by default)
│   ↓
│   └── User-defined DTOs
├── Treaty::Request::Entity (required: true by default)
│   ↓
│   └── Anonymous entities from request blocks
└── Treaty::Response::Entity (required: false by default)
    ↓
    └── Anonymous entities from response blocks
```

**All three share**:
- Same DSL methods
- Same attribute system
- Same validation logic
- Same transformation pipeline

### Factory Pattern Usage

**Request Factory**:
- Accepts blocks → creates anonymous RequestEntity
- Accepts Entity classes → uses directly
- Provides `collection_of_attributes` for validators

**Response Factory**:
- Accepts blocks → creates anonymous ResponseEntity
- Accepts Entity classes → uses directly
- Stores HTTP status code
- Provides `collection_of_attributes` for validators

**Version Factory**:
- Stores version number (integer or semantic)
- Stores summary and deprecation condition
- Stores request/response factories
- Stores executor (delegated service)

**Inventory Factory**:
- Builds inventory items via `provide` method
- Supports symbol (method), lambda, or direct value sources
- Creates Inventory::Collection

## Important Notes for AI Assistants

### When Working with Code

1. **Always run tests** after making changes
2. **Follow existing patterns** - look at similar implementations in `spec/sandbox/app/`
3. **Maintain consistency** with existing code style
4. **Update documentation** when adding features
5. **Add tests** for all new functionality
6. **Use RuboCop** to check code style
7. **Frozen string literals** - add to all new files
8. **Namespace correctly** - follow module structure

### When Writing Treaties

1. **Default attribute behavior differs**:
   - In request blocks: attributes are **optional by default**
   - In response blocks: attributes are **optional by default**
   - In Entity classes: attributes are **required by default**

2. **Version numbers** can be:
   - Integer: `1`, `2`, `3`
   - Semantic string: `"1.0"`, `"1.0.0"`, `"2.1.0"`
   - Release candidate: `"1.0.0.rc1"`

3. **Test all versions** of your treaty

4. **Document version changes** in summary:
   ```ruby
   version 2 do
     summary "Added author support to posts"
   end
   ```

5. **Modifier order matters**:
   - **Recommended order**: `transform:` → `cast:` → `default:` → `as:`
   - **Conditionals execute first**: `if:`/`unless:` → validators → modifiers
   - **Wrong order causes type errors**

6. **Choose between transform and cast**:
   - Use `cast:` for standard type conversions (26 predefined conversions)
   - Use `transform:` for custom business logic
   - Both work on non-nil values only

7. **Type casting limitations**:
   - Only scalar types: string, integer, boolean, date, time, datetime
   - Array and Object types do NOT support casting

8. **Conditional attributes**:
   - Use `if:` to include attributes only when condition is true
   - Use `unless:` to exclude attributes when condition is true
   - Conditionals receive parent object as named parameters
   - Cannot use both `if` and `unless` on same attribute
   - Work with all attribute types including objects and arrays

9. **Special `:_self` object**:
   - Attributes merge to root level (not nested)
   - Used for query parameters or array elements

10. **Format validation**:
    - Only works with string attributes
    - 8 supported formats: uuid, email, password, date, datetime, time, duration, boolean

### When Writing Tests

1. **Test both success and failure paths**
2. **Use shared examples** when available
3. **Test all API versions** defined in treaty
4. **Validate error messages** match expectations
5. **Use `aggregate_failures`** for multiple assertions
6. **Keep tests readable** - use descriptive contexts
7. **Include inventory and context** in treaty tests:
   ```ruby
   let(:context) { instance_double(ApplicationController) }
   let(:inventory) { Treaty::Executor::Inventory.new(collection, context) }
   let(:collection) { Treaty::Inventory::Collection.new }
   ```

### Common Pitfalls to Avoid

1. **Don't forget frozen string literal** comment
2. **Don't mix attribute defaults** - remember entity vs request/response differences
3. **Don't skip tests** - especially for edge cases
4. **Don't ignore RuboCop** warnings
5. **Don't use documentation disabled** classes without good reason
6. **Don't break backward compatibility** in 0.x without noting in PR
7. **Don't assume Rails version** - test across supported versions (7.1, 7.2, 8.0, 8.1)
8. **Don't use wrong modifier order** - transform before cast, default after cast
9. **Don't use `default: []` or `default: {}`** for arrays/objects
10. **Don't use format validation on non-string types**

### Useful Search Patterns

When searching the codebase:

```bash
# Find treaty definitions
find spec/sandbox/app/treaties -name "*.rb"

# Find entity definitions
find spec/sandbox/app/dtos -name "*.rb"

# Find attribute usage examples
grep -r "string :" spec/sandbox/app/

# Find version definitions
grep -r "version " spec/sandbox/app/treaties/

# Find delegation patterns
grep -r "delegate_to" spec/sandbox/app/treaties/

# Find conditional attributes
grep -r "if: ->" spec/sandbox/app/treaties/
grep -r "unless: ->" spec/sandbox/app/treaties/

# Find casting examples
grep -r "cast:" spec/sandbox/app/

# Find transformation examples
grep -r "transform:" spec/sandbox/app/
```

### Key Architecture Insights

1. **Three-Phase Processing**: Schema validation → Value validation → Value transformation
2. **Registry Pattern**: All options registered centrally for extensibility
3. **Lazy Evaluation**: Inventory and validators cached for performance
4. **Separation of Concerns**: Clear boundaries between validation, transformation, and orchestration
5. **DSL Flexibility**: Helper → Simple → Advanced mode normalization
6. **Type Safety**: Strict type checking with comprehensive validation
7. **Conditional Processing**: Attributes can be completely excluded based on runtime data
8. **Version Isolation**: Each version completely independent with own request/response schemas
9. **Rails Integration**: Seamless integration via Engine with zero configuration
10. **Error Transparency**: Custom messages with lambda support for context-aware errors

## Quick Reference

### File Locations

- **Source**: `/home/user/treaty/lib/treaty/`
- **Tests**: `/home/user/treaty/spec/`
- **Docs**: `/home/user/treaty/docs/`
- **Examples**: `/home/user/treaty/spec/sandbox/app/`
- **Config**: `/home/user/treaty/.rubocop.yml`, `.rspec`

### Common Tasks

| Task | Command |
|------|---------|
| Run tests | `bundle exec rspec` |
| Run linter | `bundle exec rubocop` |
| Fix style issues | `bundle exec rubocop -a` |
| Run all checks | `rake` |
| Test specific Rails | `BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bundle exec rspec` |
| Test all Rails | `bundle exec appraisal rspec` |

### Dependencies

- **Runtime**: i18n, rails, zeitwerk
- **Development**: appraisal, rake, rspec, rspec-rails, servactory, servactory-rubocop

### Summary Statistics

- **Codebase Size**: ~3,028 lines of Ruby code
- **Total Files**: 82 Ruby files
- **Test Files**: 77 spec files
- **Documentation Files**: 18 markdown files
- **Exception Classes**: 15 specific exceptions
- **Attribute Types**: 8 (string, integer, boolean, date, time, datetime, object, array)
- **Validators**: 4 (required, type, inclusion, format)
- **Modifiers**: 4 (default, transform, cast, as)
- **Conditionals**: 2 (if, unless)
- **Format Types**: 8 (uuid, email, password, date, datetime, time, duration, boolean)
- **Type Conversions**: 26 supported conversions
- **Supported Ruby Versions**: 4 (3.2, 3.3, 3.4, 3.5.0-preview1)
- **Supported Rails Versions**: 4 (7.1, 7.2, 8.0, 8.1)
- **CI Test Matrix**: 16 combinations (4 Ruby × 4 Rails)

---

**Last Updated**: 2025-11-30
**Treaty Version**: 0.14.0
**Repository**: https://github.com/servactory/treaty

**This document provides comprehensive guidance for working with Treaty. It covers all features, architecture, patterns, and best practices discovered through deep codebase analysis.**
