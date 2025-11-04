# frozen_string_literal: true

module Posts
  module V1
    class CreateService < ApplicationService::Base
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call
        inputs.params[:post][:id] ||= SecureRandom.uuid if inputs.params[:post]

        outputs.data = inputs.params
      end
    end
  end
end
