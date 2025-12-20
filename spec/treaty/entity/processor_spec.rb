# frozen_string_literal: true

RSpec.describe Treaty::Entity::Processor do
  # Test Entity for specs
  let(:test_entity) do
    Class.new(Treaty::Entity) do
      object :user do
        string :name
        string :email, format: :email
        integer :age, :optional
      end
    end
  end

  let(:simple_entity) do
    Class.new(Treaty::Entity) do
      string :title
      string :content
    end
  end

  describe "#initialize" do
    it "accepts entity class and configuration" do
      config = Treaty::Entity::Configuration.new(required: true)
      processor = described_class.new(test_entity, config)

      expect(processor.entity_class).to eq(test_entity)
      expect(processor.configuration).to eq(config)
    end

    it "creates default configuration if not provided" do
      processor = described_class.new(test_entity)

      expect(processor.configuration).to be_a(Treaty::Entity::Configuration)
    end
  end

  describe "#call" do
    let(:configuration) { Treaty::Entity::Configuration.new }
    let(:processor) { described_class.new(test_entity, configuration) }

    context "with valid data" do
      let(:valid_data) { { user: { name: "John", email: "john@test.com" } } }

      it "returns Result object" do
        result = processor.call(valid_data)

        expect(result).to be_a(Treaty::Entity::Result)
      end

      it "returns valid result" do
        result = processor.call(valid_data)

        expect(result).to be_valid
      end

      it "includes processed data" do
        result = processor.call(valid_data)

        expect(result.data[:user][:name]).to eq("John")
        expect(result.data[:user][:email]).to eq("john@test.com")
      end

      it "includes optional fields with nil" do
        result = processor.call(valid_data)

        expect(result.data[:user]).to have_key(:age)
        expect(result.data[:user][:age]).to be_nil
      end
    end

    context "with invalid data" do
      let(:invalid_data) { { user: { email: "john@test.com" } } }

      it "returns invalid result" do
        result = processor.call(invalid_data)

        expect(result).to be_invalid
      end

      it "includes errors" do
        result = processor.call(invalid_data)

        expect(result.errors).not_to be_empty
      end

      it "returns empty data" do
        result = processor.call(invalid_data)

        expect(result.data).to eq({})
      end
    end

    context "with required: false configuration" do
      let(:config) { Treaty::Entity::Configuration.new(required: false) }
      let(:processor) { described_class.new(simple_entity, config) }

      it "allows missing required fields" do
        result = processor.call({ title: "Hello" })

        expect(result).to be_valid
      end

      it "includes missing fields as nil" do
        result = processor.call({ title: "Hello" })

        expect(result.data).to eq(title: "Hello", content: nil)
      end
    end
  end

  describe "#call!" do
    let(:configuration) { Treaty::Entity::Configuration.new }
    let(:processor) { described_class.new(test_entity, configuration) }

    context "with valid data" do
      let(:valid_data) { { user: { name: "John", email: "john@test.com" } } }

      it "returns Result object" do
        result = processor.call!(valid_data)

        expect(result).to be_a(Treaty::Entity::Result)
      end

      it "returns valid result" do
        result = processor.call!(valid_data)

        expect(result).to be_valid
      end
    end

    context "with invalid data" do
      let(:invalid_data) { { user: { email: "john@test.com" } } }

      it "raises Treaty::Exceptions::Validation" do
        expect do
          processor.call!(invalid_data)
        end.to raise_error(Treaty::Exceptions::Validation)
      end

      it "includes error message in exception" do
        expect do
          processor.call!(invalid_data)
        end.to raise_error(Treaty::Exceptions::Validation, /name/)
      end
    end
  end
end
