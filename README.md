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
end
```

```ruby
class ApplicationController < ActionController::API
  rescue_from Treaty::Exceptions::Validation, with: :render_validation_error
  rescue_from Treaty::Exceptions::Execution, with: :render_execution_error
  rescue_from Treaty::Exceptions::Unexpected, with: :render_unexpected_error

  private

  def render_validation_error(exception)
    render json: build_error_response_for(exception),
           status: :unprocessable_entity
  end

  def render_execution_error(exception)
    render json: build_error_response_for(exception),
           status: :bad_request
  end

  def render_unexpected_error(exception)
    render json: build_error_response_for(exception),
           status: :internal_server_error
  end

  def build_error_response_for(exception)
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
  # end
end
```

```ruby
# app/treaties/application_treaty.rb
class ApplicationTreaty < Treaty::Base
end
```

### Closest version

<details>
    <summary>This version cannot be implemented due to too many functional requirements</summary>

```ruby
# app/treaties/users/index_treaty.rb
class Users::IndexTreaty < ApplicationTreaty
  version :v1 do
    strategy :direct

    # Present: first_name, last_name. Missing: middle_name.
    delegate_to Users::V1::IndexService
  end

  version :v2 do
    strategy :adapter

    # There is no space for domain and HTTP code.
    response :id,
             :first_name,
             :middle_name,
             :last_name

    delegate_to Users::Stable::IndexService
  end
end
```

```ruby
# app/treaties/users/create_treaty.rb
class Users::CreateTreaty < ApplicationTreaty
  version :v1 do
    summary "The first version of the contract for creating a user"

    strategy :direct

    # Present: first_name, last_name. Missing: middle_name.
    delegate_to Users::V1::CreateService
  end

  version :v2 do
    summary "Added middle name to expand user data"

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

    delegate_to Users::Stable::CreateService
  end
end
```

</details>

### Desired result

```ruby
# app/treaties/users/index_treaty.rb
class Users::IndexTreaty < ApplicationTreaty
  version :v1 do
    strategy :direct

    # Query: filters[first_name], filters[middle_name], filters[last_name]
    request :filters do
      string :first_name, :string, :optional
      string :middle_name, :string, :optional
      string :last_name, :string, :optional
    end

    response :users, 200

    # Present: first_name, last_name. Missing: middle_name.
    delegate_to Users::V1::IndexService
  end

  version :v2 do
    strategy :adapter

    # Query: filters[first_name], filters[middle_name], filters[last_name]
    request :filters do
      string :first_name, :string, :optional
      string :middle_name, :string, :optional
      string :last_name, :string, :optional
    end

    response :users, 200 do
      string :id
      string :first_name
      string :middle_name
      string :last_name
    end

    delegate_to Users::Stable::IndexService
  end
end
```

```ruby
# app/treaties/users/create_treaty.rb
class Users::CreateTreaty < ApplicationTreaty
  version :v1 do
    summary "The first version of the contract for creating a user"

    strategy :direct

    deprecated do
      Gem::Version.new(ENV.fetch("RELEASE_VERSION", nil)) >= 
        Gem::Version.new("17.0.0")
    end

    request :user
    response :user, 201

    # Present: first_name, last_name. Missing: middle_name.
    delegate_to Users::V1::CreateService
  end

  version :v2 do
    summary "Added middle name to expand user data"

    strategy :adapter

    request :user do
      string :first_name, :string, :required
      string :middle_name, :string, :optional
      string :last_name, :string, :required
    end

    response :user, 201 do
      string :id
      string :first_name
      string :middle_name
      string :last_name
    end

    delegate_to Users::Stable::CreateService
  end

  version :v3 do
    summary "Added address and socials to expand user data"

    strategy :adapter

    request :user do
      # Query
      string :signature, :required

      # Body
      string :first_name, :required
      string :middle_name, :optional
      string :last_name, :required

      object :address, :required do
        string :street, :required
        string :city, :required
        string :state, :required
        string :zipcode, :required
      end

      array :socials, :optional do
        string :provider, :required, in: %w[twitter linkedin github]
        string :handle, :required, as: :value
      end
    end

    response :user, 201 do
      string :id
      string :first_name
      string :middle_name
      string :last_name

      object :address do
        string :street
        string :city
        string :state
        string :zipcode
      end

      datetime :created_at
      datetime :updated_at
    end

    delegate_to Users::Stable::CreateService
  end
end
```

### Problems

- How to implement work with path and query?
- How to implement filtering from query for IndexTreaty?
- How to share a dataset between treaties (controller actions)?
