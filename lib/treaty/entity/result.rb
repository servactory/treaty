# frozen_string_literal: true

module Treaty
  class Entity
    # Result object returned by Entity.call method.
    #
    # ## Purpose
    #
    # Encapsulates the result of Entity processing, providing access to
    # validated/transformed data and any validation errors that occurred.
    # Similar to Treaty::Result but focused on Entity-level processing.
    #
    # ## Usage
    #
    # ```ruby
    # result = UserEntity.call(params)
    #
    # if result.valid?
    #   user = User.create!(result.data)
    # else
    #   render json: { errors: result.errors.to_h }, status: 422
    # end
    # ```
    #
    # ## Accessing Data
    #
    # ```ruby
    # result = UserEntity.call(params)
    #
    # result.data                  # => { user: { name: "John", email: "john@example.com" } }
    # result.to_h                  # => same as data (alias)
    # result[:user]                # => { name: "John", email: "john@example.com" }
    # result[:user][:name]         # => "John"
    # ```
    #
    # ## Error Handling
    #
    # ```ruby
    # result = UserEntity.call(invalid_params)
    #
    # result.valid?                # => false
    # result.invalid?              # => true
    # result.errors                # => Treaty::Entity::Errors instance
    # result.errors.full_messages  # => ["user.email: is invalid"]
    # result.errors.to_h           # => { user: { email: ["is invalid"] } }
    # ```
    class Result
      # @return [Hash] The processed data (empty hash if validation failed)
      attr_accessor :data

      # @return [Errors] Collection of validation errors
      attr_reader :errors

      # Creates a new Result instance.
      #
      # @param data [Hash] Processed data (default: {})
      # @param errors [Errors] Errors collection (default: new Errors)
      def initialize(data: {}, errors: nil)
        @data = data
        @errors = errors || Errors.new
      end

      # Returns true if there are no validation errors.
      #
      # @return [Boolean]
      def valid?
        @errors.empty?
      end

      # Returns true if there are validation errors.
      #
      # @return [Boolean]
      def invalid?
        !valid?
      end

      # Returns the processed data as a Hash.
      # Alias for #data method.
      #
      # @return [Hash]
      def to_h
        @data
      end

      # Provides hash-like access to the data.
      #
      # @param key [Symbol, String] The key to access
      # @return [Object, nil] The value at the given key
      def [](key)
        @data[key]
      end

      # Returns a human-readable representation.
      #
      # @return [String]
      def inspect
        "#<#{self.class.name} @valid=#{valid?} @data=#{@data.inspect} @errors=#{@errors.inspect}>"
      end

      # Sets the processed data.
      # Used internally by Processor.
      #
      # @param value [Hash] The processed data
      # @return [Hash]
      # @api private
    end
  end
end
