# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when a Treaty class cannot be found or resolved
    #
    # ## Purpose
    #
    # Indicates that the system attempted to load a Treaty class (typically via
    # constantize) but the class does not exist in the expected location.
    #
    # ## Usage
    #
    # Raised automatically by the Controller DSL when treaty class resolution fails:
    #
    # ```ruby
    # # In PostsController, looking for Gate::API::Posts::IndexTreaty
    # def treaty_class
    #   treaty_class_name.constantize
    # rescue NameError
    #   raise Treaty::Exceptions::ClassName,
    #         I18n.t("treaty.controller.treaty_class_not_found", class_name: treaty_class_name)
    # end
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::ClassName, with: :render_treaty_class_not_found_error
    #
    # def render_treaty_class_not_found_error(exception)
    #   render json: { error: exception.message }, status: :internal_server_error
    # end
    # ```
    #
    # ## Common Causes
    #
    # - Treaty class file not created
    # - Incorrect naming convention (should match controller name pattern)
    # - Typo in class name
    # - Missing autoload path configuration
    class ClassName < Base
      def initialize(class_name)
        super("Invalid class name: #{class_name}")
      end
    end
  end
end
