# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Modifiers::TransformModifier do
  subject(:modifier) do
    described_class.new(
      attribute_name: :test_attr,
      attribute_type: :string,
      option_schema:
    )
  end

  describe "#validate_schema!" do
    context "when transform is a lambda" do
      let(:option_schema) { { is: ->(value:) { value.upcase }, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "when transform is a Proc" do
      let(:option_schema) { { is: proc { |value:| value.upcase }, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "when transform is not a Proc" do
      let(:option_schema) { { is: "not a proc", message: nil } }

      it "raises a validation error", :aggregate_failures do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to eq(
              "Option 'transform' for attribute 'test_attr' must be a Proc or Lambda. Got: String"
            )
          end
        )
      end
    end
  end

  describe "#transform_value" do
    context "when lambda executes successfully" do
      let(:option_schema) { { is: ->(value:) { value.strip.upcase }, message: nil } }

      it "transforms the value" do
        result = modifier.transform_value("  hello world  ")
        expect(result).to eq("HELLO WORLD")
      end
    end

    context "when lambda raises an error" do
      let(:option_schema) { { is: ->(value:) { value.some_undefined_method }, message: nil } }

      it "catches the error and raises Treaty::Exceptions::Validation", :aggregate_failures do
        expect { modifier.transform_value("test") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("Transform failed for attribute 'test_attr'")
            expect(exception.message).to include("undefined method")
          end
        )
      end
    end

    context "when custom error message is provided" do
      let(:option_schema) do
        {
          is: ->(**) { raise StandardError, "Custom error" },
          message: "Custom transform error for test_attr"
        }
      end

      it "uses the custom message" do
        expect { modifier.transform_value("test") }.to(
          raise_error(Treaty::Exceptions::Validation, "Custom transform error for test_attr")
        )
      end
    end

    context "with advanced transformations" do
      let(:option_schema) { { is: ->(value:) { value * 100 }, message: nil } }

      it "applies numeric transformations" do
        result = modifier.transform_value(10)
        expect(result).to eq(1000)
      end
    end

    context "with chained string operations" do
      let(:option_schema) { { is: ->(value:) { value.strip.downcase.gsub(/\s+/, "_") }, message: nil } }

      it "applies multiple transformations" do
        result = modifier.transform_value("  Hello   World  ")
        expect(result).to eq("hello_world")
      end
    end
  end
end
