# frozen_string_literal: true

module Decidim
  module Admin
    # This form handles a set of forms related to handling permissions
    # in the admin panel.
    class PermissionsForm < Form
      mimic :component_permissions

      attribute :permissions, Hash[String => PermissionForm]

      private

      # Overriding Rectify::Form#form_attributes_valid? to preserve errors from custom method validations.
      def form_attributes_valid?
        return false unless errors.empty? && permissions.each_value.map(&:errors).all?(&:empty?)

        super && permissions.values.all?(&:valid?)
      end
    end
  end
end
