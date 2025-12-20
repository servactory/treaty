# frozen_string_literal: true

module Treaty
  class Entity
    # Collection of validation errors for Entity processing.
    #
    # ## Purpose
    #
    # Provides a structured way to collect, access, and format validation errors
    # that occur during Entity processing. Supports both flat and nested error
    # structures for complex attribute hierarchies.
    #
    # ## Usage
    #
    # ```ruby
    # errors = Treaty::Entity::Errors.new
    # errors.add(:email, "is invalid")
    # errors.add(:email, "must be unique")
    # errors.add(:name, "is required")
    #
    # errors.any?            # => true
    # errors[:email]         # => ["is invalid", "must be unique"]
    # errors.full_messages   # => ["email: is invalid", "email: must be unique", "name: is required"]
    # errors.to_h            # => { email: ["is invalid", "must be unique"], name: ["is required"] }
    # ```
    #
    # ## Nested Errors
    #
    # Supports dot-notation paths for nested attributes:
    #
    # ```ruby
    # errors.add("user.address.city", "is required")
    # errors.full_messages   # => ["user.address.city: is required"]
    # errors.to_h            # => { user: { address: { city: ["is required"] } } }
    # ```
    #
    # ## Integration
    #
    # Used by Treaty::Entity::Result to hold validation errors:
    #
    # ```ruby
    # result = UserEntity.call(params)
    # if result.invalid?
    #   render json: { errors: result.errors.to_h }, status: 422
    # end
    # ```
    class Errors
      include Enumerable

      def initialize
        @messages = {}
      end

      # Adds an error message for the given attribute.
      #
      # @param attribute [Symbol, String] The attribute name or path (e.g., :email or "user.email")
      # @param message [String] The error message
      # @return [Array<String>] All messages for this attribute
      def add(attribute, message)
        key = attribute.to_s
        @messages[key] ||= []
        @messages[key] << message
        @messages[key]
      end

      # Returns error messages for the given attribute.
      #
      # @param attribute [Symbol, String] The attribute name or path
      # @return [Array<String>] Messages for this attribute, or empty array if none
      def [](attribute)
        @messages[attribute.to_s] || []
      end

      # Returns true if there are no errors.
      #
      # @return [Boolean]
      def empty?
        @messages.empty?
      end

      # Returns true if there are any errors.
      #
      # @return [Boolean]
      def any?
        !empty?
      end

      # Iterates over all attribute-message pairs.
      #
      # @yield [attribute, messages] Block to execute for each attribute
      # @yieldparam attribute [String] The attribute name or path
      # @yieldparam messages [Array<String>] The error messages
      def each(&block)
        @messages.each(&block)
      end

      # Returns all error messages formatted as "attribute: message".
      #
      # @return [Array<String>] Formatted error messages
      def full_messages
        result = []
        @messages.each do |attribute, messages|
          messages.each do |message|
            result << "#{attribute}: #{message}"
          end
        end
        result
      end

      # Returns errors as a nested hash structure.
      #
      # For flat attributes: `{ email: ["is invalid"] }`
      # For nested paths: `{ user: { email: ["is invalid"] } }`
      #
      # @return [Hash] Nested hash of errors
      def to_h
        result = {}

        @messages.each do |path, messages|
          keys = path.to_s.split(".")
          current = result

          keys[0...-1].each do |key|
            key_sym = key.to_sym
            current[key_sym] ||= {}
            current = current[key_sym]
          end

          last_key = keys.last.to_sym
          current[last_key] = messages.dup
        end

        result
      end

      # Returns errors as an array of hashes with attribute and messages.
      #
      # @return [Array<Hash>] Array of `{ attribute:, messages: }` hashes
      def to_a
        @messages.map do |attribute, messages|
          { attribute: attribute, messages: messages.dup }
        end
      end

      # Returns the total number of error messages.
      #
      # @return [Integer]
      def size
        @messages.values.sum(&:size)
      end

      alias count size
      alias length size

      # Clears all error messages.
      #
      # @return [self]
      def clear
        @messages.clear
        self
      end

      # Returns a human-readable representation.
      #
      # @return [String]
      def inspect
        "#<#{self.class.name} @messages=#{@messages.inspect}>"
      end

      # Merges errors from another Errors instance.
      #
      # @param other [Errors] Another errors collection
      # @param prefix [String, nil] Optional prefix to add to attribute paths
      # @return [self]
      def merge(other, prefix: nil)
        other.each do |attribute, messages|
          key = prefix ? "#{prefix}.#{attribute}" : attribute
          messages.each { |msg| add(key, msg) }
        end
        self
      end
    end
  end
end
