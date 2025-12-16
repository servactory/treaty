# frozen_string_literal: true

module Shared
  class SocialDto < ApplicationDto
    string :provider, in: %w[twitter linkedin github]
    string :handle
  end
end
