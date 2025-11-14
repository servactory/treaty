# Examples

[← Back to Documentation](./README.md)

## Overview

This document provides complete, production-ready examples demonstrating real-world Treaty usage. Learn from practical examples including blog APIs, user profiles, social features, multi-version APIs, and format validation.

## Complete Real-World Examples

This document contains complete, production-ready examples based on actual Treaty usage.

## Example 1: Simple Blog Index

A basic index endpoint for listing blog posts with filtering.

### Treaty Definition

```ruby
module Gate
  module API
    module Posts
      class IndexTreaty < ApplicationTreaty
        version 1, default: true do
          strategy Treaty::Strategy::ADAPTER

          request do
            object :filters do
              string :title, :optional
              string :summary, :optional
              string :category, :optional
            end
          end

          response 200 do
            array :posts do
              string :id
              string :title
              string :summary
              datetime :created_at
            end

            object :meta do
              integer :count
              integer :page, default: 1
              integer :limit, default: 12
            end
          end

          delegate_to Posts::IndexService
        end
      end
    end
  end
end
```

### Controller

```ruby
module Gate
  module API
    class PostsController < ApplicationController
      treaty :index

      def index
        # Treaty handles everything automatically
      end
    end
  end
end
```

### Service

```ruby
module Posts
  class IndexService
    def self.call(params:)
      posts = Post.all
      posts = posts.where("title LIKE ?", "%#{params[:filters][:title]}%") if params[:filters][:title]

      {
        posts: posts.map { |p| { id: p.id, title: p.title, summary: p.summary, created_at: p.created_at } },
        meta: { count: posts.count, page: 1, limit: 12 }
      }
    end
  end
end
```

### Request Example

```bash
GET /api/posts?filters[title]=Ruby

# Treaty receives and validates:
{
  filters: {
    title: "Ruby"
  }
}

# Service receives:
{
  filters: {
    title: "Ruby"
  }
}

# Client receives:
{
  "posts": [
    {
      "id": "1",
      "title": "Ruby Best Practices",
      "summary": "Learn Ruby the right way",
      "created_at": "2024-01-01T12:00:00Z"
    }
  ],
  "meta": {
    "count": 1,
    "page": 1,
    "limit": 12
  }
}
```

## Example 2: Blog Post Creation

A complete create endpoint with nested structures and validation.

### Treaty Definition

```ruby
module Gate
  module API
    module Posts
      class CreateTreaty < ApplicationTreaty
        version 1 do
          summary "Basic post creation"
          strategy Treaty::Strategy::ADAPTER

          request do
            object :post do
              string :title
              string :content
              string :summary, :optional
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :content
              string :summary
              datetime :created_at
            end
          end

          delegate_to Posts::V1::CreateService
        end

        version 2 do
          summary "Added category support"
          strategy Treaty::Strategy::ADAPTER

          request do
            object :post do
              string :title
              string :content
              string :summary, :optional
              string :category, in: %w[tech business lifestyle]
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :content
              string :summary
              string :category
              datetime :created_at
            end
          end

          delegate_to Posts::Stable::CreateService
        end

        version 3, default: true do
          summary "Added author and tags"
          strategy Treaty::Strategy::ADAPTER

          request do
            object :post do
              string :title
              string :content
              string :summary, :optional
              string :category, in: %w[tech business lifestyle]
              boolean :published, :optional

              array :tags, :optional do
                string :_self
              end

              object :author do
                string :name
                string :email
                string :bio, :optional
              end
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :content
              string :summary
              string :category
              boolean :published

              array :tags do
                string :_self
              end

              object :author do
                string :name
                string :email
                string :bio
              end

              integer :views
              datetime :created_at
              datetime :updated_at
            end
          end

          delegate_to Posts::Stable::CreateService
        end
      end
    end
  end
end
```

### Request Example (Version 3)

```bash
POST /api/posts
Headers: API-Version: 3

{
  "post": {
    "title": "Getting Started with Treaty",
    "content": "Treaty is a powerful API contract library...",
    "summary": "Learn Treaty basics",
    "category": "tech",
    "published": true,
    "tags": ["ruby", "rails", "api"],
    "author": {
      "name": "John Doe",
      "email": "johndoe@example.com",
      "bio": "Software Engineer"
    }
  }
}

# Response:
{
  "post": {
    "id": "123",
    "title": "Getting Started with Treaty",
    "content": "Treaty is a powerful API contract library...",
    "summary": "Learn Treaty basics",
    "category": "tech",
    "published": true,
    "tags": ["ruby", "rails", "api"],
    "author": {
      "name": "John Doe",
      "email": "johndoe@example.com",
      "bio": "Software Engineer"
    },
    "views": 0,
    "created_at": "2024-01-01T12:00:00Z",
    "updated_at": "2024-01-01T12:00:00Z"
  }
}
```

## Example 3: Social Profile with Nested Arrays

Complex nested structures with social media profiles.

### Treaty Definition

```ruby
module Gate
  module API
    module Users
      class UpdateProfileTreaty < ApplicationTreaty
        version 1, default: true do
          strategy Treaty::Strategy::ADAPTER

          request do
            object :profile do
              string :name
              string :bio, :optional

              array :socials, :optional do
                string :provider, in: %w[twitter linkedin github]
                string :handle, as: :value
                string :url, :optional
              end

              object :settings, :optional do
                string :theme, default: "light", in: %w[light dark]
                string :language, default: "en"
                string :timezone, default: "UTC"
                boolean :email_notifications, default: true
                boolean :public_profile, default: false
              end
            end
          end

          response 200 do
            object :profile do
              string :id
              string :name
              string :bio

              array :socials do
                string :provider
                string :value, as: :handle
                string :url
              end

              object :settings do
                string :theme
                string :language
                string :timezone
                boolean :email_notifications
                boolean :public_profile
              end

              datetime :updated_at
            end
          end

          delegate_to Users::UpdateProfileService
        end
      end
    end
  end
end
```

### Request Example

```bash
PUT /api/users/profile

{
  "profile": {
    "name": "John Doe",
    "bio": "Software Engineer & Open Source Contributor",
    "socials": [
      {
        "provider": "twitter",
        "handle": "johndoe"
      },
      {
        "provider": "github",
        "handle": "johndoe",
        "url": "https://github.com/alice"
      }
    ],
    "settings": {
      "theme": "dark",
      "language": "en",
      "timezone": "America/New_York"
    }
  }
}

# Service receives (note 'handle' → 'value' transformation):
{
  profile: {
    name: "John Doe",
    bio: "Software Engineer & Open Source Contributor",
    socials: [
      {
        provider: "twitter",
        value: "johndoe"  # Transformed from 'handle'
      },
      {
        provider: "github",
        value: "johndoe",
        url: "https://github.com/alice"
      }
    ],
    settings: {
      theme: "dark",
      language: "en",
      timezone: "America/New_York"
    }
  }
}

# Service returns (note 'value' → 'handle' transformation):
{
  "profile": {
    "id": "user-123",
    "name": "John Doe",
    "bio": "Software Engineer & Open Source Contributor",
    "socials": [
      {
        "provider": "twitter",
        "handle": "johndoe",  # Transformed from 'value'
        "url": null
      },
      {
        "provider": "github",
        "handle": "johndoe",
        "url": "https://github.com/alice"
      }
    ],
    "settings": {
      "theme": "dark",
      "language": "en",
      "timezone": "America/New_York"
    },
    "updated_at": "2024-01-01T12:00:00Z"
  }
}
```

## Example 4: Using Lambda Delegation

Sometimes you don't need a service - you can process directly in a lambda.

```ruby
class SimpleCalculatorTreaty < ApplicationTreaty
  version 1, default: true do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :calculation do
        integer :a
        integer :b
        string :operation, in: %w[add subtract multiply divide]
      end
    end

    response 200 do
      object :result do
        integer :value
        string :operation
      end
    end

    delegate_to lambda { |params:|
      calc = params[:calculation]
      result = case calc[:operation]
      when "add" then calc[:a] + calc[:b]
      when "subtract" then calc[:a] - calc[:b]
      when "multiply" then calc[:a] * calc[:b]
      when "divide" then calc[:a] / calc[:b]
      end

      { result: { value: result, operation: calc[:operation] } }
    }
  end
end
```

## Example 5: Multi-Version API Evolution

How an API evolves through versions:

```ruby
class Posts::ShowTreaty < ApplicationTreaty
  # Version 1: Basic implementation
  version 1 do
    deprecated true  # Mark as deprecated

    strategy Treaty::Strategy::DIRECT

    request { object :post }
    response(200) { object :post }

    delegate_to Posts::V1::ShowService
  end

  # Version 2: Added validation
  version 2 do
    deprecated lambda { ENV["RELEASE_VERSION"] >= "3.0.0" }

    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :id
      end
    end

    response 200 do
      object :post do
        string :id
        string :title
        string :content
      end
    end

    delegate_to Posts::V2::ShowService
  end

  # Version 3: Added author info
  version 3, default: true do
    strategy Treaty::Strategy::ADAPTER

    request do
      object :post do
        string :id
      end
    end

    response 200 do
      object :post do
        string :id
        string :title
        string :content

        object :author do
          string :id
          string :name
          string :email
        end

        datetime :created_at
        datetime :updated_at
      end
    end

    delegate_to Posts::Stable::ShowService
  end
end
```

## Common Patterns

### Pattern 1: Pagination

```ruby
# In request for page/limit
object :_self do
  integer :page, default: 1
  integer :limit, default: 12
end

# In response for metadata
object :meta do
  integer :count
  integer :page
  integer :limit
  integer :total_pages
end
```

### Pattern 2: Filtering

```ruby
object :filters do
  string :status, :optional, in: %w[draft published archived]
  string :category, :optional
  datetime :created_after_at, :optional
  datetime :created_before_at, :optional
end
```

### Pattern 3: Sorting

```ruby
object :sort do
  string :by, default: "created_at", in: %w[created_at updated_at title]
  string :direction, default: "desc", in: %w[asc desc]
end
```

## Example 7: Using Entity Classes (DTOs)

Demonstrates using reusable Entity classes for better code organization.

### Entity Definitions

```ruby
# app/dtos/application_dto.rb
class ApplicationDto < Treaty::Entity
end

# app/dtos/deserialization/posts/create_dto.rb
module Deserialization
  module Posts
    class CreateDto < ApplicationDto
      object :post do
        string :title
        string :content
        string :summary, :optional
        boolean :published, :optional

        object :author do
          string :name
          string :email
        end

        array :tags, :optional do
          string :_self  # Array of strings
        end
      end
    end
  end
end

# app/dtos/serialization/posts/create_dto.rb
module Serialization
  module Posts
    class CreateDto < ApplicationDto
      object :post do
        string :id
        string :title
        string :content
        string :summary
        boolean :published
        datetime :created_at
        datetime :updated_at

        object :author do
          string :id
          string :name
          string :email
        end

        array :tags do
          string :_self
        end
      end
    end
  end
end
```

### Treaty Using Entities

```ruby
module Posts
  class CreateTreaty < ApplicationTreaty
    version 1 do
      strategy Treaty::Strategy::ADAPTER

      # Use Entity classes instead of inline blocks
      request Deserialization::Posts::CreateDto
      response 201, Serialization::Posts::CreateDto

      delegate_to Posts::CreateService
    end

    version 2 do
      strategy Treaty::Strategy::ADAPTER

      # Reuse the same Entity classes across versions
      request Deserialization::Posts::CreateDto
      response 201, Serialization::Posts::CreateDto

      delegate_to Posts::V2::CreateService
    end
  end
end
```

### Controller

```ruby
class PostsController < ApplicationController
  treaty :create

  def create
    # Treaty handles everything automatically
    # Request validated against Deserialization::Posts::CreateDto
    # Response validated against Serialization::Posts::CreateDto
  end
end
```

### Service

```ruby
module Posts
  class CreateService
    def self.call(params:)
      post = Post.create!(
        title: params[:post][:title],
        content: params[:post][:content],
        summary: params[:post][:summary],
        published: params[:post][:published] || false
      )

      author = Author.create!(
        name: params[:post][:author][:name],
        email: params[:post][:author][:email]
      )

      post.update!(author: author)
      post.tag_list = params[:post][:tags] if params[:post][:tags]
      post.save!

      {
        post: {
          id: post.id,
          title: post.title,
          content: post.content,
          summary: post.summary,
          published: post.published?,
          created_at: post.created_at,
          updated_at: post.updated_at,
          author: {
            id: author.id,
            name: author.name,
            email: author.email
          },
          tags: post.tag_list
        }
      }
    end
  end
end
```

### Request/Response Examples

**Request:**
```json
POST /posts
{
  "post": {
    "title": "Getting Started with Treaty",
    "content": "Treaty is a powerful library...",
    "summary": "An introduction to Treaty",
    "published": true,
    "author": {
      "name": "John Doe",
      "email": "john@example.com"
    },
    "tags": ["ruby", "api", "treaty"]
  }
}
```

**Response:**
```json
{
  "post": {
    "id": "123",
    "title": "Getting Started with Treaty",
    "content": "Treaty is a powerful library...",
    "summary": "An introduction to Treaty",
    "published": true,
    "created_at": "2024-11-12T10:30:00Z",
    "updated_at": "2024-11-12T10:30:00Z",
    "author": {
      "id": "456",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "tags": ["ruby", "api", "treaty"]
  }
}
```

### Benefits

1. **Reusability** - Same Entity classes used across multiple versions
2. **Maintainability** - Update structure in one place
3. **Organization** - Clear separation between request and response structures
4. **Type Safety** - Consistent validation across all usages
5. **Testability** - Test Entity classes independently

See [Entity Classes (DTOs)](./entities.md) for detailed documentation.

## Example 8: Format Validation for User Registration

Demonstrates format validation for email, password, dates, and other specific string formats.

### Treaty Definition

```ruby
module Gate
  module API
    module Users
      class RegisterTreaty < ApplicationTreaty
        version 1, default: true do
          strategy Treaty::Strategy::ADAPTER

          request do
            object :user do
              # Email format validation
              string :email, format: :email

              string :username

              # Password format with custom message
              string :password, format: {
                is: :password,
                message: "Password must be 8-16 characters with at least one digit, lowercase, and uppercase"
              }

              # Optional fields with format validation
              string :birth_date, :optional, format: :date
              string :phone, :optional
              string :website, :optional

              # UUID format for external ID
              string :external_id, :optional, format: :uuid

              # Boolean string format
              string :newsletter_consent, format: :boolean
            end
          end

          response 201 do
            object :user do
              string :id
              string :email, format: :email
              string :username
              string :birth_date, :optional, format: :date
              string :external_id, :optional, format: :uuid
              datetime :created_at
            end
          end

          delegate_to Users::RegisterService
        end
      end
    end
  end
end
```

### Valid Request Example

```bash
POST /api/users/register

{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "password": "SecurePass123",
    "birth_date": "1990-01-15",
    "external_id": "550e8400-e29b-41d4-a716-446655440000",
    "newsletter_consent": "true"
  }
}
```

### Invalid Requests - Format Validation Errors

```bash
# Invalid email format
{
  "user": {
    "email": "invalid-email",
    "username": "johndoe",
    "password": "SecurePass123",
    "newsletter_consent": "true"
  }
}
# Error: Attribute 'email' has invalid email format: 'invalid-email'

# Invalid password format (too weak)
{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "password": "weak",
    "newsletter_consent": "true"
  }
}
# Error: Password must be 8-16 characters with at least one digit, lowercase, and uppercase

# Invalid date format
{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "password": "SecurePass123",
    "birth_date": "not-a-date",
    "newsletter_consent": "true"
  }
}
# Error: Attribute 'birth_date' has invalid date format: 'not-a-date'

# Invalid UUID format
{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "password": "SecurePass123",
    "external_id": "not-a-uuid",
    "newsletter_consent": "true"
  }
}
# Error: Attribute 'external_id' has invalid uuid format: 'not-a-uuid'

# Invalid boolean format
{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "password": "SecurePass123",
    "newsletter_consent": "yes"
  }
}
# Error: Attribute 'newsletter_consent' has invalid boolean format: 'yes'
```

### Supported Format Types

- `:uuid` - UUID format (e.g., "550e8400-e29b-41d4-a716-446655440000")
- `:email` - RFC 2822 compliant email address
- `:password` - Password (8-16 chars, must contain digit, lowercase, and uppercase)
- `:date` - ISO 8601 date string (e.g., "2025-01-15")
- `:datetime` - ISO 8601 datetime string (e.g., "2025-01-15T10:30:00Z")
- `:time` - Time string (e.g., "10:30:00", "10:30 AM")
- `:duration` - ISO 8601 duration format (e.g., "PT2H", "P1D", "PT30M")
- `:boolean` - Boolean string ("true", "false", "0", "1")

See [Format Validation](./validation.md#format-validation) for complete documentation.

## Next Steps

- [Validation](./validation.md) - Understand how validation works
- [Versioning](./versioning.md) - Manage multiple versions
- [API Reference](./api-reference.md) - Complete API documentation

[← Back to Documentation](./README.md)
