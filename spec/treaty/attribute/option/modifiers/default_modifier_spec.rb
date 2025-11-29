# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Modifiers::DefaultModifier do
  subject(:modifier) do
    described_class.new(
      attribute_name: :limit,
      attribute_type: :integer,
      option_schema:
    )
  end

  describe "#validate_schema!" do
    context "with static integer value" do
      let(:option_schema) { { is: 12, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "with static string value" do
      let(:option_schema) { { is: "pending", message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "with Proc value" do
      let(:option_schema) { { is: -> { 42 }, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "with nil value" do
      let(:option_schema) { { is: nil, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end
  end

  describe "#transform_value" do
    context "when value is nil" do
      context "with static integer default" do
        let(:option_schema) { { is: 12, message: nil } }

        it "returns the default value" do
          result = modifier.transform_value(nil)
          expect(result).to eq(12)
        end
      end

      context "with static string default" do
        let(:option_schema) { { is: "pending", message: nil } }

        it "returns the default value" do
          result = modifier.transform_value(nil)
          expect(result).to eq("pending")
        end
      end

      context "with static boolean default (false)" do
        let(:option_schema) { { is: false, message: nil } }

        it "returns the default value" do
          result = modifier.transform_value(nil)
          expect(result).to be false
        end
      end

      context "with static boolean default (true)" do
        let(:option_schema) { { is: true, message: nil } }

        it "returns the default value" do
          result = modifier.transform_value(nil)
          expect(result).to be true
        end
      end

      context "with Proc default" do
        let(:option_schema) { { is: -> { 42 }, message: nil } }

        it "calls the Proc and returns its value" do
          result = modifier.transform_value(nil)
          expect(result).to eq(42)
        end
      end

      context "with Proc that generates dynamic value" do
        let(:time) { Time.new(2025, 2, 21, 0, 0, 0) }
        let(:option_schema) { { is: -> { time }, message: nil } }

        it "calls the Proc and returns dynamic value" do
          result = modifier.transform_value(nil)
          expect(result).to eq(time)
        end
      end
    end

    context "when value is not nil" do
      let(:option_schema) { { is: 12, message: nil } }

      context "with integer value" do
        it "returns the original value" do
          result = modifier.transform_value(5)
          expect(result).to eq(5)
        end
      end

      context "with string value" do
        it "returns the original value" do
          result = modifier.transform_value("custom")
          expect(result).to eq("custom")
        end
      end

      context "with empty string" do
        it "returns the empty string (not replaced)" do
          result = modifier.transform_value("")
          expect(result).to eq("")
        end
      end

      context "with empty array" do
        it "returns the empty array (not replaced)" do
          result = modifier.transform_value([])
          expect(result).to eq([])
        end
      end

      context "with empty hash" do
        it "returns the empty hash (not replaced)" do
          result = modifier.transform_value({})
          expect(result).to eq({})
        end
      end

      context "with false value" do
        it "returns false (not replaced)" do
          result = modifier.transform_value(false)
          expect(result).to be false
        end
      end

      context "with zero value" do
        it "returns zero (not replaced)" do
          result = modifier.transform_value(0)
          expect(result).to eq(0)
        end
      end
    end

    describe "edge cases" do
      context "when default is nil and value is nil" do
        let(:option_schema) { { is: nil, message: nil } }

        it "returns nil" do
          result = modifier.transform_value(nil)
          expect(result).to be_nil
        end
      end

      context "when Proc default returns nil" do
        let(:option_schema) { { is: -> {}, message: nil } }

        it "returns nil from Proc" do
          result = modifier.transform_value(nil)
          expect(result).to be_nil
        end
      end

      context "when Proc default is called multiple times" do
        let(:counter) { [0] }
        let(:option_schema) { { is: -> { counter[0] += 1 }, message: nil } }

        it "executes the Proc each time", :aggregate_failures do
          expect(modifier.transform_value(nil)).to eq(1)
          expect(modifier.transform_value(nil)).to eq(2)
          expect(modifier.transform_value(nil)).to eq(3)
        end
      end
    end
  end
end
