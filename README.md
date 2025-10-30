# Pactory

## Draft

> [!WARNING]
> This is a rough draft for upcoming implementation.

### General part

```ruby
class UsersController < ApplicationController
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
# app/pacts/users/create_pact.rb
class Users::CreatePact < ApplicationPact
  version :v1, "The first version of the contract for creating a user" do
    strategy :adapter
    
    request :first_name,
            :middle_name,
            :last_name

    response :id,
             :first_name,
             :middle_name,
             :last_name

    use Users::CreateService
  end
end
```

### Desired result

```ruby
# app/pacts/users/create_pact.rb
class Users::CreatePact < ApplicationPact
  version :v1, "The first version of the contract for creating a user" do
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

    use Users::CreateService
  end
end
```
