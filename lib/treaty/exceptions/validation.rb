# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when attribute validation fails
    #
    # ## Purpose
    #
    # Indicates that data does not conform to the schema defined in the treaty.
    # Most commonly used exception in Treaty, covering all validation scenarios
    # including type mismatches, required fields, inclusion constraints, and more.
    #
    # ## Usage
    #
    # Raised automatically during validation in various scenarios:
    #
    # ### Required Field Validation
    # ```ruby
    # request do
    #   string :title, :required
    # end
    # # Raises: "Attribute 'title' is required but was not provided or is empty"
    # ```
    #
    # ### Type Validation
    # ```ruby
    # request do
    #   integer :age
    # end
    # # Passing "25" as string raises:
    # # "Attribute 'age' must be an Integer, got String"
    # ```
    #
    # ### Inclusion Validation
    # ```ruby
    # request do
    #   string :status, inclusion: ["active", "inactive"]
    # end
    # # Passing "pending" raises:
    # # "Attribute 'status' must be one of: active, inactive. Got: 'pending'"
    # ```
    #
    # ### Nested Structure Validation
    # ```ruby
    # request do
    #   array :tags do
    #     string :_self
    #   end
    # end
    # # Passing [123, 456] raises:
    # # "Error in array 'tags' at index 0: Element must match one of the defined types"
    # ```
    #
    # ### Custom Messages
    # ```ruby
    # request do
    #   string :email, required: { is: true, message: "Email is mandatory for registration" }
    # end
    # # Raises custom message when email is missing
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers to return appropriate HTTP status:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::Validation, with: :render_validation_error
    #
    # def render_validation_error(exception)
    #   render json: { error: exception.message }, status: :unprocessable_entity  # HTTP 422
    # end
    # ```
    #
    # ## Validation Types
    #
    # This exception covers multiple validation scenarios:
    #
    # - **Required** - Attribute presence validation
    # - **Type** - Data type validation (integer, string, array, object, datetime)
    # - **Inclusion** - Value must be in allowed set
    # - **Nested** - Complex structure validation (arrays, objects)
    # - **Options** - Unknown or invalid option specifications
    # - **Schema** - DSL definition validation
    #
    # ## HTTP Status
    #
    # Typically returns HTTP 422 Unprocessable Entity, indicating that the
    # request was well-formed but contains semantic errors.
    #
    # ## Localization
    #
    # All validation messages support I18n for multilingual applications.
    # Messages are defined in `config/locales/en.yml` under `treaty.attributes.validators.*`.
    class Validation < Base
    end
  end
end
