# Inventory System

## Overview

The Inventory system allows you to provide additional data from your controllers to services through the treaty execution pipeline. This enables you to pass controller-specific data, such as current user information, session data, or dynamically computed values, to your services without including them in the request parameters.

## Basic Usage

### Defining Inventory in Controllers

Use the `provide` method within a block passed to the `treaty` method to define inventory items:

```ruby
class PostsController < ApplicationController
  treaty :index do
    provide :current_user, from: :current_user_method  # Explicit source
    provide :request_id, from: -> { request.uuid }     # Lambda source
    provide :static_value, from: "Welcome"             # Direct value
    provide :current_user                              # Shorthand: uses :current_user as source
  end
end
```

## Inventory Sources

The `from:` parameter is optional and accepts three types of sources. When omitted, the inventory name itself is used as the source.

### 1. Symbol - Controller Method

```ruby
treaty :index do
  provide :posts, from: :load_posts
end

private

def load_posts
  Post.where(user: current_user).limit(10)
end
```

When the treaty executes, it will call `load_posts` on the controller instance and pass the result to the service.

### 2. Proc/Lambda - Callable Object

```ruby
treaty :index do
  # Simple lambda
  provide :meta, from: -> { { count: 10 } }

  # Lambda with context (controller)
  provide :posts, from: -> { load_posts }

  # Lambda accessing request
  provide :request_id, from: -> { request.uuid }
end
```

Lambdas are evaluated in the controller's context, so you can access controller methods and instance variables.

### 3. Direct Value - Static Data

```ruby
treaty :index do
  provide :welcome_message, from: "Welcome to our API"
  provide :api_version, from: 3
  provide :feature_flags, from: { new_ui: true, beta: false }
end
```

Direct values are passed through unchanged.

### 4. Shorthand Syntax - Optional `from`

When the `from:` parameter is omitted, the inventory name is used as the source:

```ruby
treaty :index do
  # These are equivalent:
  provide :current_user, from: :current_user
  provide :current_user  # Shorthand

  # These are equivalent:
  provide :posts, from: :posts
  provide :posts  # Shorthand
end

private

def current_user
  @current_user ||= User.find(session[:user_id])
end

def posts
  Post.where(user: current_user).published
end
```

This shorthand is particularly useful when the inventory name matches the controller method name, making the code more concise and readable.

## Internal Architecture

### Lazy Evaluation

The inventory system uses **lazy evaluation** to optimize performance. Inventory items are not evaluated until they are actually accessed in your service.

**How it works:**

1. When a treaty executes, a `Treaty::Executor::Inventory` instance is created with:
   - The inventory collection (definitions from your `provide` calls)
   - The controller context (for method calls and proc evaluation)

2. Items are evaluated **only when accessed** via method calls:
   ```ruby
   # This triggers evaluation of the :posts inventory item
   posts = inventory.posts

   # This triggers evaluation of the :current_user inventory item
   user = inventory.current_user
   ```

3. Once evaluated, results are **cached** for the duration of the request:
   ```ruby
   posts1 = inventory.posts  # Evaluates and caches
   posts2 = inventory.posts  # Returns cached value, no re-evaluation
   ```

4. Calling `inventory.to_h` evaluates **all** inventory items at once and returns a hash.

**Benefits:**

- **Performance**: Only evaluates data that is actually used
- **Efficiency**: Expensive operations (database queries, API calls) are skipped if not needed
- **Caching**: Each item is evaluated once per request, preventing redundant work

**Example:**

```ruby
# Controller defines 3 inventory items
treaty :index do
  provide :current_user                    # Might call database
  provide :posts, from: :load_posts        # Might call database
  provide :meta, from: -> { build_meta }   # Computation
end

# Service only uses current_user
def call
  user = inputs.inventory.current_user  # Only this is evaluated
  # posts and meta are never evaluated - performance win!
end
```

## Accessing Inventory in Services

Inventory is passed to services as a `Treaty::Executor::Inventory` instance, which provides both **method-based** and **hash-based** access to inventory items.

### Method-Based Access (Recommended)

The inventory object supports method calls for accessing items:

```ruby
# In service
def call
  posts = inventory.posts          # Method call
  user = inventory.current_user    # Method call
  meta = inventory.meta            # Method call
end
```

If an inventory item is not found, `Treaty::Exceptions::Inventory` is raised with a helpful error message listing available items.

### Hash-Based Access (Alternative)

For backward compatibility or dynamic access, you can convert inventory to a hash:

```ruby
# In service
def call
  data = inventory.to_h            # Convert to hash
  posts = data[:posts]             # Hash access
  user = data[:current_user]       # Hash access
end
```

### Servactory Services

For Servactory services, declare an `inventory` input to receive the inventory data:

```ruby
class Posts::IndexService < ApplicationService::Base
  input :params, type: Hash
  input :inventory, required: false

  output :data, type: Hash

  private

  def call
    # Use method-based access
    posts = inputs.inventory&.posts || Post.all

    outputs.data = {
      posts: posts.map(&:to_h),
      meta: build_meta(posts)
    }
  end
end
```

The `inventory` input receives a `Treaty::Executor::Inventory` instance providing method-based access to evaluated inventory items.

### Proc Executors

For Proc executors, inventory is passed as a keyword argument:

```ruby
version 1 do
  delegate_to(lambda do |params:, inventory:|
    # Use method-based access
    posts = inventory.posts
    { posts: posts, meta: { count: posts.size } }
  end)
end
```

### Regular Class Services

For regular Ruby classes, inventory is passed as a keyword argument to the specified method:

```ruby
class Posts::IndexService
  def self.call(params:, inventory:)
    # Use method-based access
    posts = inventory.posts
    { posts: posts.map(&:to_h) }
  end
end
```

## Complete Example

### Controller

```ruby
class PostsController < ApplicationController
  treaty :index do
    provide :current_user              # Shorthand: calls current_user method
    provide :posts, from: :load_posts  # Explicit: calls load_posts method
    provide :meta, from: -> { build_meta }
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def load_posts
    Post.where(published: true).limit(10)
  end

  def build_meta
    { timestamp: Time.current, api_version: 3 }
  end
end
```

### Treaty

```ruby
module Posts
  class IndexTreaty < ApplicationTreaty
    version 3, default: true do
      request do
        object :filters, :optional do
          string :title, :optional
          string :tag, :optional
        end
      end

      response 200 do
        array :posts do
          string :id
          string :title
          string :content
        end

        object :meta do
          integer :count
          string :timestamp
        end
      end

      delegate_to Posts::IndexService
    end
  end
end
```

### Service

```ruby
module Posts
  class IndexService < ApplicationService::Base
    input :params, type: Hash
    input :inventory, required: false

    output :data, type: Hash

    private

    def call
      # Access pre-loaded data from inventory using method calls
      posts = inputs.inventory.posts
      current_user = inputs.inventory.current_user
      meta = inputs.inventory.meta

      # Apply filters from params if needed
      posts = apply_filters(posts, inputs.params[:filters]) if inputs.params[:filters]

      outputs.data = {
        posts: posts.map { |post| serialize_post(post) },
        meta: meta.merge(count: posts.size)
      }
    end

    def apply_filters(posts, filters)
      posts = posts.where(title: filters[:title]) if filters[:title]
      posts = posts.tagged_with(filters[:tag]) if filters[:tag]
      posts
    end

    def serialize_post(post)
      { id: post.id, title: post.title, content: post.content }
    end
  end
end
```

## Benefits

### 1. Lazy Evaluation

Inventory items are evaluated only when accessed, providing significant performance benefits:

- Expensive operations (database queries, API calls) are skipped if not needed
- Each item is evaluated once and cached for the request duration
- Services can define many inventory sources without performance penalty

### 2. Separation of Concerns

Keep controller-specific logic (like loading current user, checking permissions) in the controller, while keeping services focused on business logic.

### 3. Performance Optimization

Pre-load expensive data once in the controller and reuse it across multiple service calls or in different parts of your treaty processing.

### 4. Testing Simplification

Services can be tested independently by passing inventory directly:

```ruby
RSpec.describe Posts::IndexService do
  let(:posts) { create_list(:post, 5) }
  let(:user) { create(:user) }

  it "processes posts from inventory" do
    result = described_class.call!(
      params: {},
      inventory: { posts: posts, current_user: user }
    )

    expect(result.data[:posts].size).to eq(5)
  end
end
```

### 5. Flexibility

Mix and match different data sources without cluttering your request parameters.

## Best Practices

### 1. Use Descriptive Names

```ruby
# Good
provide :current_user              # Shorthand when name matches method
provide :current_user, from: :current_user  # Explicit, same result
provide :filtered_posts, from: :load_filtered_posts

# Avoid
provide :data, from: :get_data
provide :x, from: :y
```

### 2. Keep Sources Simple

```ruby
# Good - simple method call
provide :posts, from: :load_posts

# Good - simple lambda
provide :meta, from: -> { { count: 10 } }

# Avoid - complex logic in lambda
provide :data, from: -> do
  # 20 lines of complex logic here
  # This should be a method instead
end
```

### 3. Declare Inventory Input in Servactory Services

When using inventory in Servactory services, you must declare it as an input. The inventory is always passed to services when it exists, so services should be prepared to receive it:

```ruby
# Make inventory optional if service works both with and without it
input :inventory, required: false

# Or make it required if service always needs inventory
input :inventory
```

**Note**: The inventory is a `Treaty::Executor::Inventory` instance. Servactory's type checking is flexible and will accept it.

If a Servactory service receives inventory but hasn't declared the input, Servactory will raise `Servactory::Exceptions::Input` error.

### 4. Document Inventory Dependencies

```ruby
# Expects inventory to provide:
# - current_user (User) - The authenticated user via inventory.current_user
# - posts (Array<Post>) - Pre-loaded posts via inventory.posts
class Posts::IndexService < ApplicationService::Base
  input :params, type: Hash
  input :inventory, required: false

  private

  def call
    user = inputs.inventory.current_user
    posts = inputs.inventory.posts
    # ...
  end
end
```

## Forbidden Patterns

### 1. Direct Method Calls (Without Symbol/Proc)

```ruby
# FORBIDDEN - This will be evaluated at load time
treaty :index do
  provide :posts, from: load_posts  # Error!
end

# CORRECT - Use symbol or lambda
treaty :index do
  provide :posts, from: :load_posts  # OK
  provide :posts, from: -> { load_posts }  # OK
end
```

### 2. Passing Nil as Source

```ruby
# FORBIDDEN - Explicitly passing nil is not allowed
treaty :index do
  provide :posts, from: nil  # Error!
end

# ALLOWED - Omitting from parameter uses inventory name as source
treaty :index do
  provide :posts  # OK: equivalent to provide :posts, from: :posts
end
```

## Error Messages

### Unknown Method in Treaty Block

```
Unknown method 'unknown_method' in treaty block for action 'index'.
Only 'provide' method is supported. Use: provide :name, from: :source OR provide :name
```

### Invalid Inventory Name

```
Inventory name must be a Symbol, got "posts".
Use: provide :name, from: :source OR provide :name
```

### Source Cannot Be Nil

```
Inventory source cannot be nil.
Provide a Symbol (method name), Proc/Lambda, or direct value
```

## Advanced Usage

### Conditional Inventory

```ruby
treaty :index do
  if admin_user?
    provide :all_posts, from: -> { Post.all }
  else
    provide :published_posts, from: -> { Post.published }
  end
end
```

### Chaining Data

```ruby
treaty :index do
  provide :user, from: :current_user
  provide :user_posts, from: -> { current_user.posts }
  provide :post_count, from: -> { current_user.posts.count }
end
```

### Multiple Sources

```ruby
treaty :index do
  # Shorthand - calls current_user method
  provide :current_user

  # Controller method with explicit source
  provide :user, from: :current_user

  # Lambda
  provide :session_id, from: -> { session.id }

  # Direct value
  provide :app_name, from: "MyApp"

  # Complex lambda
  provide :permissions, from: -> do
    current_user.roles.map(&:permissions).flatten.uniq
  end
end
```

## See Also

- [Core Concepts](./core-concepts.md) - Understanding Treaty architecture
- [Defining Contracts](./defining-contracts.md) - Creating treaties
- [Examples](./examples.md) - Real-world usage patterns
- [API Reference](./api-reference.md) - Complete API documentation
