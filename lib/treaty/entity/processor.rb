# frozen_string_literal: true

module Treaty
  class Entity
    # Processor for Entity.call method.
    #
    # ## Purpose
    #
    # Coordinates the processing of data through the Entity validation and
    # transformation pipeline. Creates the appropriate orchestrator, runs
    # validation, and returns a Result object.
    #
    # ## Usage
    #
    # ```ruby
    # processor = Processor.new(UserEntity, Configuration.new(required: true))
    # result = processor.call(params)
    #
    # result.valid?  # => true/false
    # result.data    # => validated and transformed hash
    # result.errors  # => Errors collection
    # ```
    #
    # ## Architecture
    #
    # The Processor:
    # 1. Creates a dynamic orchestrator class with the Entity's collection_of_attributes
    # 2. Calls the orchestrator's validate! method
    # 3. Captures any validation errors
    # 4. Returns a Result object with data and/or errors
    #
    # ## Error Handling
    #
    # Validation errors are caught and added to the Result's errors collection.
    # The Result's data will be an empty hash if validation fails.
    class Processor
      # @return [Class<Entity>] The Entity class to process with
      attr_reader :entity_class

      # @return [Configuration] The configuration with default options
      attr_reader :configuration

      # Creates a new Processor instance.
      #
      # @param entity_class [Class<Entity>] The Entity class to process with
      # @param configuration [Configuration] Configuration with default options
      def initialize(entity_class, configuration = nil)
        @entity_class = entity_class
        @configuration = configuration || Configuration.new
      end

      # Processes data through the Entity's validation and transformation pipeline.
      #
      # @param data [Hash] The data to validate and transform
      # @return [Result] Result object with data and/or errors
      def call(data)
        result = Result.new

        begin
          validated_data = validate_and_transform!(data)
          result.data = validated_data
        rescue Treaty::Exceptions::Validation => e
          handle_validation_error(e, result)
        end

        result
      end

      # Processes data and raises exception on validation errors.
      #
      # @param data [Hash] The data to validate and transform
      # @return [Result] Result object with validated data
      # @raise [Treaty::Exceptions::Validation] If validation fails
      def call!(data)
        result = Result.new
        validated_data = validate_and_transform!(data)
        result.data = validated_data
        result
      end

      private

      # Validates and transforms data using the orchestrator.
      #
      # @param data [Hash] The data to validate and transform
      # @return [Hash] Validated and transformed data
      # @raise [Treaty::Exceptions::Validation] If validation fails
      def validate_and_transform!(data)
        orchestrator = build_orchestrator(data)
        orchestrator.validate!
      end

      # Builds an orchestrator instance for processing.
      #
      # @param data [Hash] The data to validate and transform
      # @return [Attribute::Validation::Orchestrator::Base] Orchestrator instance
      def build_orchestrator(data)
        entity = entity_class
        config = configuration

        orchestrator_class = Class.new(Attribute::Validation::Orchestrator::Base) do
          define_method(:collection_of_attributes) do
            entity.collection_of_attributes
          end

          define_method(:configuration) do
            config
          end
        end

        # Create orchestrator with nil version_factory (not needed for Entity processing)
        # Pass configuration for default options handling
        orchestrator_class.new(version_factory: nil, data: data, configuration: config)
      end

      # Handles validation errors by adding them to the result.
      #
      # @param error [Treaty::Exceptions::Validation] The validation error
      # @param result [Result] The result to add errors to
      # @return [void]
      def handle_validation_error(error, result)
        # Extract attribute path and message from the error
        # For now, add the full error message under a general key
        # TODO: Parse error message to extract attribute path
        result.errors.add(:base, error.message)
      end
    end
  end
end
