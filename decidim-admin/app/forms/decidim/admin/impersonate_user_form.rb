# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to impersonate users from the admin dashboard.
    #
    # This form will contain a dynamic attribute for the user authorization.
    # This authorization will be selected by the admin user if more than one exists.
    class ImpersonateUserForm < Form
      attribute :name, String
      attribute :user, Decidim::User
      attribute :authorization, Decidim::AuthorizationHandler

      attribute :impersonation_target, Decidim::User

      validates :impersonation_target, presence: true

      def impersonation_target
        return user if name.blank?

        Decidim::User.find_or_initialize_by(
          organization: current_organization,
          managed: true,
          name: name
        ) do |u|
          u.admin = false
          u.tos_agreement = true
        end
      end
    end
  end
end
