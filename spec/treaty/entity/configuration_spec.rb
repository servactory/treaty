# frozen_string_literal: true

RSpec.describe Treaty::Entity::Configuration do
  describe "#initialize" do
    it "creates configuration with empty options" do
      config = described_class.new

      expect(config.options).to eq({})
    end

    it "accepts required option as boolean" do
      config = described_class.new(required: true)

      expect(config.required_default).to eq(is: true, message: nil)
    end

    it "normalizes required: true to advanced mode" do
      config = described_class.new(required: true)

      expect(config.options[:required]).to eq(is: true, message: nil)
    end

    it "normalizes required: false to advanced mode" do
      config = described_class.new(required: false)

      expect(config.options[:required]).to eq(is: false, message: nil)
    end

    it "accepts required option as hash" do
      config = described_class.new(required: { is: true, message: "Custom message" })

      expect(config.required_default).to eq(is: true, message: "Custom message")
    end
  end

  describe "#required_default" do
    it "returns normalized required option" do
      config = described_class.new(required: true)

      expect(config.required_default).to eq(is: true, message: nil)
    end

    it "returns nil when not set" do
      config = described_class.new

      expect(config.required_default).to be_nil
    end
  end

  describe "#required?" do
    it "returns true when required is true" do
      config = described_class.new(required: true)

      expect(config.required?).to be true
    end

    it "returns false when required is false" do
      config = described_class.new(required: false)

      expect(config.required?).to be false
    end

    it "returns false when not set" do
      config = described_class.new

      expect(config.required?).to be false
    end
  end

  describe "#skip_default_required?" do
    it "returns true when required is explicitly false" do
      config = described_class.new(required: false)

      expect(config.skip_default_required?).to be true
    end

    it "returns false when required is true" do
      config = described_class.new(required: true)

      expect(config.skip_default_required?).to be false
    end

    it "returns false when not set" do
      config = described_class.new

      expect(config.skip_default_required?).to be false
    end
  end

  describe "#apply_to" do
    it "returns attribute options unchanged if required is set" do
      config = described_class.new(required: true)
      attr_options = { required: { is: false, message: nil } }

      result = config.apply_to(attr_options)

      expect(result[:required]).to eq(is: false, message: nil)
    end

    it "adds required default if not set in attribute" do
      config = described_class.new(required: true)
      attr_options = { type: :string }

      result = config.apply_to(attr_options)

      expect(result[:required]).to eq(is: true, message: nil)
    end

    it "does not modify original options" do
      config = described_class.new(required: true)
      attr_options = { type: :string }

      config.apply_to(attr_options)

      expect(attr_options).not_to have_key(:required)
    end

    it "returns unchanged options if no required default" do
      config = described_class.new
      attr_options = { type: :string }

      result = config.apply_to(attr_options)

      expect(result).to eq(type: :string)
    end
  end

  describe "#to_h" do
    it "returns options as hash" do
      config = described_class.new(required: true)

      expect(config.to_h).to eq(required: { is: true, message: nil })
    end

    it "returns copy of options" do
      config = described_class.new(required: true)

      result = config.to_h
      result[:other] = "value"

      expect(config.options).not_to have_key(:other)
    end
  end

  describe "#inspect" do
    it "returns readable representation" do
      config = described_class.new(required: true)

      expect(config.inspect).to include("Treaty::Entity::Configuration")
      expect(config.inspect).to include("required")
    end
  end
end
