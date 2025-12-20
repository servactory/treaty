# frozen_string_literal: true

module Shared
  class AuthorDto < ApplicationDto
    string :name
    string :bio, :optional

    array :socials, :optional do
      use_entity(Shared::SocialDto)
    end
  end
end
