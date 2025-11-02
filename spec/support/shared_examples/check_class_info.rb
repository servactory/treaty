# frozen_string_literal: true

RSpec.shared_examples "check class info" do
  it "returns expected information about class", :aggregate_failures do
    expect(described_class.respond_to?(:info)).to be(true)
    expect(described_class.info).to be_a(Treaty::Info::Result)

    expect(described_class.respond_to?(:treaty?)).to be(true)
    expect(described_class.treaty?).to be(true)
  end
end
