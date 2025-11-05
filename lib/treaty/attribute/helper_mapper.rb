# frozen_string_literal: true

module Treaty
  module Attribute
    # Maps DSL helper symbols to their simple mode option equivalents.
    #
    # ## Purpose
    #
    # Helpers provide the most concise syntax for common options.
    # They are syntactic sugar that gets converted to simple mode options.
    #
    # ## Available Helpers
    #
    # - `:required` → `required: true`
    # - `:optional` → `required: false`
    #
    # ## Usage Examples
    #
    # Helper mode (most concise):
    #   string :title, :required
    #   string :bio, :optional
    #
    # Equivalent to simple mode:
    #   string :title, required: true
    #   string :bio, required: false
    #
    # ## Processing Flow
    #
    # 1. Helper mode: `string :title, :required`
    # 2. HelperMapper: `:required` → `required: true`
    # 3. OptionNormalizer: `required: true` → `{ is: true, message: nil }`
    # 4. Final: Advanced mode used internally
    #
    # ## Adding New Helpers
    #
    # To add a new helper:
    # ```ruby
    # HELPER_MAPPINGS = {
    #   required: { required: true },
    #   optional: { required: false },
    #   my_helper: { my_option: :smth }  # New helper example
    # }.freeze
    # ```
    class HelperMapper
      HELPER_MAPPINGS = {
        required: { required: true },
        optional: { required: false }
      }.freeze

      class << self
        # Maps helper symbols to their simple mode equivalents
        #
        # @param helpers [Array<Symbol>] Array of helper symbols
        # @return [Hash] Simple mode options hash
        def map(helpers)
          helpers.each_with_object({}) do |helper, result|
            mapping = HELPER_MAPPINGS.fetch(helper)
            result.merge!(mapping) if mapping.present?
          end
        end

        # Checks if a symbol is a registered helper
        #
        # @param symbol [Symbol] Symbol to check
        # @return [Boolean] True if symbol is a helper
        def helper?(symbol)
          HELPER_MAPPINGS.key?(symbol)
        end
      end
    end
  end
end
