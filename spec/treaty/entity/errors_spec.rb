# frozen_string_literal: true

RSpec.describe Treaty::Entity::Errors do
  subject(:errors) { described_class.new }

  describe "#add" do
    it "adds error message for attribute" do
      errors.add(:email, "is invalid")

      expect(errors[:email]).to eq(["is invalid"])
    end

    it "adds multiple messages for same attribute" do
      errors.add(:email, "is invalid")
      errors.add(:email, "must be unique")

      expect(errors[:email]).to eq(["is invalid", "must be unique"])
    end

    it "returns all messages for attribute" do
      result = errors.add(:email, "is invalid")

      expect(result).to eq(["is invalid"])
    end

    it "accepts string attribute names" do
      errors.add("email", "is invalid")

      expect(errors[:email]).to eq(["is invalid"])
    end

    it "accepts nested paths" do
      errors.add("user.email", "is invalid")

      expect(errors["user.email"]).to eq(["is invalid"])
    end
  end

  describe "#[]" do
    it "returns messages for attribute" do
      errors.add(:email, "is invalid")

      expect(errors[:email]).to eq(["is invalid"])
    end

    it "returns empty array for unknown attribute" do
      expect(errors[:unknown]).to eq([])
    end

    it "works with string keys" do
      errors.add(:email, "is invalid")

      expect(errors["email"]).to eq(["is invalid"])
    end
  end

  describe "#empty?" do
    it "returns true when no errors" do
      expect(errors).to be_empty
    end

    it "returns false when errors exist" do
      errors.add(:email, "is invalid")

      expect(errors).not_to be_empty
    end
  end

  describe "#any?" do
    it "returns false when no errors" do
      expect(errors.any?).to be false
    end

    it "returns true when errors exist" do
      errors.add(:email, "is invalid")

      expect(errors.any?).to be true
    end
  end

  describe "#each" do
    it "yields attribute and messages" do
      errors.add(:email, "is invalid")
      errors.add(:name, "is required")

      result = errors.map { |attr, msgs| [attr, msgs] }

      expect(result).to contain_exactly(
        ["email", ["is invalid"]],
        ["name", ["is required"]]
      )
    end

    it "is enumerable" do
      expect(errors).to be_a(Enumerable)
    end
  end

  describe "#full_messages" do
    it "returns formatted messages" do
      errors.add(:email, "is invalid")
      errors.add(:name, "is required")

      expect(errors.full_messages).to contain_exactly(
        "email: is invalid",
        "name: is required"
      )
    end

    it "handles multiple messages per attribute" do
      errors.add(:email, "is invalid")
      errors.add(:email, "must be unique")

      expect(errors.full_messages).to contain_exactly(
        "email: is invalid",
        "email: must be unique"
      )
    end

    it "handles nested paths" do
      errors.add("user.email", "is invalid")

      expect(errors.full_messages).to eq(["user.email: is invalid"])
    end

    it "returns empty array when no errors" do
      expect(errors.full_messages).to eq([])
    end
  end

  describe "#to_h" do
    it "returns flat hash for simple attributes" do
      errors.add(:email, "is invalid")
      errors.add(:name, "is required")

      expect(errors.to_h).to eq(
        email: ["is invalid"],
        name: ["is required"]
      )
    end

    it "returns nested hash for dotted paths" do
      errors.add("user.email", "is invalid")

      expect(errors.to_h).to eq(
        user: { email: ["is invalid"] }
      )
    end

    it "handles deeply nested paths" do
      errors.add("user.address.city", "is required")

      expect(errors.to_h).to eq(
        user: { address: { city: ["is required"] } }
      )
    end

    it "returns empty hash when no errors" do
      expect(errors.to_h).to eq({})
    end
  end

  describe "#to_a" do
    it "returns array of hashes" do
      errors.add(:email, "is invalid")
      errors.add(:name, "is required")

      expect(errors.to_a).to contain_exactly(
        { attribute: "email", messages: ["is invalid"] },
        { attribute: "name", messages: ["is required"] }
      )
    end

    it "returns empty array when no errors" do
      expect(errors.to_a).to eq([])
    end
  end

  describe "#size" do
    it "returns total number of messages" do
      errors.add(:email, "is invalid")
      errors.add(:email, "must be unique")
      errors.add(:name, "is required")

      expect(errors.size).to eq(3)
    end

    it "returns 0 when no errors" do
      expect(errors.size).to eq(0)
    end

    it "has count alias" do
      errors.add(:email, "is invalid")

      expect(errors.count).to eq(1)
    end

    it "has length alias" do
      errors.add(:email, "is invalid")

      expect(errors.length).to eq(1)
    end
  end

  describe "#clear" do
    it "removes all errors" do
      errors.add(:email, "is invalid")
      errors.clear

      expect(errors).to be_empty
    end

    it "returns self" do
      expect(errors.clear).to eq(errors)
    end
  end

  describe "#inspect" do
    it "returns readable representation", :aggregate_failures do
      errors.add(:email, "is invalid")

      expect(errors.inspect).to include("Treaty::Entity::Errors")
      expect(errors.inspect).to include("email")
    end
  end

  describe "#merge" do
    it "merges errors from another instance", :aggregate_failures do
      other = described_class.new
      other.add(:email, "is invalid")

      errors.add(:name, "is required")
      errors.merge(other)

      expect(errors[:email]).to eq(["is invalid"])
      expect(errors[:name]).to eq(["is required"])
    end

    it "adds prefix to merged errors" do
      other = described_class.new
      other.add(:email, "is invalid")

      errors.merge(other, prefix: "user")

      expect(errors["user.email"]).to eq(["is invalid"])
    end

    it "returns self" do
      other = described_class.new

      expect(errors.merge(other)).to eq(errors)
    end
  end
end
