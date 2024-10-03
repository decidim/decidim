# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        field_class Types::BaseField

        def self.allowed_to?(action, subject, object, context)
          chain = [
            object.component.manifest.permissions_class,
            object.participatory_space.manifest.permissions_class,
            Decidim::Admin::Permissions,
            Decidim::Permissions
          ]

          local_context = context.to_h
          local_context.merge!({ current_participatory_space: object.try(:participatory_space) })
          local_context.merge!({ current_component: object.try(:component) })

          permission_action = Decidim::PermissionAction.new(scope: :public, action:, subject:)

          chain.inject(permission_action) do |current_permission_action, permission_class|
            permission_class.new(context[:current_user], current_permission_action, local_context).permissions
          end.allowed?
        # rescue Decidim::PermissionAction::PermissionNotSetError
        #   false
        end
      end
    end
  end
end
