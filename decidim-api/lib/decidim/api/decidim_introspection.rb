# frozen_string_literal: true

module Decidim
  module Api
    module DecidimIntrospection
      module FieldVisibility
        extend ActiveSupport::Concern

        included do
          def self.visible?(context)
            raise Errors::IntrospectionDisabledError, I18n.t("decidim.api.errors.introspection_disabled") unless context[:can_introspect] == true

            super
          end
        end
      end

      class SchemaType < GraphQL::Introspection::SchemaType
        include FieldVisibility
      end

      class TypeType < GraphQL::Introspection::TypeType
        include FieldVisibility
      end

      class DirectiveType < GraphQL::Introspection::DirectiveType
        include FieldVisibility
      end

      class DirectiveLocationEnum < GraphQL::Introspection::DirectiveLocationEnum
        include FieldVisibility
      end

      class EnumValueType < GraphQL::Introspection::EnumValueType
        include FieldVisibility
      end

      class FieldType < GraphQL::Introspection::FieldType
        include FieldVisibility
      end

      class InputValueType < GraphQL::Introspection::InputValueType
        include FieldVisibility
      end

      class TypeKindEnum < GraphQL::Introspection::TypeKindEnum
        include FieldVisibility
      end
    end
  end
end
