# frozen_string_literal: true

RSpec.describe Treaty::VERSION do
  it { expect(Treaty::VERSION::STRING).to be_present }
end
