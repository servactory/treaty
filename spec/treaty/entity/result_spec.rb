# frozen_string_literal: true

RSpec.describe Treaty::Entity::Result do
  describe "#initialize" do
    it "creates result with empty data by default" do
      result = described_class.new

      expect(result.data).to eq({})
    end

    it "creates result with empty errors by default", :aggregate_failures do
      result = described_class.new

      expect(result.errors).to be_a(Treaty::Entity::Errors)
      expect(result.errors).to be_empty
    end

    it "accepts custom data" do
      result = described_class.new(data: { name: "John" })

      expect(result.data).to eq(name: "John")
    end

    it "accepts custom errors" do
      errors = Treaty::Entity::Errors.new
      errors.add(:email, "is invalid")
      result = described_class.new(errors:)

      expect(result.errors[:email]).to eq(["is invalid"])
    end
  end

  describe "#valid?" do
    it "returns true when no errors" do
      result = described_class.new

      expect(result).to be_valid
    end

    it "returns false when errors exist" do
      errors = Treaty::Entity::Errors.new
      errors.add(:email, "is invalid")
      result = described_class.new(errors:)

      expect(result).not_to be_valid
    end
  end

  describe "#invalid?" do
    it "returns false when no errors" do
      result = described_class.new

      expect(result).not_to be_invalid
    end

    it "returns true when errors exist" do
      errors = Treaty::Entity::Errors.new
      errors.add(:email, "is invalid")
      result = described_class.new(errors:)

      expect(result).not_to be_valid
    end
  end

  describe "#to_h" do
    it "returns data as hash" do
      result = described_class.new(data: { name: "John", age: 30 })

      expect(result.to_h).to eq(name: "John", age: 30)
    end

    it "is alias for data" do
      result = described_class.new(data: { name: "John" })

      expect(result.to_h).to eq(result.data)
    end
  end

  describe "#[]" do
    it "provides hash-like access to data" do
      result = described_class.new(data: { user: { name: "John" } })

      expect(result[:user]).to eq(name: "John")
    end

    it "returns nil for missing keys" do
      result = described_class.new(data: { name: "John" })

      expect(result[:unknown]).to be_nil
    end

    it "allows nested access" do
      result = described_class.new(data: { user: { name: "John" } })

      expect(result[:user][:name]).to eq("John")
    end
  end

  describe "#data=" do
    it "sets data" do
      result = described_class.new
      result.data = { name: "John" }

      expect(result.data).to eq(name: "John")
    end
  end

  describe "#inspect" do
    it "returns readable representation for valid result", :aggregate_failures do
      result = described_class.new(data: { name: "John" })

      expect(result.inspect).to include("Treaty::Entity::Result")
      expect(result.inspect).to include("@valid=true")
      expect(result.inspect).to include("name")
    end

    it "returns readable representation for invalid result" do
      errors = Treaty::Entity::Errors.new
      errors.add(:email, "is invalid")
      result = described_class.new(errors:)

      expect(result.inspect).to include("@valid=false")
    end
  end
end
