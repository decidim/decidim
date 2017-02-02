# frozen_string_literal: true
module Decidim
  module Admin
    class PermissionsForm < Form
      mimic :feature_permissions

      attribute :permissions, Hash[String => PermissionForm]

      def valid?
        super && permissions.values.all?(&:valid?)
      end
    end
  end
end
