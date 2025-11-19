# CLAUDE.md - AI Assistant Guide for Treaty

This document provides comprehensive guidance for AI assistants working with the Treaty codebase. It covers the repository structure, development workflows, coding conventions, and best practices.

## Table of Contents

- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Core Architecture](#core-architecture)
- [Development Workflow](#development-workflow)
- [Coding Conventions](#coding-conventions)
- [Testing Guidelines](#testing-guidelines)
- [Adding New Features](#adding-new-features)
- [Common Patterns](#common-patterns)
- [Documentation](#documentation)
- [CI/CD](#cicd)

## Project Overview

**Treaty** is a Ruby gem (v0.11.0) for defining and managing REST API contracts with versioning support in Ruby on Rails applications.

### Key Information

- **Language**: Ruby 3.2+ (currently tested on 3.2, 3.3, 3.4, 3.5.0-preview1)
- **Framework**: Rails 7.1+ (tested on 7.1, 7.2, 8.0, 8.1)
- **Status**: Active development (0.x series) - breaking changes may occur between minor versions
- **License**: MIT
- **Author**: Anton Sokolov (Servactory ecosystem)
- **Repository**: https://github.com/servactory/treaty

### Core Features

1. **Type Safety** - Strict type checking for request/response data
2. **API Versioning** - Manage multiple concurrent API versions
3. **Unified Validation** - Same attribute system across requests, responses, and entities
4. **Entity Classes (DTOs)** - Reusable data transfer objects
5. **Built-in Validation** - Automatic validation of incoming/outgoing data
6. **Data Transformation** - Transform data between API versions
7. **Deprecation Management** - Mark versions as deprecated with conditions
8. **Internationalization** - Full I18n support

## Repository Structure

```
treaty/
├── .github/
│   └── workflows/          # CI/CD workflows (test, rubocop, code-review)
├── docs/                   # Comprehensive documentation (18+ files)
├── lib/                    # Main source code (70 files, 2,343 LOC)
│   └── treaty/
│       ├── attribute/      # Core attribute system (DSL, validation, transformation)
│       ├── controller/     # Rails controller integration
│       ├── entity/         # DTO/Entity classes
│       ├── request/        # Request handling
│       ├── response/       # Response handling
│       ├── versions/       # Version management
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
│   │       ├── services/
│   │       ├── treaties/   # Example treaty definitions
│   │       └── dtos/       # Example DTO definitions
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
| Version DSL | `/home/user/treaty/lib/treaty/versions/dsl.rb` |
| Controller DSL | `/home/user/treaty/lib/treaty/controller/dsl.rb` |
| Entity Base | `/home/user/treaty/lib/treaty/entity.rb` |
| Configuration | `/home/user/treaty/lib/treaty/configuration.rb` |
| Rails Engine | `/home/user/treaty/lib/treaty/engine.rb` |
| Test Helper | `/home/user/treaty/spec/spec_helper.rb` |
| RuboCop Config | `/home/user/treaty/.rubocop.yml` |
| Gem Spec | `/home/user/treaty/treaty.gemspec` |

## Core Architecture

### Design Patterns

1. **DSL-Driven Design**: Expressive, declarative APIs for defining contracts
2. **Modular Organization**: Clear separation between request/response/version/entity concerns
3. **Reusable Components**: Unified attribute system across all definitions
4. **Rails Integration**: Automatic ActionController inclusion via Rails Engine
5. **Method Missing Magic**: Type methods (string, integer, etc.) via `method_missing`

### The 7 Main Systems

#### 1. Attribute System (`lib/treaty/attribute/`)

**THE HEART OF TREATY** - Unified validation/transformation across request, response, and entities.

**DSL Methods**:
- `string`, `integer`, `boolean`, `datetime` - Type definitions
- `array` - Array with nested type definitions
- `object` - Object with nested attributes

**Modifiers**:
- `:optional` - Makes attribute optional (otherwise required by default in entities)
- `:required` - Explicitly marks as required (in request/response blocks)
- `default: value` - Default value if not provided
- `as: :new_name` - Transform key name
- `in: [...]` - Value must be in list (inclusion validation)
- `format: :email` - Format validation (email, uuid, datetime, etc.)

**Key Classes**:
- `Treaty::Attribute::DSL` - Provides attribute definition methods
- `Treaty::Attribute::Base` - Base attribute class
- `Treaty::Attribute::Collection` - Manages collection of attributes
- `Treaty::Attribute::OptionOrchestrator` - Orchestrates validation/transformation

#### 2. Versioning System (`lib/treaty/versions/`)

Manages multiple concurrent API versions.

**DSL**:
```ruby
version 1, default: true do
  summary "Description of this version"
  strategy Treaty::Strategy::ADAPTER
  deprecated { condition }
  request { ... }
  response(201) { ... }
  delegate_to ServiceClass
end
```

**Version Formats**: `1`, `1.0`, `1.0.0`, `1.0.0.rc1`

#### 3. Request Handling (`lib/treaty/request/`)

Parses and validates incoming request data.

#### 4. Response Handling (`lib/treaty/response/`)

Validates and formats outgoing response data.

#### 5. Controller Integration (`lib/treaty/controller/`)

Simple DSL for controllers:
```ruby
treaty :action_name
```

Automatically:
1. Validates incoming parameters
2. Calls delegated service
3. Validates service response
4. Returns transformed data

#### 6. Entity/DTOs (`lib/treaty/entity/`)

Reusable data transfer objects using same attribute system.

**Important**: Attributes in Entity classes are **required by default** (opposite of request/response blocks).

```ruby
class UserDto < Treaty::Entity
  object :user do
    string :id                    # required by default
    string :email, format: :email
    string :bio, :optional        # explicitly optional
  end
end
```

#### 7. Supporting Systems

- Configuration (`lib/treaty/configuration.rb`)
- Engine (`lib/treaty/engine.rb`) - Rails integration
- Context DSL (`lib/treaty/context/`)
- Info (`lib/treaty/info/`)
- Exceptions (`lib/treaty/exceptions/`)
- Strategy (`lib/treaty/strategy/`)

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

The repository includes a full Rails integration test app at `/home/user/treaty/spec/sandbox/` that demonstrates real-world usage.

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
  subject(:perform) { described_class.call!(version:, params:) }

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
         strategy Treaty::Strategy::ADAPTER

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
   ```ruby
   # spec/treaties/posts/create_treaty_spec.rb
   RSpec.describe Posts::CreateTreaty do
     # Test structure as shown above
   end
   ```

3. Use in controller
   ```ruby
   class PostsController < ApplicationController
     treaty :create
   end
   ```

### Adding a New Entity/DTO

1. Create entity class
   ```ruby
   # app/dtos/post_dto.rb
   class PostDto < Treaty::Entity
     object :post do
       string :id
       string :title
       string :content, :optional  # optional field
       datetime :created_at
     end
   end
   ```

2. Use in treaty
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

1. Create validator in `lib/treaty/attribute/validators/`
2. Integrate with `OptionOrchestrator`
3. Add tests
4. Update documentation

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
```

### Attribute Patterns

```ruby
# Basic types
string :name
integer :age
boolean :active
datetime :created_at

# Optional attributes
string :bio, :optional

# Required with explicit marker
string :email, :required

# With default value
string :role, default: { is: "user" }

# With inclusion validation
string :status, in: %w[active inactive pending]

# With format validation
string :email, format: :email
string :uuid, format: :uuid

# With custom validation message
string :username,
       required: { is: true, message: "Username is required" }

# With transformation (rename)
string :first_name, as: :firstName

# Nested objects
object :author do
  string :name
  string :email
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
  end
end

# Remember: Entity attributes are required by default!
# Use :optional explicitly if needed
class FlexibleDto < Treaty::Entity
  object :data do
    string :id              # required
    string :name            # required
    string :bio, :optional  # optional
  end
end
```

### Strategy Patterns

```ruby
# Direct strategy - passes params directly to service
strategy Treaty::Strategy::DIRECT

# Adapter strategy - transforms data
strategy Treaty::Strategy::ADAPTER
```

### Delegation Patterns

```ruby
# Class constant
delegate_to Posts::CreateService

# String (will be constantized)
delegate_to "Posts::CreateService"

# With custom method
delegate_to Posts::CreateService => :call!

# With return value transformation
delegate_to Posts::CreateService => :call, return: lambda(&:data)
```

## Documentation

### Primary Documentation

All documentation is in `/home/user/treaty/docs/`:

- `getting-started.md` - Installation and basic setup
- `core-concepts.md` - Fundamental concepts
- `defining-contracts.md` - How to define treaties
- `attributes.md` - Attribute types and options
- `validation.md` - Validation system
- `transformation.md` - Data transformation
- `entities.md` - Entity/DTO classes
- `versioning.md` - Version management
- `strategies.md` - Strategy patterns
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

- **Current**: 0.11.0 (0.x series)
- **Breaking Changes**: Allowed between minor versions (0.x)
- **Stability**: Will stabilize with 1.0 release
- **Recommendation**: Pin to specific patch versions (e.g., `gem "treaty", "~> 0.11.0"`)

## Important Notes for AI Assistants

### When Working with Code

1. **Always run tests** after making changes
2. **Follow existing patterns** - look at similar implementations
3. **Maintain consistency** with existing code style
4. **Update documentation** when adding features
5. **Add tests** for all new functionality
6. **Use RuboCop** to check code style
7. **Frozen string literals** - add to all new files
8. **Namespace correctly** - follow module structure

### When Writing Treaties

1. **Default attribute behavior differs**:
   - In request/response blocks: attributes are optional by default
   - In Entity classes: attributes are required by default
2. **Use appropriate strategy**:
   - `DIRECT` - minimal transformation
   - `ADAPTER` - data transformation between versions
3. **Version numbers** can be integer or semantic versioning string
4. **Test all versions** of your treaty
5. **Document version changes** in summary

### When Writing Tests

1. **Test both success and failure paths**
2. **Use shared examples** when available
3. **Test all API versions** defined in treaty
4. **Validate error messages** match expectations
5. **Use `aggregate_failures`** for multiple assertions
6. **Keep tests readable** - use descriptive contexts

### Common Pitfalls to Avoid

1. **Don't forget frozen string literal** comment
2. **Don't mix attribute defaults** - remember entity vs request/response differences
3. **Don't skip tests** - especially for edge cases
4. **Don't ignore RuboCop** warnings
5. **Don't use documentation disabled** classes without good reason
6. **Don't break backward compatibility** in 0.x without noting in PR
7. **Don't assume Rails version** - test across supported versions

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
```

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

---

**Last Updated**: 2025-11-19
**Treaty Version**: 0.11.0
**Repository**: https://github.com/servactory/treaty
