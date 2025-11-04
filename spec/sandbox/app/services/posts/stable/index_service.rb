# frozen_string_literal: true

module Posts
  module Stable
    class IndexService < ApplicationService::Base
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call
        outputs.data = {}
      end
    end
  end
end
