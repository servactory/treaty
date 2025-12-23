# frozen_string_literal: true

module Treaty
  module Action
    class Base
      include Info::DSL
      include Context::DSL
      include Versions::DSL
    end
  end
end
