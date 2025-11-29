# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Modifiers::CastModifier do
  subject(:modifier) do
    described_class.new(
      attribute_name: :test_attribute,
      attribute_type:,
      option_schema:
    )
  end

  describe "#value_key" do
    let(:attribute_type) { :string }
    let(:option_schema) { { to: :integer, message: nil } }

    it "returns :to instead of :is" do
      expect(modifier.send(:value_key)).to eq(:to)
    end
  end

  describe "#validate_schema!" do
    context "when cast target is a valid symbol" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: :integer, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "when cast target is not a Symbol" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: "integer", message: nil } }

      it "raises a validation error", :aggregate_failures do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to eq(
              "Option 'cast' for attribute 'test_attribute' must be a Symbol. Got: String"
            )
          end
        )
      end
    end

    context "when source type does not support casting (array)" do
      let(:attribute_type) { :array }
      let(:option_schema) { { to: :string, message: nil } }

      it "raises a validation error", :aggregate_failures do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("cannot be used with type 'array'")
            expect(exception.message).to include("integer, string, boolean, date, time, datetime")
          end
        )
      end
    end

    context "when source type does not support casting (object)" do
      let(:attribute_type) { :object }
      let(:option_schema) { { to: :string, message: nil } }

      it "raises a validation error", :aggregate_failures do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("cannot be used with type 'object'")
          end
        )
      end
    end

    context "when target type is not supported" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: :array, message: nil } }

      it "raises a validation error", :aggregate_failures do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("cannot cast to 'array'")
            expect(exception.message).to include("integer, string, boolean, date, time, datetime")
          end
        )
      end
    end

    context "when conversion is not supported (boolean to datetime)" do
      let(:attribute_type) { :boolean }
      let(:option_schema) { { to: :datetime, message: nil } }

      it "raises a validation error", :aggregate_failures do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("does not support conversion from 'boolean' to 'datetime'")
          end
        )
      end
    end
  end

  describe "#transform_value" do
    context "when value is nil" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: :integer, message: nil } }

      it "returns nil without casting" do
        result = modifier.transform_value(nil)
        expect(result).to be_nil
      end
    end

    # Integer conversions
    context "when casting integer to string" do
      let(:attribute_type) { :integer }
      let(:option_schema) { { to: :string, message: nil } }

      it "converts integer to string" do
        result = modifier.transform_value(42)
        expect(result).to eq("42")
      end
    end

    context "when casting integer to boolean" do
      let(:attribute_type) { :integer }
      let(:option_schema) { { to: :boolean, message: nil } }

      it "converts 0 to false" do
        result = modifier.transform_value(0)
        expect(result).to be(false)
      end

      it "converts non-zero to true" do
        result = modifier.transform_value(42)
        expect(result).to be(true)
      end

      it "converts negative number to true" do
        result = modifier.transform_value(-5)
        expect(result).to be(true)
      end
    end

    context "when casting integer to datetime" do
      let(:attribute_type) { :integer }
      let(:option_schema) { { to: :datetime, message: nil } }

      it "converts Unix timestamp to DateTime", :aggregate_failures do
        timestamp = 1_705_320_600 # 2024-01-15 10:30:00 UTC
        result = modifier.transform_value(timestamp)
        expect(result).to be_a(DateTime)
        expect(result.to_i).to eq(timestamp)
      end
    end

    context "when casting integer to integer (same type)" do
      let(:attribute_type) { :integer }
      let(:option_schema) { { to: :integer, message: nil } }

      it "returns the same value" do
        result = modifier.transform_value(42)
        expect(result).to eq(42)
      end
    end

    # String conversions
    context "when casting string to integer" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: :integer, message: nil } }

      it "converts valid string to integer" do
        result = modifier.transform_value("42")
        expect(result).to eq(42)
      end

      it "raises error for invalid string", :aggregate_failures do
        expect { modifier.transform_value("not a number") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("Cast failed for attribute 'test_attribute'")
            expect(exception.message).to include("from 'string' to 'integer'")
          end
        )
      end
    end

    context "when casting string to boolean" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: :boolean, message: nil } }

      it "converts 'true' to true" do
        expect(modifier.transform_value("true")).to be(true)
      end

      it "converts 'false' to false" do
        expect(modifier.transform_value("false")).to be(false)
      end

      it "converts '1' to true" do
        expect(modifier.transform_value("1")).to be(true)
      end

      it "converts '0' to false" do
        expect(modifier.transform_value("0")).to be(false)
      end

      it "converts 'yes' to true" do
        expect(modifier.transform_value("yes")).to be(true)
      end

      it "converts 'no' to false" do
        expect(modifier.transform_value("no")).to be(false)
      end

      it "converts 'on' to true" do
        expect(modifier.transform_value("on")).to be(true)
      end

      it "converts 'off' to false" do
        expect(modifier.transform_value("off")).to be(false)
      end

      it "is case-insensitive", :aggregate_failures do
        expect(modifier.transform_value("TRUE")).to be(true)
        expect(modifier.transform_value("False")).to be(false)
      end

      it "raises error for invalid boolean string", :aggregate_failures do
        expect { modifier.transform_value("maybe") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("Cast failed")
            expect(exception.message).to include("Cannot convert 'maybe' to boolean")
          end
        )
      end
    end

    context "when casting string to datetime" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: :datetime, message: nil } }

      it "converts ISO8601 string to DateTime" do
        result = modifier.transform_value("2024-01-15T10:30:00Z")
        expect(result).to be_a(DateTime)
      end

      it "converts RFC3339 string to DateTime" do
        result = modifier.transform_value("2024-01-15 10:30:00")
        expect(result).to be_a(DateTime)
      end

      it "raises error for invalid date string", :aggregate_failures do
        expect { modifier.transform_value("not a date") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("Cast failed")
          end
        )
      end
    end

    context "when casting string to string (same type)" do
      let(:attribute_type) { :string }
      let(:option_schema) { { to: :string, message: nil } }

      it "returns the same value" do
        result = modifier.transform_value("hello")
        expect(result).to eq("hello")
      end
    end

    # Boolean conversions
    context "when casting boolean to string" do
      let(:attribute_type) { :boolean }
      let(:option_schema) { { to: :string, message: nil } }

      it "converts true to 'true'" do
        result = modifier.transform_value(true)
        expect(result).to eq("true")
      end

      it "converts false to 'false'" do
        result = modifier.transform_value(false)
        expect(result).to eq("false")
      end
    end

    context "when casting boolean to integer" do
      let(:attribute_type) { :boolean }
      let(:option_schema) { { to: :integer, message: nil } }

      it "converts true to 1" do
        result = modifier.transform_value(true)
        expect(result).to eq(1)
      end

      it "converts false to 0" do
        result = modifier.transform_value(false)
        expect(result).to eq(0)
      end
    end

    context "when casting boolean to boolean (same type)" do
      let(:attribute_type) { :boolean }
      let(:option_schema) { { to: :boolean, message: nil } }

      it "returns the same value" do
        result = modifier.transform_value(true)
        expect(result).to be(true)
      end
    end

    # DateTime conversions
    context "when casting datetime to string" do
      let(:attribute_type) { :datetime }
      let(:option_schema) { { to: :string, message: nil } }

      it "converts DateTime to ISO8601 string", :aggregate_failures do
        datetime = DateTime.new(2024, 2, 21, 0, 0, 0)
        result = modifier.transform_value(datetime)
        expect(result).to be_a(String)
        expect(result).to include("2024-02-21")
      end

      it "converts Time to ISO8601 string", :aggregate_failures do
        time = Time.utc(2024, 2, 21, 0, 0, 0)
        result = modifier.transform_value(time)
        expect(result).to be_a(String)
        expect(result).to include("2024-02-21")
      end
    end

    context "when casting datetime to integer" do
      let(:attribute_type) { :datetime }
      let(:option_schema) { { to: :integer, message: nil } }

      it "converts DateTime to Unix timestamp", :aggregate_failures do
        datetime = Time.utc(2024, 2, 21, 0, 0, 0)
        result = modifier.transform_value(datetime)
        expect(result).to be_an(Integer)
        expect(result).to eq(datetime.to_i)
      end
    end

    context "when casting datetime to datetime (same type)" do
      let(:attribute_type) { :datetime }
      let(:option_schema) { { to: :datetime, message: nil } }

      it "returns the same value" do
        datetime = Time.current
        result = modifier.transform_value(datetime)
        expect(result).to eq(datetime)
      end
    end

    # Custom error messages
    context "when custom error message is provided" do
      let(:attribute_type) { :string }
      let(:option_schema) do
        {
          to: :integer,
          message: "Custom cast error message"
        }
      end

      it "uses the custom message when conversion fails" do
        expect { modifier.transform_value("not a number") }.to(
          raise_error(Treaty::Exceptions::Validation, "Custom cast error message")
        )
      end
    end
  end
end
