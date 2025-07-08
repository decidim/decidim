# frozen_string_literal: true

module Decidim
  module Api
    # Adds methods to Authorize the API objects.
    module GraphqlPermissions
      extend ActiveSupport::Concern

      include Decidim::Api::RequiredScopes

      class_methods do
        def authorized?(object, context)
          return false unless scope_authorized?(context)

          chain = []

          subject = determine_subject_name(object)
          context[subject] = object

          chain.unshift(allowed_to?(:read, :participatory_space, object, context)) if object.respond_to?(:participatory_space)
          chain.unshift(allowed_to?(:read, :component, object, context)) if object.respond_to?(:component) && object.component.present?

          super && chain.all?
        end

        def determine_subject_name(object)
          object.class.name.split("::").last.underscore.to_sym
        end

        # This is a simplified adaptation of allowed_to? from NeedsPermission concern
        # @param action [Symbol] The action performed. Most cases the action is :read
        # @param subject [Object] The name of the subject. Ex: :participatory_space, :component, or object
        # @param object [ActiveModel::Base] The object that is being represented.
        # @param context [GraphQL::Query::Context] The GraphQL context
        #
        # @return Boolean
        def allowed_to?(action, subject, object, context, scope: :public)
          unless subject.is_a?(::Symbol)
            subject = determine_subject_name(object)
            context[subject] = object
          end

          permission_action = Decidim::PermissionAction.new(scope:, action:, subject:)

          permission_chain(object).inject(permission_action) do |current_permission_action, permission_class|
            permission_context =
              if scope == :admin
                local_admin_context(object, context)
              else
                local_context(object, context)
              end

            permission_class.new(
              context[:current_user],
              current_permission_action,
              permission_context
            ).permissions
          end.allowed?
        end

        # Injects into context object current_participatory_space and current_component keys as they are needed
        #
        # @param object [ActiveModel::Base] The object that is being represented.
        # @param context [GraphQL::Query::Context] The GraphQL context
        #
        # @return Hash
        def local_context(object, context)
          context[:current_participatory_space] = object.participatory_space if object.respond_to?(:participatory_space)
          context[:current_component] =
            if object.is_a?(Decidim::Component)
              object
            elsif object.respond_to?(:component)
              object.component
            end

          context.to_h
        end

        def local_admin_context(object, context)
          context = local_context(object, context)

          component = context[:current_component]
          return context unless component
          return context unless component.respond_to?(:current_settings)
          return context unless component.respond_to?(:settings)
          return context unless component.respond_to?(:organization)

          context[:current_settings] = component.current_settings
          context[:component_settings] = component.settings
          context[:current_organization] = component.organization

          context
        end

        # Creates the permission chain arrau that contains all the permission classes required to authorize a certain resource
        # We are using unshift as we need the Admin and base permissions to be last in the chain
        # @param object [ActiveModel::Base] The object that is being represented.
        #
        # @return [Decidim::DefaultPermissions]
        def permission_chain(object)
          permissions = [
            Decidim::Admin::Permissions,
            Decidim::Permissions
          ]

          if object.is_a?(Decidim::Component)
            permissions.unshift(object.participatory_space.manifest.permissions_class)
            permissions.unshift(object.manifest.permissions_class)
          else
            permissions.unshift(object.participatory_space.manifest.permissions_class) if object.respond_to?(:participatory_space)
            permissions.unshift(object.component.manifest.permissions_class) if object.respond_to?(:component) && object.component.present?
          end

          permissions
        end
      end

      private

      delegate :allowed_to?, to: :class

      attr_reader :action
    end
  end
end
