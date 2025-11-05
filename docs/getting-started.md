# Getting Started

[← Back to Documentation](./README.md)

## Installation

Add to your Gemfile:

```ruby
gem 'treaty'
```

Run:

```bash
bundle install
```

## Rails Setup

Treaty automatically integrates with Rails through an Engine. After installing the gem, it's available in your application.

### Configuration

Create `config/initializers/treaty.rb`:

```ruby
Treaty::Engine.configure do |config|
  # Maximum nesting level for attributes (default: 3)
  config.treaty.attribute_nesting_level = 3
end
```

## Creating Your First Contract

### Step 1: Create Base Class

Create `app/treaties/application_treaty.rb`:

```ruby
class ApplicationTreaty < Treaty::Base
end
```

### Step 2: Define a Contract

Create `app/treaties/gate/api/posts/index_treaty.rb`:

```ruby
module Gate
  module API
    module Posts
      class IndexTreaty < ApplicationTreaty
        version 1, default: true do
          strategy Treaty::Strategy::ADAPTER

          request do
            scope :filters do
              string :title, :optional
              string :summary, :optional
            end
          end

          response 200 do
            scope :posts do
              string :id
              string :title
              string :summary
            end

            scope :meta do
              integer :count
              integer :page
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

### Step 3: Use in Controller

In `app/controllers/gate/api/posts_controller.rb`:

```ruby
module Gate
  module API
    class PostsController < ApplicationController
      treaty :index

      def index
        # Treaty automatically:
        # 1. Validates incoming parameters according to request definition
        # 2. Calls Posts::IndexService with validated data
        # 3. Validates service response according to response definition
        # 4. Returns transformed data
      end
    end
  end
end
```

## How It Works

1. **Request arrives** at controller with parameters
2. **Treaty determines version** based on headers or parameters
3. **Request validation** checks data structure and types
4. **Delegation** passes validated data to service
5. **Execution** service processes the request
6. **Response validation** checks service output
7. **Transformation** converts data to version format
8. **Return** controller returns result to client

## Directory Structure

```
app/
  treaties/
    application_treaty.rb
    gate/
      api/
        posts/
          index_treaty.rb
          create_treaty.rb
          show_treaty.rb
  controllers/
    gate/
      api/
        posts_controller.rb
```

## Treaty Naming Convention

- **File location**: `app/treaties/[namespace]/[controller]/[action]_treaty.rb`
- **Class name**: `[Namespace]::[Controller]::[Action]Treaty`
- **Example**: `Gate::API::Posts::CreateTreaty` for `gate/api/posts#create`

## Next Steps

- [Core Concepts](./core-concepts.md) - dive deeper into Treaty concepts
- [Defining Contracts](./defining-contracts.md) - detailed contract creation
- [Examples](./examples.md) - more practical examples

[← Back to Documentation](./README.md) | [Next: Core Concepts →](./core-concepts.md)
