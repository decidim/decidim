# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when permissions for a resource not related with
    # a component are updated in the admin panel.
    class UpdateResourcePermissions < Rectify::Command
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
          permission.authorization_handler_name.present?
        end
      end

      def update_permissions
        permissions = configured_permissions.inject({}) do |result, (key, value)|
          serialized = {
            "authorization_handler_name" => value.authorization_handler_name,
            "options" => value.options
          }

          result.update(key => value.authorization_handler_name.present? ? serialized : {})
        end

        resource_permissions.update!(permissions: permissions)
      end

      def resource_permissions
        @resource_permissions ||= resource.resource_permission || resource.build_resource_permission
      end
    end
  end
end
