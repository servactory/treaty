# frozen_string_literal: true

module Treaty
  class Base
    include Info::DSL
    include Context::DSL
    include Versions::DSL
  end
end
