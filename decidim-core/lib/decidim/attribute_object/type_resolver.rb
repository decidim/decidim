# frozen_string_literal: true

# Make sure the custom attributes are defined
require "decidim/attributes"

module Decidim
  module AttributeObject
    # This resolves the ActiveModel::Attributes types from the Decidim's own
    # type definitions format inspired by Virtus.
    class TypeResolver
      def resolve(type, **options)
        case type
        when Symbol, ActiveModel::Type::Value
          {
            type: type,
            options: options
          }
        when Class
          resolve_class(type, **options)
        when Hash
          resolve_hash(type, **options)
        when Array
          resolve_array(type, **options)
        else
          resolve_default(type, **options)
        end
      end

      def exists?(type)
        # This needs to be changed after upgrade to Rails 7.0 as follows:
        # ActiveModel::Type.registry.send(:registrations).has_key?(type)
        ActiveModel::Type.registry.send(:registrations).any? { |t| t.send(:name) == type }
      end

      private

      def resolve_class(type, **options)
        if type.include?(Decidim::AttributeObject::Model) || type <= ActiveRecord::Base
          {
            type: :model,
            options: options.merge(primitive: type)
          }
        elsif type == Hash
          resolve_hash({ Symbol => Object }, **options)
        elsif type == Array
          resolve_array(Array[Object], **options)
        else
          resolve_default(type, **options)
        end
      end

      def resolve_hash(type, **options)
        key_type = type.keys.first || Symbol
        val_type = type.values.first || Object
        options[:default] ||= {}

        {
          type: :hash,
          options: options.merge(key_type: key_type, value_type: val_type)
        }
      end

      def resolve_array(type, **options)
        options[:default] ||= []

        {
          type: :array,
          options: options.merge(value_type: type.first)
        }
      end

      def resolve_default(type, **options)
        type_symbol = type.to_s.underscore.to_sym

        if exists?(type_symbol)
          # Off the bat, this handles the basic types from:
          # https://github.com/rails/rails/tree/main/activemodel/lib/active_model/type
          {
            type: type_symbol,
            options: options
          }
        else
          {
            type: :object,
            options: options.merge(primitive: type)
          }
        end
      end
    end
  end
end
