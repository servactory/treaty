# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Modifiers::AsModifier do
  subject(:modifier) do
    described_class.new(
      attribute_name:,
      attribute_type: :string,
      option_schema:
    )
  end

  let(:attribute_name) { :user_handle }

  describe "#validate_schema!" do
    context "when option value is a Symbol" do
      let(:option_schema) { { is: :username, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "when option value is a String" do
      let(:option_schema) { { is: "username", message: nil } }

      it "raises a validation error" do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("user_handle")
            expect(exception.message).to include("String")
          end
        )
      end
    end

    context "when option value is an Integer" do
      let(:option_schema) { { is: 123, message: nil } }

      it "raises a validation error" do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("user_handle")
            expect(exception.message).to include("Integer")
          end
        )
      end
    end

    context "when option value is nil" do
      let(:option_schema) { { is: nil, message: nil } }

      it "raises a validation error" do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("user_handle")
            expect(exception.message).to include("NilClass")
          end
        )
      end
    end
  end

  describe "#transforms_name?" do
    let(:option_schema) { { is: :username, message: nil } }

    it "returns true" do
      expect(modifier.transforms_name?).to be true
    end
  end

  describe "#target_name" do
    context "when target is :username" do
      let(:option_schema) { { is: :username, message: nil } }

      it "returns :username" do
        expect(modifier.target_name).to eq(:username)
      end
    end

    context "when target is :value" do
      let(:option_schema) { { is: :value, message: nil } }

      it "returns :value" do
        expect(modifier.target_name).to eq(:value)
      end
    end
  end

  describe "#transform_value" do
    let(:option_schema) { { is: :username, message: nil } }

    context "when value is a String" do
      it "returns the value unchanged" do
        result = modifier.transform_value("alice")
        expect(result).to eq("alice")
      end
    end

    context "when value is an Integer" do
      it "returns the value unchanged" do
        result = modifier.transform_value(123)
        expect(result).to eq(123)
      end
    end

    context "when value is nil" do
      it "returns the value unchanged" do
        result = modifier.transform_value(nil)
        expect(result).to be_nil
      end
    end

    context "when value is a Hash" do
      it "returns the value unchanged" do
        value = { name: "Alice" }
        result = modifier.transform_value(value)
        expect(result).to eq(value)
      end
    end

    context "when value is an Array" do
      it "returns the value unchanged" do
        value = [1, 2, 3]
        result = modifier.transform_value(value)
        expect(result).to eq(value)
      end
    end
  end
end
