# frozen_string_literal: true

RSpec.describe Treaty::Entity::Context do
  # Test Entity class for specs
  let(:simple_entity) do
    Class.new(Treaty::Entity) do
      string :title
      string :content
    end
  end

  let(:entity_with_explicit) do
    Class.new(Treaty::Entity) do
      string :name
      string :bio, :optional # Explicitly optional
      integer :age, default: 0 # Explicit default
    end
  end

  describe "#initialize" do
    it "accepts entity class and options" do
      context = described_class.new(simple_entity, required: false)

      expect(context.entity_class).to eq(simple_entity)
    end

    it "accepts empty options" do
      context = described_class.new(simple_entity)

      expect(context.entity_class).to eq(simple_entity)
    end

    it "normalizes options through OptionNormalizer" do
      context = described_class.new(simple_entity, required: false)

      expect(context.any?).to be true
    end
  end

  describe "#call" do
    context "without options" do
      it "validates with default required: true", :aggregate_failures do
        context = described_class.new(simple_entity)
        result = context.call({ title: "Test" })

        expect(result).not_to be_valid
        expect(result.errors).not_to be_empty
      end
    end

    context "with required: false" do
      it "allows missing required fields", :aggregate_failures do
        context = described_class.new(simple_entity, required: false)
        result = context.call({ title: "Test" })

        expect(result).to be_valid
        expect(result.data).to eq(title: "Test", content: nil)
      end

      it "allows completely empty data", :aggregate_failures do
        context = described_class.new(simple_entity, required: false)
        result = context.call({})

        expect(result).to be_valid
        expect(result.data).to eq(title: nil, content: nil)
      end
    end

    context "with explicit attribute options" do
      it "does not override explicitly optional attributes", :aggregate_failures do
        context = described_class.new(entity_with_explicit)
        result = context.call({ name: "John", age: 25 })

        # :bio is explicitly optional, so should be valid without it
        expect(result).to be_valid
        expect(result.data[:bio]).to be_nil
      end

      it "does not override explicit default values" do
        context = described_class.new(entity_with_explicit, required: false)
        result = context.call({ name: "John" })

        # :age has explicit default: 0, should keep that
        expect(result.data[:age]).to eq(0)
      end
    end
  end

  describe "#call!" do
    context "with valid data" do
      it "returns Result object" do
        context = described_class.new(simple_entity)
        result = context.call!({ title: "Test", content: "Content" })

        expect(result).to be_a(Treaty::Entity::Result)
      end
    end

    context "with invalid data" do
      it "raises Treaty::Exceptions::Validation" do
        context = described_class.new(simple_entity)

        expect do
          context.call!({ title: "Test" })
        end.to raise_error(Treaty::Exceptions::Validation)
      end
    end

    context "with required: false" do
      it "allows missing fields" do
        context = described_class.new(simple_entity, required: false)
        result = context.call!({ title: "Test" })

        expect(result).to be_valid
      end
    end
  end

  describe "#valid?" do
    context "with valid data" do
      it "returns true" do
        context = described_class.new(simple_entity)
        result = context.valid?({ title: "Test", content: "Content" })

        expect(result).to be true
      end
    end

    context "with invalid data" do
      it "returns false" do
        context = described_class.new(simple_entity)
        result = context.valid?({ title: "Test" })

        expect(result).to be false
      end
    end

    context "with required: false" do
      it "returns true for partial data" do
        context = described_class.new(simple_entity, required: false)
        result = context.valid?({ title: "Test" })

        expect(result).to be true
      end
    end
  end

  describe "#any?" do
    it "returns false for empty options" do
      context = described_class.new(simple_entity)

      expect(context.any?).to be false
    end

    it "returns true for non-empty options" do
      context = described_class.new(simple_entity, required: false)

      expect(context.any?).to be true
    end
  end

  describe "#merge_with" do
    it "returns attribute options unchanged when no context options" do
      context = described_class.new(simple_entity)
      attribute_options = { required: { is: true, message: nil } }
      explicit_options = Set.new([:required])

      result = context.merge_with(attribute_options, explicit_options)

      expect(result).to eq(attribute_options)
    end

    it "does not override explicit attribute options" do
      context = described_class.new(simple_entity, required: false)
      attribute_options = { required: { is: true, message: nil } }
      explicit_options = Set.new([:required])

      result = context.merge_with(attribute_options, explicit_options)

      # Explicit required: true should be preserved
      expect(result[:required][:is]).to be(true)
    end

    it "overrides non-explicit attribute options" do
      context = described_class.new(simple_entity, required: false)
      attribute_options = { required: { is: true, message: nil } }
      explicit_options = Set.new # Empty - required was not explicit

      result = context.merge_with(attribute_options, explicit_options)

      # Non-explicit required should be overridden to false
      expect(result[:required][:is]).to be(false)
    end

    it "adds new options from context" do
      context = described_class.new(simple_entity, required: false)
      attribute_options = {}
      explicit_options = Set.new

      result = context.merge_with(attribute_options, explicit_options)

      # Should add required: false from context
      expect(result[:required][:is]).to be(false)
    end
  end

  describe "#to_h" do
    it "returns copy of options hash", :aggregate_failures do
      context = described_class.new(simple_entity, required: false)
      hash = context.to_h

      expect(hash).to be_a(Hash)
      expect(hash).to have_key(:required)
    end
  end

  describe "#inspect" do
    it "returns readable representation", :aggregate_failures do
      context = described_class.new(simple_entity, required: false)

      expect(context.inspect).to include("Context")
      expect(context.inspect).to include("required")
    end
  end
end
