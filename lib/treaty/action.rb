# frozen_string_literal: true

module Treaty
  # Action namespace containing the base class and versioning system.
  #
  # Users should inherit from Treaty::Action::Base:
  #
  #   class Posts::CreateTreaty < Treaty::Action::Base
  #     version 1, default: true do
  #       summary "Create a new post"
  #
  #       request do
  #         object :post do
  #           string :title, :required
  #         end
  #       end
  #
  #       response 201 do
  #         object :post do
  #           string :id
  #         end
  #       end
  #
  #       delegate_to Posts::CreateService
  #     end
  #   end
  #
  # @see Treaty::Action::Base for full documentation and examples
  module Action
  end
end
