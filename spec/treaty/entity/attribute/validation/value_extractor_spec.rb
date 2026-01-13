# frozen_string_literal: true

RSpec.describe Treaty::Entity::Attribute::Validation::ValueExtractor do
  describe ".extract" do
    context "with Hash source" do
      let(:source) { { name: "Alice", email: "alice@example.com", age: 30 } }

      it "extracts value by symbol key" do
        expect(described_class.extract(source, :name)).to eq("Alice")
      end

      it "extracts nested value" do
        nested_source = { user: { name: "Bob" } }
        expect(described_class.extract(nested_source, :user)).to eq({ name: "Bob" })
      end

      it "returns nil for missing key" do
        expect(described_class.extract(source, :unknown)).to be_nil
      end

      it "returns nil for explicitly nil value" do
        source_with_nil = { name: nil }
        expect(described_class.extract(source_with_nil, :name)).to be_nil
      end

      it "returns false for false value (not nil)" do
        source_with_false = { active: false }
        expect(described_class.extract(source_with_false, :active)).to be(false)
      end

      it "returns empty string for empty string value" do
        source_with_empty = { bio: "" }
        expect(described_class.extract(source_with_empty, :bio)).to eq("")
      end
    end

    context "with Struct source" do
      let(:user_struct) { Struct.new(:name, :email, keyword_init: true) }
      let(:source) { user_struct.new(name: "Alice", email: "alice@example.com") }

      it "extracts value via public_send" do
        expect(described_class.extract(source, :name)).to eq("Alice")
      end

      it "extracts another attribute" do
        expect(described_class.extract(source, :email)).to eq("alice@example.com")
      end

      it "returns nil when method not defined" do
        expect(described_class.extract(source, :unknown)).to be_nil
      end
    end

    context "with custom PORO class" do
      let(:user_class) do
        Class.new do
          attr_reader :name, :email

          def initialize(name:, email:)
            @name = name
            @email = email
          end

          private

          def secret
            "hidden"
          end
        end
      end

      let(:source) { user_class.new(name: "Alice", email: "alice@example.com") }

      it "extracts value via public_send" do
        expect(described_class.extract(source, :name)).to eq("Alice")
      end

      it "returns nil when method not defined" do
        expect(described_class.extract(source, :unknown)).to be_nil
      end

      it "returns nil for private methods" do
        expect(described_class.extract(source, :secret)).to be_nil
      end
    end

    context "with Data class (Ruby 3.2+)" do
      let(:user_data) { Data.define(:name, :email) }
      let(:source) { user_data.new(name: "Alice", email: "alice@example.com") }

      it "extracts value via public_send" do
        expect(described_class.extract(source, :name)).to eq("Alice")
      end

      it "returns nil when method not defined" do
        expect(described_class.extract(source, :unknown)).to be_nil
      end
    end

    context "with edge cases" do
      it "handles nil source gracefully" do
        expect(described_class.extract(nil, :name)).to be_nil
      end

      it "handles empty Hash" do
        expect(described_class.extract({}, :name)).to be_nil
      end

      it "returns array values from Hash" do
        source = { tags: %w[ruby rails] }
        expect(described_class.extract(source, :tags)).to eq(%w[ruby rails])
      end

      it "returns hash values from Hash" do
        source = { meta: { created_at: "2024-01-01" } }
        expect(described_class.extract(source, :meta)).to eq({ created_at: "2024-01-01" })
      end
    end
  end
end
