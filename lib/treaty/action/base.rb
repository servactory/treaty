# frozen_string_literal: true

module Treaty
  module Action
    class Base
      include Info::Rest::DSL
      include Context::DSL
      include Versions::DSL
    end
  end
end
