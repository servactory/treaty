# frozen_string_literal: true

module Treaty
  module Attribute
    # DSL module for defining attributes in Entity-like classes.
    #
    # This module provides the class-level DSL for defining attributes.
    # It can be included in any class that needs attribute definition capabilities.
    #
    # ## Usage
    #
    # ```ruby
    # class MyEntity
    #   include Treaty::Attribute::DSL
    #
    #   string :name
    #   integer :age
    # end
    # ```
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Defines an attribute with explicit type
        #
        # @param name [Symbol] The attribute name
        # @param type [Symbol] The attribute type
        # @param helpers [Array<Symbol>] Helper symbols (:required, :optional)
        # @param options [Hash] Attribute options
        # @param block [Proc] Block for nested attributes
        # @return [void]
        def attribute(name, type, *helpers, **options, &block)
          collection_of_attributes << create_attribute(
            name,
            type,
            *helpers,
            nesting_level: 0,
            **options,
            &block
          )
        end

        # Returns collection of attributes for this class
        #
        # @return [Collection] Collection of attributes
        def collection_of_attributes
          @collection_of_attributes ||= Treaty::Attribute::Collection.new
        end

        # Handles DSL methods like `string :name` where method name is the type
        #
        # @param type [Symbol] The attribute type (method name)
        # @param name [Symbol] The attribute name (first argument)
        # @param helpers [Array<Symbol>] Helper symbols
        # @param options [Hash] Attribute options
        # @param block [Proc] Block for nested attributes
        # @return [void]
        def method_missing(type, *helpers, **options, &block)
          name = helpers.shift

          # If no attribute name provided, this is not an attribute definition
          # Pass to super to handle it properly (e.g., for methods like 'info', 'call!', etc.)
          return super if name.nil?

          attribute(name, type, *helpers, **options, &block)
        end

        def respond_to_missing?(name, *)
          super
        end

        private

        # Creates an attribute instance (must be implemented by including class)
        #
        # @raise [Treaty::Exceptions::NotImplemented] If not implemented
        # @return [Attribute::Base] Created attribute instance
        def create_attribute(*)
          raise Treaty::Exceptions::NotImplemented,
                I18n.t(
                  "treaty.attributes.dsl.create_attribute_not_implemented",
                  class: self
                )
        end
      end
    end
  end
end
