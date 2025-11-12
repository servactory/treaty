# Examples

[← Back to Documentation](./README.md)

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
            object :posts do
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

## Next Steps

- [Validation](./validation.md) - understand how validation works
- [Versioning](./versioning.md) - manage multiple versions
- [API Reference](./api-reference.md) - complete API documentation

[← Back: Objects](./objects.md) | [← Back to Documentation](./README.md)
