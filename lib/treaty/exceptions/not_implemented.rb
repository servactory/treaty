# frozen_string_literal: true

module Treaty
  module Exceptions
    class NotImplemented < Base
      # Custom NotImplementedError for Treaty
      #
      # ## Purpose
      #
      # Indicates that a required method must be implemented in a subclass.
      # Used instead of Ruby's standard NotImplementedError to integrate with
      # Treaty's exception handling system.
      #
      # ## Usage
      #
      # ```ruby
      # def some_method
      #   raise Treaty::Exceptions::NotImplemented,
      #         I18n.t("treaty.builder.not_implemented", class: self.class)
      # end
      # ```
      #
      # ## Integration
      #
      # Can be rescued by application controllers using rescue_from:
      #
      # ```ruby
      # rescue_from Treaty::Exceptions::NotImplemented, with: :render_not_implemented_error
      # ```
    end
  end
end
