# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        field_class Types::BaseField

        # This is a simplified adaptation of allowed_to? from NeedsPermission concern
        # @param action [Symbol] The action performed. Most cases the action is :read
        # @param subject [Symbol] The name of the subject. Ex: :participatory_space, :component
        # @param object [ActiveModel::Base] The object that is being represented.
        # @param context [GraphQL::Query::Context] The GraphQL context
        #
        # @return Boolean
        def self.allowed_to?(action, subject, object, context)
          permission_action = Decidim::PermissionAction.new(scope: :public, action:, subject:)

          permission_chain(object).inject(permission_action) do |current_permission_action, permission_class|
            permission_class.new(
              context[:current_user],
              current_permission_action,
              local_context(object, context)
            ).permissions
          end.allowed?
        end

        # Injects into context object current_participatory_space and current_component keys as they are needed
        #
        # @param object [ActiveModel::Base] The object that is being represented.
        # @param context [GraphQL::Query::Context] The GraphQL context
        #
        # @return Hash
        def self.local_context(object, context)
          context[:current_participatory_space] = object.participatory_space if object.respond_to?(:participatory_space)
          context[:current_component] = object.component if object.respond_to?(:component)

          context.to_h
        end

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
          permissions.unshift(object.component.manifest.permissions_class) if object.respond_to?(:component)

          permissions
        end
      end
    end
  end
end
