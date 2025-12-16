# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseMutation < GraphQL::Schema::RelayClassicMutation
        include Decidim::Api::GraphqlPermissions

        object_class BaseObject
        field_class Types::BaseField
        input_object_class BaseInputObject

        required_scopes "api:read", "api:write"

        def current_user
          context[:current_user]
        end

        def current_component
          context[:current_component]
        end

        def current_organization
          context[:current_organization]
        end

        def available_locales
          if current_organization.present?
            current_organization.available_locales
          else
            I18n.available_locales.map(&:to_s)
          end
        end
      end
    end
  end
end
