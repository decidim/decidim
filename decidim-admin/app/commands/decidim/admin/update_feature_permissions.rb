# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when permissions for a feature are updated
    # in the admin panel.
    class UpdateFeaturePermissions < Rectify::Command
      attr_reader :form, :feature

      # Public: Initializes the command.
      #
      # form    - The form from which the data in this feature comes from.
      # feature - The feature to update.
      def initialize(form, feature)
        @form = form
        @feature = feature
      end

      # Public: Sets the permissions for a feature.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) unless @form.valid?

        update_permissions
        broadcast(:ok)
      end

      private

      def update_permissions
        permissions = @form.permissions.inject({}) do |result, (key, value)|
          serialized = {
            "authorization_handler_name" => value.authorization_handler_name
          }

          serialized["options"] = JSON.parse(value.options) if value.options
          result.update(key => serialized)
        end

        @feature.update_attributes!(
          permissions: permissions
        )
      end
    end
  end
end
