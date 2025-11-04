# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      module Orchestrator
        class Base # rubocop:disable Metrics/ClassLength
          SELF_SCOPE = :_self
          private_constant :SELF_SCOPE

          attr_reader :version_factory, :data

          def self.validate!(...)
            new(...).validate!
          end

          def initialize(version_factory:, data: {})
            @version_factory = version_factory
            @data = data
          end

          def validate!
            transformed_data = {}

            collection_of_scopes.each do |scope_factory|
              transformed_scope_data = validate_and_transform_scope!(scope_factory)
              transformed_data[scope_factory.name] = transformed_scope_data if scope_factory.name != SELF_SCOPE
              transformed_data.merge!(transformed_scope_data) if scope_factory.name == SELF_SCOPE
            end

            transformed_data
          end

          private

          def collection_of_scopes
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Subclass must implement the collection_of_scopes method"
          end

          def validate_scope!(scope_factory)
            scope_data = scope_data_for(scope_factory.name)

            validators_for_scope(scope_factory).each do |attribute, validator|
              value = scope_data.fetch(attribute.name, nil)
              validator.validate_value!(value)
            end
          end

          def validators_for_scope(scope_factory)
            @validators_cache ||= {}
            @validators_cache[scope_factory] ||= build_validators_for_scope(scope_factory)
          end

          def build_validators_for_scope(scope_factory)
            scope_factory.collection_of_attributes.each_with_object({}) do |attribute, cache|
              validator = AttributeValidator.new(attribute)
              validator.validate_schema!
              cache[attribute] = validator
            end
          end

          def scope_data_for(_name)
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Subclass must implement the scope_data_for method"
          end

          def validate_and_transform_scope!(scope_factory) # rubocop:disable Metrics/MethodLength
            scope_data = scope_data_for(scope_factory.name)

            return scope_data if scope_factory.collection_of_attributes.empty?

            transformed_scope_data = {}

            validators_for_scope(scope_factory).each do |attribute, validator|
              source_name = attribute.name
              value = scope_data.fetch(source_name, nil)

              if attribute.nested?
                transformed_value = validate_and_transform_nested(attribute, value, validator)
              else
                validator.validate_value!(value)
                transformed_value = value
              end

              target_name = fetch_target_name(attribute)

              transformed_scope_data[target_name] = transformed_value
            end

            transformed_scope_data
          end

          def validate_and_transform_nested(attribute, value, validator)
            validator.type_validator.validate_value!(value) unless value.nil?
            validator.required_validator.validate_value!(value) if attribute.options.key?(:required)

            transform_attribute_value(attribute, value)
          end

          def fetch_target_name(attribute)
            return attribute.options.dig(:as, :is) if attribute.options.dig(:as, :is)
            return attribute.options[:as] if attribute.options[:as].is_a?(Symbol)

            attribute.name
          end

          def transform_attribute_value(attribute, value)
            return value if value.nil?

            case attribute.type
            when :object
              transform_object_value(attribute, value)
            when :array
              transform_array_value(attribute, value)
            else
              value
            end
          end

          def transform_object_value(attribute, value) # rubocop:disable Metrics/MethodLength
            return value unless attribute.nested?

            transformed_object = {}

            attribute.collection_of_attributes.each do |nested_attribute|
              source_name = nested_attribute.name
              nested_value = value.fetch(source_name, nil)

              validator = Validation::AttributeValidator.new(nested_attribute)
              validator.validate_schema!

              if nested_attribute.nested?
                transformed_nested_value = validate_and_transform_nested(nested_attribute, nested_value, validator)
              else
                validator.validate_value!(nested_value)
                transformed_nested_value = nested_value
              end

              target_name = fetch_target_name(nested_attribute)
              transformed_object[target_name] = transformed_nested_value
            end

            transformed_object
          end

          def transform_array_value(attribute, value)
            return value unless attribute.nested?

            value.each_with_index.map do |item, index|
              if simple_array?(attribute)
                validate_simple_array_element(attribute, item, index)
                item
              else
                transform_array_item(attribute, item, index)
              end
            end
          end

          def validate_simple_array_element(attribute, item, index) # rubocop:disable Metrics/MethodLength
            self_attr = attribute.collection_of_attributes.first
            validator = Validation::AttributeValidator.new(self_attr)
            validator.validate_schema!

            begin
              validator.validate_value!(item)
            rescue Treaty::Exceptions::Validation => e
              # TODO: It is necessary to implement a translation system (I18n).
              raise Treaty::Exceptions::Validation,
                    "Error in array '#{attribute.name}' at index #{index}: " \
                    "Element must match one of the defined types. " \
                    "Errors: #{e.message}"
            end
          end

          def simple_array?(attribute)
            attribute.collection_of_attributes.size == 1 &&
              attribute.collection_of_attributes.first.name == SELF_SCOPE
          end

          def transform_array_item(attribute, item, index) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            unless item.is_a?(Hash)
              # TODO: It is necessary to implement a translation system (I18n).
              raise Treaty::Exceptions::Validation,
                    "Error in array '#{attribute.name}' at index #{index}: Expected Hash but got #{item.class}"
            end

            transformed_item = {}

            attribute.collection_of_attributes.each do |nested_attribute|
              source_name = nested_attribute.name
              nested_value = item.fetch(source_name, nil)

              validator = Validation::AttributeValidator.new(nested_attribute)
              validator.validate_schema!

              begin
                if nested_attribute.nested?
                  transformed_nested_value = validate_and_transform_nested(nested_attribute, nested_value, validator)
                else
                  validator.validate_value!(nested_value)
                  transformed_nested_value = nested_value
                end
              rescue Treaty::Exceptions::Validation => e
                # TODO: It is necessary to implement a translation system (I18n).
                raise Treaty::Exceptions::Validation,
                      "Error in array '#{attribute.name}' at index #{index}: #{e.message}"
              end

              target_name = fetch_target_name(nested_attribute)
              transformed_item[target_name] = transformed_nested_value
            end

            transformed_item
          end
        end
      end
    end
  end
end
