# Defining Contracts

[← Back to Documentation](./README.md)

## Contract Structure

A Treaty contract consists of:

1. **Class definition** - inheriting from `Treaty::Base`
2. **Version blocks** - one or more version definitions
3. **Request definition** - what data comes in
4. **Response definition(s)** - what data goes out
5. **Delegation** - where to process the request

## Basic Contract

```ruby
module Gate
  module API
    module Posts
      class CreateTreaty < ApplicationTreaty
        version 1 do
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
  end
end
```

## Version Definition

### Simple Version

```ruby
version 1 do
  # Version configuration
end
```

### Default Version

```ruby
version 2, default: true do
  # This version is used when no version specified
end
```

### Version with Metadata

```ruby
version 3 do
  summary "Added support for post categories and tags"

  deprecated lambda {
    Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
      Gem::Version.new("4.0.0")
  }

  strategy Treaty::Strategy::ADAPTER

  # ... rest of definition
end
```

## Request Definition

### Single Scope

```ruby
request do
  object :post do
    string :title
    string :content
  end
end
```

### Multiple Scopes

```ruby
request do
  object :post do
    string :title
    string :content
  end

  object :filters do
    string :category, :optional
    array :tags, :optional do
      string :_self
    end
  end
end
```

### Root Level Attributes (`:_self` object)

```ruby
request do
  # These attributes go to root level
  object :_self do
    string :signature
    string :timestamp
  end

  # These go under 'post' key
  object :post do
    string :title
  end
end

# Expects data like:
# {
#   signature: "abc123",
#   timestamp: "2024-01-01",
#   post: { title: "Hello" }
# }
```

### Empty Scope (Declaration Only)

```ruby
request do
  object :post
  object :filters
end

# Just declares that these objects exist
# Useful with DIRECT strategy
```

## Response Definition

### Single Status Code

```ruby
response 200 do
  object :posts do
    string :id
    string :title
  end
end
```

### Multiple Status Codes

```ruby
response 200 do
  object :posts do
    string :id
    string :title
  end

  object :meta do
    integer :count
    integer :page
  end
end

response 201 do
  object :post do
    string :id
    string :title
    datetime :created_at
  end
end

response 422 do
  object :errors do
    string :message
  end
end
```

## Strategy Selection

### When to use DIRECT

```ruby
strategy Treaty::Strategy::DIRECT
```

**Use DIRECT when:**
- Building a prototype or MVP
- The service already handles validation
- You don't need data transformation
- Performance is critical and you trust your data

**Example:**
```ruby
version 1 do
  strategy Treaty::Strategy::DIRECT

  request { object :post }
  response(201) { object :post }

  delegate_to Posts::V1::CreateService
end
```

### When to use ADAPTER

```ruby
strategy Treaty::Strategy::ADAPTER
```

**Use ADAPTER when:**
- You need strict validation
- You're managing multiple API versions
- You need data transformation between versions
- You want to ensure data consistency

**Example:**
```ruby
version 2 do
  strategy Treaty::Strategy::ADAPTER

  request do
    object :post do
      string :title
      string :content
      array :tags, :optional do
        string :_self
      end
    end
  end

  response 201 do
    object :post do
      string :id
      string :title
      string :content
      array :tags do
        string :_self
      end
      datetime :created_at
    end
  end

  delegate_to Posts::Stable::CreateService
end
```

## Delegation

### Service Class

```ruby
# Constant
delegate_to Posts::CreateService

# String (constant)
delegate_to "Posts::CreateService"

# String (path, will be constantized)
delegate_to "posts/create_service"
```

### Lambda Function

```ruby
delegate_to lambda { |params:|
  # Process request directly
  post = Post.create!(params[:post])
  { post: post.as_json }
}
```

### With Options

```ruby
# Specify method and return processing
delegate_to Posts::CreateService => :call, return: lambda(&:data)

# Service will be called as:
# service = Posts::CreateService.call(params: validated_params)
# result = return_lambda.call(service)
```

## Multiple Requests

You can define multiple request blocks that will be merged:

```ruby
request do
  # Query parameters
  object :_self do
    string :signature
  end
end

request do
  # Body parameters
  object :post do
    string :title
    string :content
  end
end
```

## Best Practices

### 1. One Contract Per Action

```ruby
# Good
class Posts::CreateTreaty < ApplicationTreaty
  # Handles posts#create
end

class Posts::UpdateTreaty < ApplicationTreaty
  # Handles posts#update
end

# Bad - don't handle multiple actions in one treaty
```

### 2. Meaningful Version Numbers

```ruby
# Good
version 1 do
  summary "Initial release"
end

version 2 do
  summary "Added author support"
end

version 3 do
  summary "Added categories and tags"
end

# Bad - no context about changes
version 1 do; end
version 2 do; end
```

### 3. Always Set a Default Version

```ruby
version 3, default: true do
  # This is the current production version
end
```

### 4. Use ADAPTER in Production

```ruby
# Good for production
version 1 do
  strategy Treaty::Strategy::ADAPTER
  # Full validation and transformation
end

# OK for development/prototyping
version 1 do
  strategy Treaty::Strategy::DIRECT
  # Quick iteration
end
```

### 5. Document Deprecation

```ruby
version 1 do
  summary "Initial release - DEPRECATED"

  deprecated lambda {
    # Will be removed in version 4.0.0
    Gem::Version.new(ENV["RELEASE_VERSION"]) >= Gem::Version.new("4.0.0")
  }

  # ... rest of definition
end
```

## Complete Example

Here's a complete example from the sandbox:

```ruby
module Gate
  module API
    module Posts
      class CreateTreaty < ApplicationTreaty
        version 3 do
          summary "Added author and socials to expand post data"

          strategy Treaty::Strategy::ADAPTER

          request do
            object :_self do
              string :signature
            end
          end

          request do
            object :post do
              string :title
              string :summary
              string :description, :optional
              string :content

              array :tags, :optional do
                string :_self
              end

              object :author do
                string :name
                string :bio

                array :socials, :optional do
                  string :provider, in: %w[twitter linkedin github]
                  string :handle, as: :value
                end
              end
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :summary
              string :description
              string :content

              array :tags do
                string :_self
              end

              object :author do
                string :name
                string :bio

                array :socials do
                  string :provider
                  string :value, as: :handle
                end
              end

              integer :rating
              integer :views

              datetime :created_at
              datetime :updated_at
            end
          end

          delegate_to "posts/stable/create_service"
        end
      end
    end
  end
end
```

## Next Steps

- [Attributes](./attributes.md) - learn about attribute types and options
- [Scopes](./scopes.md) - understand scope organization
- [Versioning](./versioning.md) - manage multiple versions

[← Back: Core Concepts](./core-concepts.md) | [← Back to Documentation](./README.md) | [Next: Attributes →](./attributes.md)
