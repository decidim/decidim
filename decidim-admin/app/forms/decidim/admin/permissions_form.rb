# frozen_string_literal: true

module Decidim
  module Admin
    # This form handles a set of forms related to handling permissions
    # in the admin panel.
    class PermissionsForm < Form
      mimic :feature_permissions

      attribute :permissions, Hash[String => PermissionForm]

      def valid?
        super && permissions.values.all?(&:valid?)
      end
    end
  end
end
