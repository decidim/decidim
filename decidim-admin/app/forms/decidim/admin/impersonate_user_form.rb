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

      validates :user, presence: true
    end
  end
end
