# frozen_string_literal: true

module Posts
  class AuthorDto < ApplicationDto
    string :name
    string :bio

    array :socials, :optional do
      use_entity(SocialDto)
    end
  end
end
