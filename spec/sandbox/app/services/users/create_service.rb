# frozen_string_literal: true

module Users
  class CreateService < ApplicationService::Base
    input :params, type: Hash, required: false, default: {}

    output :data, type: Hash

    private

    def call # rubocop:disable Metrics/AbcSize
      user_params = inputs.params[:user] || {}

      # Generate ID if not present
      user_params[:id] ||= SecureRandom.uuid

      # Set timestamps if not present
      user_params[:created_at] ||= Time.current
      user_params[:updated_at] ||= Time.current

      # Apply default for role if not present (already defined in DTO, but for safety)
      user_params[:role] ||= "user"

      # Apply default for email_verified if not present
      user_params[:email_verified] ||= "false"

      outputs.data = { user: user_params }
    end
  end
end
