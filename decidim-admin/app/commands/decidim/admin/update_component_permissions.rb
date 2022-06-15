# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when permissions for a component are updated
    # in the admin panel.
    class UpdateComponentPermissions < Decidim::Command
      # Public: Initializes the command.
      #
      # form    - The form from which the data in this component comes from.
      # component - The component to update.
      # resource - The resource to update.
      def initialize(form, component, resource, user)
        @form = form
        @component = component
        @resource = resource
        @user = user
      end

      # Public: Sets the permissions for a component.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) unless form.valid?

        Decidim.traceability.perform_action!("update_permissions", @component, @user) do
          transaction do
            update_permissions
            run_hooks
          end
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :component, :resource

      def configured_permissions
        form.permissions.select do |action, permission|
          selected_handlers(permission).present? || overriding_component_permissions?(action)
        end
      end

      def update_permissions
        permissions = configured_permissions.inject({}) do |result, (key, value)|
          handlers_content = {}

          selected_handlers(value).each do |handler_key|
            opts = value.authorization_handlers_options[handler_key.to_s]
            handlers_content[handler_key] = opts ? { options: opts } : {}
          end

          serialized = {
            "authorization_handlers" => handlers_content
          }

          result.update(key => selected_handlers(value).any? ? serialized : {})
        end

        if resource
          resource_permissions.update!(permissions: different_from_component_permissions(permissions))
        else
          component.update!(permissions: permissions)
        end
      end

      def run_hooks
        component.manifest.run_hooks(:permission_update, component: component, resource: resource)
      end

      def resource_permissions
        @resource_permissions ||= resource.resource_permission || resource.build_resource_permission
      end

      def different_from_component_permissions(permissions)
        return permissions unless component.permissions

        permissions.deep_stringify_keys.reject do |action, config|
          Hashdiff.diff(config, component.permissions[action]).empty?
        end
      end

      def overriding_component_permissions?(action)
        resource && component&.permissions&.fetch(action, nil)
      end

      def selected_handlers(permission)
        permission.authorization_handlers_names & component.organization.available_authorizations
      end
    end
  end
end
