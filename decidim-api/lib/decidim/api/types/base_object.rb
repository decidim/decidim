# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        include Decidim::Api::GraphqlPermissions

        field_class Types::BaseField

        required_scopes "api:read"
      end
    end
  end
end
