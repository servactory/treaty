# frozen_string_literal: true

class SocialEntity < ApplicationEntity
  string :provider, in: %w[twitter linkedin github]
  string :handle
end
