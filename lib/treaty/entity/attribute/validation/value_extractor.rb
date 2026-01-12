# frozen_string_literal: true

module Treaty
  module Entity
    module Attribute
      module Validation
        # Extracts values from Hash or PORO objects polymorphically.
        #
        # ## Purpose
        #
        # Provides unified interface for accessing attribute values from:
        # - Hash objects (using fetch with symbol keys)
        # - PORO objects (using public_send)
        #
        # ## Usage
        #
        #   ValueExtractor.extract({ name: "Alice" }, :name)  # => "Alice"
        #   ValueExtractor.extract(user_object, :name)        # => user_object.name
        #
        # ## Missing Values
        #
        # Returns nil when:
        # - Hash key doesn't exist
        # - PORO doesn't respond to the method
        # - Method is private (respond_to? returns false)
        #
        # RequiredValidator handles nil values appropriately.
        class ValueExtractor
          class << self
            # Extracts value from source by key
            #
            # @param source [Hash, Object] Source data (Hash or PORO)
            # @param key [Symbol] Attribute name to extract
            # @return [Object, nil] Extracted value or nil if not found
            def extract(source, key)
              case source
              when Hash
                source.fetch(key, nil)
              else
                source.respond_to?(key) ? source.public_send(key) : nil
              end
            end
          end
        end
      end
    end
  end
end
