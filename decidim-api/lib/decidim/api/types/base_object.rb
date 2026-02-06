# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        include Decidim::Api::RequiredScopes
        include Decidim::Api::GraphqlPermissions

        field_class Types::BaseField

        required_scopes "api:read"

        def current_user
          context[:current_user]
        end

        def current_component
          context[:current_component]
        end

        def current_organization
          context[:current_organization]
        end
      end
    end
  end
end
