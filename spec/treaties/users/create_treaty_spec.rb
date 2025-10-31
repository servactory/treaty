# frozen_string_literal: true

RSpec.describe Users::CreateTreaty do
  subject(:perform) { described_class.call!(context:, params:) }

  let(:context) { nil }
  let(:params) { {} }

  context "when required data for work is valid" do
    it { expect { perform }.not_to raise_error }
  end
end
