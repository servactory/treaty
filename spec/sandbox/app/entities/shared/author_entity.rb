# frozen_string_literal: true

module Shared
  class AuthorEntity < ApplicationEntity
    string :name
    string :bio, :optional

    array :socials, :optional do
      use_entity(Shared::SocialEntity)
    end
  end
end
