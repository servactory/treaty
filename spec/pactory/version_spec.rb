# frozen_string_literal: true

RSpec.describe Pactory::VERSION do
  it { expect(Pactory::VERSION::STRING).to be_present }
end
