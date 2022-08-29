# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when permissions for a resource not related with
    # a component are updated in the admin panel.
    class UpdateResourcePermissions < Decidim::Command
      # Public: Initializes the command.
      #
      # form     - The form from which the data in this resource comes from.
      # resource - The resource to update.
      def initialize(form, resource)
        @form = form
        @resource = resource
      end

      # Public: Sets the permissions for a resource.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) unless form.valid?

        transaction do
          update_permissions
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :resource

      def configured_permissions
        form.permissions.select do |_, permission|
          selected_handlers(permission).any?
        end
      end

      def update_permissions
        permissions = configured_permissions.inject({}) do |result, (key, value)|
          handlers_content = selected_handlers(value).inject({}) do |handlers_content_result, handler_key|
            opts = value.authorization_handlers_options[handler_key.to_s]

            handlers_content_result.update(handler_key => opts ? { options: opts } : {})
          end

          serialized = {
            "authorization_handlers" => handlers_content
          }

          result.update(key => selected_handlers(value).any? ? serialized : {})
        end

        resource_permissions.update!(permissions:)
      end

      def resource_permissions
        @resource_permissions ||= resource.resource_permission || resource.build_resource_permission
      end

      def selected_handlers(permission)
        permission.authorization_handlers_names & @form.current_organization.available_authorizations
      end
    end
  end
end
