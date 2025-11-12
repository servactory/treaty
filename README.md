<div align="center">
  <h1>Treaty</h1>
  <p>A Ruby library for defining and managing REST API contracts with versioning support.</p>
</div>

<div align="center">

[![Gem Version](https://img.shields.io/gem/v/treaty.svg)](https://rubygems.org/gems/treaty)
[![Release Date](https://img.shields.io/github/release-date/servactory/treaty)](https://github.com/servactory/treaty/releases)
[![Gem Downloads](https://img.shields.io/gem/dt/treaty.svg)](https://rubygems.org/gems/treaty)
[![Ruby Version](https://img.shields.io/badge/Ruby-3.2%2B-red)](https://www.ruby-lang.org)

</div>

> [!WARNING]
> **Development Status**: Treaty is currently under active development in the 0.x version series. Breaking changes may occur between minor versions (0.x) as we refine the API and add new features. The library will stabilize with the 1.0 release. We recommend pinning to specific patch versions in your Gemfile (e.g., `gem "treaty", "~> 0.5.0"`) until the 1.0 release.

## 📚 Documentation

Explore comprehensive guides and documentation at [docs](./docs):

- [Getting Started](./docs/getting-started.md) - installation and configuration
- [Core Concepts](./docs/core-concepts.md) - understand fundamental concepts
- [API Reference](./docs/api-reference.md) - complete API documentation
- [Examples](./docs/examples.md) - practical real-world examples
- [Internationalization](./docs/internationalization.md) - I18n and multilingual support
- [Full Documentation Index](./docs/README.md) - all documentation topics

## 💡 Why Treaty?

Treaty provides a complete solution for building versioned APIs in Ruby on Rails:

- **Type Safety** - Enforce strict type checking for request and response data
- **API Versioning** - Manage multiple concurrent API versions effortlessly
- **Built-in Validation** - Validate incoming requests and outgoing responses automatically
- **Data Transformation** - Transform data seamlessly between different API versions
- **Deprecation Management** - Mark versions as deprecated with flexible conditions
- **Internationalization** - Full I18n support for multilingual error messages
- **Well-documented** - Comprehensive guides and examples for every feature

## 🚀 Quick Start

### Installation

Add Treaty to your Gemfile:

```ruby
gem "treaty"
```

Run:

```bash
bundle install
```

### Define Treaty

Create your first API contract in `app/treaties/posts/create_treaty.rb`:

```ruby
module Posts
  class CreateTreaty < ApplicationTreaty
    version 1, default: true do
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

      delegate_to Posts::CreateService
    end
  end
end
```

### Use in Controller

Define the treaty in your controller `app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  # Treaty automatically:
  # 1. Validates incoming parameters according to request definition
  # 2. Calls Posts::CreateService with validated data
  # 3. Validates service response according to response definition
  # 4. Returns transformed data to client
  treaty :create
end
```

## 🤝 Contributing

We welcome contributions! You can help by:

- Reporting bugs and suggesting features
- Writing code and improving documentation
- Reviewing pull requests
- Sharing your experience with Treaty

Please read our [Contributing Guide](./CONTRIBUTING.md) before submitting a pull request.

## 🙏 Acknowledgments

Thank you to all [contributors](https://github.com/servactory/treaty/graphs/contributors) who have helped make Treaty better!

## 📄 License

Treaty is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
