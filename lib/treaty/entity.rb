# frozen_string_literal: true

module Treaty
  # Entity namespace containing the base class and attribute system.
  #
  # Users should inherit from Treaty::Entity::Base:
  #
  #   class MyEntity < Treaty::Entity::Base
  #     string :name
  #     integer :age
  #   end
  #
  # @see Treaty::Entity::Base for full documentation and examples
  module Entity
  end
end
