# frozen_string_literal: true

module Posts
  module Stable
    class CreateService < ApplicationService::Base
      input :params, type: Hash

      output :data, type: Hash

      private

      def call
        outputs.data = {}
      end
    end
  end
end
