# frozen_string_literal: true

module Treaty
  class Base
    include Context::DSL
    include Versions::DSL
  end
end
