# Treaty

## Draft

> [!WARNING]
> This is a rough draft for upcoming implementation.

### General part

```ruby
# config/initializers/treaty.rb
Treaty::Engine.configure do |config|
  config.version = lambda do |context|
    accept = context.request.headers["Accept"]
    return if accept.blank?

    match = accept.match(/application\/vnd\.myapp\.v(\d+)/)
    return if match.blank?

    match[1].to_i
  end

  config.error_handler = lambda do |exception|
    Sentry.capture_exception(exception)
  end

  config.error_response = lambda do |exception|
    {
      error: {
        message: exception.message
      }
    }
  end
end
```

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  treaty :index
  
  treaty :create

  # Equivalent to:
  # def create
  #   treaty = Users::CreateTreaty.call!(context: self, params:)
  #
  #   render json: treaty.data, status: treaty.status
  # rescue Treaty::Exceptions::Validation => e
  #   Treaty::Engine.config.treaty.error_handler.call(e)
  #
  #   render json: Treaty::Engine.config.treaty.error_response.call(e),
  #          status: :unprocessable_entity
  # rescue Treaty::Exceptions::Service => e
  #   Treaty::Engine.config.treaty.error_handler.call(e)
  #  
  #   render json: Treaty::Engine.config.treaty.error_response.call(e),
  #          status: :bad_request
  # end
end
```

```ruby
# app/treaties/application_treaty.rb
class ApplicationTreaty < Treaty::Base
end
```

### Closest version

```ruby
# app/treaties/users/index_treaty.rb
class Users::IndexTreaty < ApplicationTreaty
  version :v1 do
    strategy :service_chain

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::IndexService
  end

  version :v2 do
    strategy :adapter

    # There is no space for domain and HTTP code.
    response :id,
             :first_name,
             :middle_name,
             :last_name

    use Users::Stable::IndexService
  end
end
```

```ruby
# app/treaties/users/create_treaty.rb
class Users::CreateTreaty < ApplicationTreaty
  version :v1, "The first version of the contract for creating a user" do
    strategy :service_chain

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::CreateService
  end

  version :v2, "Added middle name to expand user data" do
    strategy :adapter

    # There is no space for domain and HTTP code.
    request :first_name,
            :middle_name,
            :last_name

    # There is no space for domain and HTTP code.
    response :id,
             :first_name,
             :middle_name,
             :last_name

    use Users::Stable::CreateService
  end
end
```

### Desired result

```ruby
# app/treaties/users/index_treaty.rb
class Users::IndexTreaty < ApplicationTreaty
  version :v1 do
    strategy :service_chain

    response :users, 200

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::IndexService
  end

  version :v2 do
    strategy :adapter

    response :users, 200 do
      string! :id
      string! :first_name
      string? :middle_name
      string! :last_name
    end

    use Users::Stable::IndexService
  end
end
```

```ruby
# app/treaties/users/create_treaty.rb
class Users::CreateTreaty < ApplicationTreaty
  version :v1, "The first version of the contract for creating a user" do
    strategy :service_chain

    request :user
    response :user, 201

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::CreateService
  end

  version :v2, "Added middle name to expand user data" do
    strategy :adapter

    request :user do
      string! :first_name
      string? :middle_name
      string! :last_name
    end

    response :user, 201 do
      string! :id
      string! :first_name
      string? :middle_name
      string! :last_name
    end

    use Users::Stable::CreateService
  end
end
```

### Problems

- How to share a dataset between treaties (controller actions)?
