# frozen_string_literal: true

module Posts
  class SocialDto < ApplicationDto
    string :provider, in: %w[twitter linkedin github]
    string :handle, as: :value
  end
end
