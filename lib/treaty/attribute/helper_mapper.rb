# frozen_string_literal: true

module Treaty
  module Attribute
    class HelperMapper
      HELPER_MAPPINGS = {
        required: { required: true },
        optional: { required: false }
      }.freeze

      class << self
        def map(helpers)
          helpers.each_with_object({}) do |helper, result|
            mapping = HELPER_MAPPINGS.fetch(helper)
            result.merge!(mapping) if mapping.present?
          end
        end

        def helper?(symbol)
          HELPER_MAPPINGS.key?(symbol)
        end
      end
    end
  end
end
