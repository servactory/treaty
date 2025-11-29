# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Conditionals::Base do
  subject(:conditional) do
    described_class.new(
      attribute_name: :test_attr,
      attribute_type: :string,
      option_schema:
    )
  end

  let(:option_schema) { ->(post:) { post[:published_at].present? } }

  describe "#validate_schema!" do
    context "when called on Base class directly" do
      it "raises NotImplemented error", :aggregate_failures do
        expect { conditional.validate_schema! }.to(
          raise_error(Treaty::Exceptions::NotImplemented) do |exception|
            expect(exception.message).to include("must implement #validate_schema!")
            expect(exception.message).to include(described_class.name)
          end
        )
      end
    end
  end

  describe "#evaluate_condition" do
    let(:data) { { post: { published_at: Time.current } } }

    context "when called on Base class directly" do
      it "raises NotImplemented error", :aggregate_failures do
        expect { conditional.evaluate_condition(data) }.to(
          raise_error(Treaty::Exceptions::NotImplemented) do |exception|
            expect(exception.message).to include("must implement #evaluate_condition")
            expect(exception.message).to include(described_class.name)
          end
        )
      end
    end
  end

  describe "#validate_value!" do
    context "when called with any value" do
      it "does not raise error for nil" do
        expect { conditional.validate_value!(nil) }.not_to raise_error
      end

      it "does not raise error for string" do
        expect { conditional.validate_value!("test") }.not_to raise_error
      end

      it "does not raise error for integer" do
        expect { conditional.validate_value!(123) }.not_to raise_error
      end

      it "does not raise error for hash" do
        expect { conditional.validate_value!({ key: "value" }) }.not_to raise_error
      end

      it "does not raise error for array" do
        expect { conditional.validate_value!([1, 2, 3]) }.not_to raise_error
      end

      it "does not raise error for boolean" do
        expect { conditional.validate_value!(true) }.not_to raise_error
      end
    end
  end

  describe "#transform_value" do
    context "when called with any value" do
      it "returns nil unchanged" do
        result = conditional.transform_value(nil)
        expect(result).to be_nil
      end

      it "returns string unchanged" do
        result = conditional.transform_value("test")
        expect(result).to eq("test")
      end

      it "returns integer unchanged" do
        result = conditional.transform_value(123)
        expect(result).to eq(123)
      end

      it "returns hash unchanged" do
        hash = { key: "value" }
        result = conditional.transform_value(hash)
        expect(result).to eq(hash)
      end

      it "returns array unchanged" do
        array = [1, 2, 3]
        result = conditional.transform_value(array)
        expect(result).to eq(array)
      end

      it "returns boolean unchanged" do
        result = conditional.transform_value(true)
        expect(result).to be(true)
      end

      it "returns same object reference" do
        object = { complex: { nested: "data" } }
        result = conditional.transform_value(object)
        expect(result).to be(object)
      end
    end
  end
end
