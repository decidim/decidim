# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to impersonate users from the admin dashboard.
    #
    # This form will contain a dynamic attribute for the user authorization.
    # This authorization will be selected by the admin user if more than one exists.
    class ImpersonateUserForm < Form
      attribute :name, String
      attribute :reason, String
      attribute :user, Decidim::User
      attribute :authorization, Decidim::AuthorizationHandler
      attribute :handler_name, String

      validates :user, presence: true
      validates :reason, presence: true, unless: :managed_user?

      private

      def managed_user?
        user && user.managed?
      end
    end
  end
end
