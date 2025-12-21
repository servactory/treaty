# frozen_string_literal: true

class AuthorEntity < ApplicationEntity
  string :name
  string :bio, :optional

  array :socials, :optional do
    use_entity(SocialEntity)
  end
end