# Pactory

## Draft

> [!WARNING]
> This is a rough draft for upcoming implementation.

### General part

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  action :index
  
  action :create
end
```

```ruby
# app/pacts/application_pact.rb
class ApplicationPact < Pactory::Base
end
```

### Closest version

```ruby
# app/pacts/users/index_pact.rb
class Users::IndexPact < ApplicationPact
  version :v1 do
    strategy :service_chain

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::IndexService
  end

  version :v2 do
    strategy :adapter

    response :id,
             :first_name,
             :middle_name,
             :last_name

    use Users::Stable::IndexService
  end
end
```

```ruby
# app/pacts/users/create_pact.rb
class Users::CreatePact < ApplicationPact
  version :v1, "The first version of the contract for creating a user" do
    strategy :service_chain

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::CreateService
  end

  version :v2, "Added middle name to expand user data" do
    strategy :adapter

    request :first_name,
            :middle_name,
            :last_name

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
# app/pacts/users/index_pact.rb
class Users::IndexPact < ApplicationPact
  version :v1 do
    strategy :service_chain

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::IndexService
  end

  version :v2 do
    strategy :adapter

    response do
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
# app/pacts/users/create_pact.rb
class Users::CreatePact < ApplicationPact
  version :v1, "The first version of the contract for creating a user" do
    strategy :service_chain

    # Present: first_name, last_name. Missing: middle_name.
    use Users::V1::CreateService
  end

  version :v2, "Added middle name to expand user data" do
    strategy :adapter
    
    request do
      string! :first_name
      string? :middle_name
      string! :last_name
    end

    response do
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

- How to share a dataset between pacts (controller actions)?
