# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        include Decidim::Api::RequiredScopes
        include Decidim::Api::GraphqlPermissions

        field_class Types::BaseField

        required_scopes "api:read"

        # Creates the permission chain arrau that contains all the permission classes required to authorize a certain resource
        # We are using unshift as we need the Admin and base permissions to be last in the chain
        # @param object [ActiveModel::Base] The object that is being represented.
        #
        # @return [Decidim::DefaultPermissions]
        def self.permission_chain(object)
          permissions = [
            Decidim::Admin::Permissions,
            Decidim::Permissions
          ]

          permissions.unshift(object.participatory_space.manifest.permissions_class) if object.respond_to?(:participatory_space)
          permissions.unshift(object.component.manifest.permissions_class) if object.respond_to?(:component) && object.component.present?

          permissions
        end
      end
    end
  end
end
