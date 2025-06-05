# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        include Decidim::Api::RequiredScopes

        field_class Types::BaseField

        required_scopes "api:read"

        def self.authorized?(object, context)
          return false unless scope_authorized?(context)

          chain = []

          subject = determine_subject_name(object)
          context[subject] = object

          chain.unshift(allowed_to?(:read, :participatory_space, object, context)) if object.respond_to?(:participatory_space)
          chain.unshift(allowed_to?(:read, :component, object, context)) if object.respond_to?(:component) && object.component.present?

          super && chain.all?
        end

        def self.determine_subject_name(object)
          object.class.name.split("::").last.underscore.to_sym
        end

        # This is a simplified adaptation of allowed_to? from NeedsPermission concern
        # @param action [Symbol] The action performed. Most cases the action is :read
        # @param subject [Object] The name of the subject. Ex: :participatory_space, :component, or object
        # @param object [ActiveModel::Base] The object that is being represented.
        # @param context [GraphQL::Query::Context] The GraphQL context
        #
        # @return Boolean
        def self.allowed_to?(action, subject, object, context)
          unless subject.is_a?(::Symbol)
            subject = determine_subject_name(object)
            context[subject] = object
          end

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
          context[:current_component] = object.component if object.respond_to?(:component) && object.component.present?

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
          permissions.unshift(object.component.manifest.permissions_class) if object.respond_to?(:component) && object.component.present?

          permissions
        end
      end
    end
  end
end
