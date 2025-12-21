# frozen_string_literal: true

module Shared
  class SocialEntity < ApplicationEntity
    string :provider, in: %w[twitter linkedin github]
    string :handle
  end
end
