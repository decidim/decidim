# frozen_string_literal: true

module Decidim
  module Admin
    # This form handles a set of forms related to handling permissions
    # in the admin panel.
    class PermissionsForm < Form
      mimic :component_permissions

      attribute(:permissions, { String => PermissionForm })
    end
  end
end
