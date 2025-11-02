# frozen_string_literal: true

RSpec.describe Treaty::Attribute::OptionNormalizer do
  describe ".normalize" do
    context "with standard options using :is key" do
      context "when options are in simple mode" do
        it "normalizes required option" do
          result = described_class.normalize(required: true)

          expect(result).to eq(required: { is: true, message: nil })
        end

        it "normalizes as option" do
          result = described_class.normalize(as: :value)

          expect(result).to eq(as: { is: :value, message: nil })
        end

        it "normalizes multiple standard options" do
          result = described_class.normalize(required: true, as: :value)

          expect(result).to eq(
            required: { is: true, message: nil },
            as: { is: :value, message: nil }
          )
        end
      end

      context "when options are in advanced mode" do
        it "preserves advanced mode format for required" do
          result = described_class.normalize(
            required: { is: true, message: "Required field" }
          )

          expect(result).to eq(
            required: { is: true, message: "Required field" }
          )
        end

        it "preserves advanced mode format for as" do
          result = described_class.normalize(
            as: { is: :value, message: "Invalid format" }
          )

          expect(result).to eq(
            as: { is: :value, message: "Invalid format" }
          )
        end

        it "handles missing message key" do
          result = described_class.normalize(
            required: { is: true }
          )

          expect(result).to eq(
            required: { is: true, message: nil }
          )
        end
      end
    end

    context "with inclusion option using :in key" do
      context "when option is in simple mode" do
        it "normalizes in option to inclusion with in key" do
          values = %w[twitter linkedin github]
          result = described_class.normalize(in: values)

          expect(result).to eq(
            inclusion: { in: values, message: nil }
          )
        end

        it "normalizes in option with array of symbols" do
          values = %i[active inactive pending]
          result = described_class.normalize(in: values)

          expect(result).to eq(
            inclusion: { in: values, message: nil }
          )
        end

        it "normalizes in option with range" do
          range = 1..10
          result = described_class.normalize(in: range)

          expect(result).to eq(
            inclusion: { in: range, message: nil }
          )
        end
      end

      context "when option is in advanced mode" do
        it "preserves advanced mode format for inclusion" do
          values = %w[twitter linkedin github]
          result = described_class.normalize(
            inclusion: { in: values, message: "Must be a valid provider" }
          )

          expect(result).to eq(
            inclusion: { in: values, message: "Must be a valid provider" }
          )
        end

        it "handles missing message key in advanced mode" do
          values = %w[twitter linkedin github]
          result = described_class.normalize(
            inclusion: { in: values }
          )

          expect(result).to eq(
            inclusion: { in: values, message: nil }
          )
        end
      end
    end

    context "with mixed options" do
      it "normalizes both standard and inclusion options in simple mode" do
        result = described_class.normalize(
          required: true,
          as: :value,
          in: %w[twitter linkedin github]
        )

        expect(result).to eq(
          required: { is: true, message: nil },
          as: { is: :value, message: nil },
          inclusion: { in: %w[twitter linkedin github], message: nil }
        )
      end

      it "normalizes mixed simple and advanced mode options" do
        result = described_class.normalize(
          required: { is: true, message: "Required" },
          as: :value,
          in: %w[twitter linkedin github]
        )

        expect(result).to eq(
          required: { is: true, message: "Required" },
          as: { is: :value, message: nil },
          inclusion: { in: %w[twitter linkedin github], message: nil }
        )
      end

      it "handles all options in advanced mode" do
        result = described_class.normalize(
          required: { is: true, message: "Required" },
          as: { is: :value, message: "Invalid" },
          inclusion: { in: %w[twitter linkedin github], message: "Invalid provider" }
        )

        expect(result).to eq(
          required: { is: true, message: "Required" },
          as: { is: :value, message: "Invalid" },
          inclusion: { in: %w[twitter linkedin github], message: "Invalid provider" }
        )
      end
    end

    describe "edge cases" do
      it "handles empty hash" do
        result = described_class.normalize({})

        expect(result).to eq({})
      end

      it "handles nil values" do
        result = described_class.normalize(required: nil)

        expect(result).to eq(required: { is: nil, message: nil })
      end

      it "handles false values" do
        result = described_class.normalize(required: false)

        expect(result).to eq(required: { is: false, message: nil })
      end

      it "handles empty array for inclusion" do
        result = described_class.normalize(in: [])

        expect(result).to eq(inclusion: { in: [], message: nil })
      end
    end
  end
end
