# frozen_string_literal: true

RSpec.shared_examples "check treaty class info" do |versions:|
  it "returns expected information about class", :aggregate_failures do
    expect(described_class.respond_to?(:info)).to be(true)
    expect(described_class.info).to be_a(Treaty::Info::Rest::Result)

    expect(described_class.info.respond_to?(:versions)).to be(true)
    expect(described_class.info.versions).to match(versions)

    expect(described_class.respond_to?(:treaty?)).to be(true)
    expect(described_class.treaty?).to be(true)
  end
end

RSpec.shared_examples "check treaty entity info" do |attributes:|
  it "returns expected information about class", :aggregate_failures do
    expect(described_class.respond_to?(:info)).to be(true)
    expect(described_class.info).to be_a(Treaty::Info::Entity::Result)

    expect(described_class.info.respond_to?(:attributes)).to be(true)
    expect(described_class.info.attributes).to match(attributes)

    expect(described_class.respond_to?(:treaty?)).to be(true)
    expect(described_class.treaty?).to be(true)
  end
end
