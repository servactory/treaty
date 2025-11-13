# frozen_string_literal: true

module Languages
  module V1
    class ShowService < ApplicationService::Base
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call
        outputs.data = inputs.params
      end
    end
  end
end
