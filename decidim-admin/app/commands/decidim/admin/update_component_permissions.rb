# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when permissions for a component are updated
    # in the admin panel.
    class UpdateComponentPermissions < Decidim::Command
      delegate :current_user, to: :form
      # Public: Initializes the command.
      #
      # form    - The form from which the data in this component comes from.
      # component - The component to update.
      # resource - The resource to update.
      def initialize(form, component, resource)
        @form = form
        @component = component
        @resource = resource
      end

      # Public: Sets the permissions for a component.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) unless form.valid?

        Decidim.traceability.perform_action!("update_permissions", @component, current_user) do
          transaction do
            permissions_with_changes_in_ephemeral_handlers
            update_permissions
            raise ActiveRecord::Rollback unless clean_ephemeral_authorizations

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
        if resource
          resource_permissions.update!(permissions: permissions_with_differences(component.permissions, selected_permissions))
        else
          component.update!(permissions: selected_permissions)
        end
      end

      def clean_ephemeral_authorizations
        handler_names = permissions_with_changes_in_ephemeral_handlers.values.map { |config| config["authorization_handlers"].keys }.flatten.uniq
        ephemeral_handler_names = handler_names.select { |handler_name| Decidim::Verifications::Adapter.from_element(handler_name).ephemeral? }

        ephemeral_handler_names.each do |name|
          Decidim::Verifications::RevokeByNameAuthorizations.call(current_user.organization, name, current_user) do
            on(:ok) do
              return true
            end

            on(:invalid) do
              return false
            end
          end
        end
      end

      def run_hooks
        component.manifest.run_hooks(:permission_update, component:, resource:)
      end

      def selected_permissions
        @selected_permissions ||= configured_permissions.inject({}) do |result, (key, value)|
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
      end

      def permissions_with_changes_in_ephemeral_handlers
        @permissions_with_changes_in_ephemeral_handlers ||= begin
          old_permissions = ((resource.present? ? resource_permissions.permissions : component.permissions) || {}).deep_stringify_keys

          selected_permissions.deep_stringify_keys.reject do |action, config|
            old_config = old_permissions[action] || { "authorization_handlers" => {} }
            Hashdiff.diff(config, old_config).none? do |_, key, _|
              handler_name = key.split(".")[1]
              next if handler_name.blank?

              Decidim::Verifications::Adapter.from_element(handler_name).ephemeral? && config["authorization_handlers"].keys.include?(handler_name)
            end
          end
        end
      end

      def resource_permissions
        @resource_permissions ||= resource.resource_permission || resource.build_resource_permission
      end

      def permissions_with_differences(old_permissions, new_permissions)
        return new_permissions unless old_permissions

        old_permissions = old_permissions.deep_stringify_keys

        new_permissions.deep_stringify_keys.reject do |action, config|
          Hashdiff.diff(old_permissions[action], config).empty?
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
