# frozen_string_literal: true

module Treaty
  # Base class for defining DTO (Data Transfer Object) entities in Treaty.
  #
  # ## Purpose
  #
  # Treaty::Entity provides a base class for creating reusable DTO classes
  # that can be used in both request and response definitions. This allows
  # for better code organization and reusability of common data structures.
  #
  # ## Standalone Usage
  #
  # Entity classes can be used independently for data validation and transformation:
  #
  # ```ruby
  # class UserEntity < Treaty::Entity
  #   object :user do
  #     string :name
  #     string :email, format: :email
  #   end
  # end
  #
  # # Validate and transform data
  # result = UserEntity.call(params)
  # result.valid?     # => true/false
  # result.data       # => { user: { name: "John", email: "john@test.com" } }
  # result.errors     # => Errors collection
  #
  # # With exception on validation errors
  # result = UserEntity.call!(params)  # raises Treaty::Exceptions::Validation
  #
  # # Check validity only (predicate)
  # UserEntity.valid?(params)  # => true/false
  # ```
  #
  # ## Options via .preset()
  #
  # Use `.preset()` method to configure validation behavior. This approach
  # avoids name conflicts between attribute names and option names:
  #
  # ```ruby
  # # With options
  # UserEntity.preset(required: false).call(data)  # lenient validation
  # UserEntity.preset(required: false, default: "N/A").call(data)  # multiple options
  #
  # # Reuse preset
  # preset = UserEntity.preset(required: false)
  # result1 = preset.call(data1)
  # result2 = preset.call(data2)
  #
  # # No conflict with attribute names!
  # class PaymentEntity < Treaty::Entity
  #   object :payment do
  #     boolean :required  # Attribute named "required" - OK!
  #   end
  # end
  # PaymentEntity.preset(required: false).call({ payment: { required: true } })
  # ```
  #
  # ## Usage with Treaty Class
  #
  # Entity classes can also be used in Treaty definitions:
  #
  # ```ruby
  # class CreateTreaty < ApplicationTreaty
  #   version 1 do
  #     request PostEntity
  #     response 201, PostEntity
  #   end
  # end
  # ```
  #
  # ## Attribute Defaults
  #
  # Unlike request/response blocks, Entity attributes are required by default:
  # - All attributes have `required: true` unless explicitly marked as `:optional`
  # - Use `:optional` helper to make attributes optional:
  #   ```ruby
  #   string :title           # required by default
  #   string :summary, :optional  # optional
  #   ```
  #
  # ## Features
  #
  # - **Type Safety** - Enforce strict type checking for all attributes
  # - **Nested Structures** - Support for nested objects and arrays
  # - **Validation** - Built-in validation for all attribute types
  # - **Reusability** - Define once, use in multiple treaties
  # - **Options** - Full support for attribute options (required, default, as, etc.)
  #
  # ## Supported Types
  #
  # - `string` - String values
  # - `integer` - Integer values
  # - `boolean` - Boolean values (true/false)
  # - `datetime` - DateTime values
  # - `array` - Array values (with nested type definition)
  # - `object` - Object values (with nested attributes)
  class Entity
    include Info::Entity::DSL
    include Attribute::DSL
    include Context::DSL
    include Processing::DSL
  end
end
