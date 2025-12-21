# frozen_string_literal: true

RSpec.describe Treaty::Entity do
  # Test Entity class for specs
  let(:user_entity) do
    Class.new(described_class) do
      object :user do
        string :name
        string :email, format: :email
        integer :age, :optional
      end
    end
  end

  let(:simple_entity) do
    Class.new(described_class) do
      string :title
      string :content
    end
  end

  describe ".call" do
    context "with valid data" do
      let(:valid_data) { { user: { name: "John", email: "john@test.com" } } }

      it "returns a Result object" do
        result = user_entity.call(valid_data)

        expect(result).to be_a(Treaty::Entity::Result)
      end

      it "returns valid result", :aggregate_failures do
        result = user_entity.call(valid_data)

        expect(result).to be_valid
        expect(result).not_to be_invalid
      end

      it "returns processed data" do
        result = user_entity.call(valid_data)

        # Optional attributes are included with nil value
        expect(result.data).to eq(user: { name: "John", email: "john@test.com", age: nil })
      end

      it "returns data via to_h" do
        result = user_entity.call(valid_data)

        # Optional attributes are included with nil value
        expect(result.to_h).to eq(user: { name: "John", email: "john@test.com", age: nil })
      end

      it "has no errors" do
        result = user_entity.call(valid_data)

        expect(result.errors).to be_empty
      end

      it "processes optional attributes when provided" do
        data = { user: { name: "John", email: "john@test.com", age: 30 } }
        result = user_entity.call(data)

        expect(result.data).to eq(user: { name: "John", email: "john@test.com", age: 30 })
      end
    end

    context "with invalid data" do
      it "returns invalid result when required field is missing", :aggregate_failures do
        data = { user: { email: "john@test.com" } }
        result = user_entity.call(data)

        expect(result).not_to be_valid
        expect(result).not_to be_valid
      end

      it "has errors when validation fails" do
        data = { user: { email: "john@test.com" } }
        result = user_entity.call(data)

        expect(result.errors).not_to be_empty
      end

      it "returns empty data when validation fails" do
        data = { user: { email: "john@test.com" } }
        result = user_entity.call(data)

        expect(result.data).to eq({})
      end

      it "returns invalid result when format validation fails" do
        data = { user: { name: "John", email: "invalid-email" } }
        result = user_entity.call(data)

        expect(result).not_to be_valid
      end
    end

    context "with required: false option via .preset()" do
      it "treats missing required fields as optional", :aggregate_failures do
        data = { title: "Hello" }
        result = simple_entity.preset(required: false).call(data)

        expect(result).to be_valid
        # Missing fields are included with nil value
        expect(result.data).to eq(title: "Hello", content: nil)
      end
    end
  end

  describe ".call!" do
    context "with valid data" do
      let(:valid_data) { { user: { name: "John", email: "john@test.com" } } }

      it "returns a Result object" do
        result = user_entity.call!(valid_data)

        expect(result).to be_a(Treaty::Entity::Result)
      end

      it "returns processed data" do
        result = user_entity.call!(valid_data)

        # Optional attributes are included with nil value
        expect(result.data).to eq(user: { name: "John", email: "john@test.com", age: nil })
      end
    end

    context "with invalid data" do
      it "raises Treaty::Exceptions::Validation" do
        data = { user: { email: "john@test.com" } }

        expect do
          user_entity.call!(data)
        end.to raise_error(Treaty::Exceptions::Validation)
      end
    end
  end

  describe ".valid?" do
    context "with valid data" do
      it "returns true" do
        data = { user: { name: "John", email: "john@test.com" } }
        result = user_entity.valid?(data)

        expect(result).to be true
      end
    end

    context "with invalid data" do
      it "returns false when required field is missing" do
        data = { user: { email: "john@test.com" } }
        result = user_entity.valid?(data)

        expect(result).to be false
      end

      it "returns false when format validation fails" do
        data = { user: { name: "John", email: "invalid" } }
        result = user_entity.valid?(data)

        expect(result).to be false
      end
    end

    context "with required: false option via .preset()" do
      it "returns true for partial data" do
        data = { title: "Hello" }
        result = simple_entity.preset(required: false).valid?(data)

        expect(result).to be true
      end
    end
  end

  describe ".from_block" do
    it "creates anonymous Entity class" do
      entity_class = described_class.from_block do
        string :name
      end

      expect(entity_class).to be < described_class
    end

    it "anonymous Entity can validate data", :aggregate_failures do
      entity_class = described_class.from_block do
        string :name
      end

      data = { name: "John" }
      result = entity_class.call(data)

      expect(result).to be_valid
      expect(result.data).to eq(name: "John")
    end

    it "works with .preset() for inline entities" do
      entity_class = described_class.from_block do
        string :name
      end

      # Use .preset() method for validation options
      result = entity_class.preset(required: false).call({})
      expect(result).to be_valid
    end

    it "works with nested structures", :aggregate_failures do
      entity_class = described_class.from_block do
        object :user do
          string :name
        end
      end

      data = { user: { name: "John" } }
      result = entity_class.call(data)

      expect(result).to be_valid
      expect(result.data).to eq(user: { name: "John" })
    end
  end

  describe ".preset" do
    it "returns a Preset instance" do
      preset = user_entity.preset(required: false)

      expect(preset).to be_a(Treaty::Entity::Context::Preset)
    end

    it "Preset can call, call!, and valid?", :aggregate_failures do
      preset = simple_entity.preset(required: false)

      expect(preset).to respond_to(:call)
      expect(preset).to respond_to(:call!)
      expect(preset).to respond_to(:valid?)
    end

    it "Preset.call works correctly", :aggregate_failures do
      result = simple_entity.preset(required: false).call({ title: "Test" })

      expect(result).to be_valid
      expect(result.data).to eq(title: "Test", content: nil)
    end

    it "Preset.call! works correctly", :aggregate_failures do
      result = simple_entity.preset(required: false).call!({ title: "Test" })

      expect(result).to be_valid
      expect(result.data).to eq(title: "Test", content: nil)
    end

    it "Preset.valid? works correctly" do
      result = simple_entity.preset(required: false).valid?({ title: "Test" })

      expect(result).to be true
    end

    it "allows multiple options" do
      preset = simple_entity.preset(required: false)

      result = preset.call({})

      expect(result).to be_valid
    end

    it "preset can be reused", :aggregate_failures do
      preset = simple_entity.preset(required: false)

      result1 = preset.call({ title: "First" })
      result2 = preset.call({ content: "Second" })

      expect(result1).to be_valid
      expect(result2).to be_valid
    end

    it "explicit attribute options take precedence over preset", :aggregate_failures do
      entity_with_explicit = Class.new(described_class) do
        string :title
        string :content, :optional # Explicitly optional
      end

      # Even with required: true in preset, :content stays optional
      result = entity_with_explicit.call({ title: "Test" })
      expect(result).to be_valid

      # And with required: false, :title can be missing
      result = entity_with_explicit.preset(required: false).call({ content: "Only content" })
      expect(result).to be_valid
    end
  end

  describe "hash-like access on Result" do
    it "provides [] accessor for data", :aggregate_failures do
      data = { user: { name: "John", email: "john@test.com" } }
      result = user_entity.call(data)

      # Optional attributes are included with nil value
      expect(result[:user]).to eq(name: "John", email: "john@test.com", age: nil)
      expect(result[:user][:name]).to eq("John")
    end
  end
end
