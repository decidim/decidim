# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when permissions for a component are updated
    # in the admin panel.
    class UpdateComponentPermissions < Rectify::Command
      attr_reader :form, :component

      # Public: Initializes the command.
      #
      # form    - The form from which the data in this component comes from.
      # component - The component to update.
      def initialize(form, component)
        @form = form
        @component = component
      end

      # Public: Sets the permissions for a component.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) unless @form.valid?

        transaction do
          update_permissions
          run_hooks
        end

        broadcast(:ok)
      end

      private

      def configured_permissions
        @form.permissions.select do |_action, permission|
          permission.authorization_handler_name.present?
        end
      end

      def update_permissions
        permissions = configured_permissions.inject({}) do |result, (key, value)|
          serialized = {
            "authorization_handler_name" => value.authorization_handler_name,
            "options" => value.options
          }

          result.update(key => serialized)
        end

        @component.update!(
          permissions: permissions
        )
      end

      def run_hooks
        @component.manifest.run_hooks(:permission_update, @component)
      end
    end
  end
end
