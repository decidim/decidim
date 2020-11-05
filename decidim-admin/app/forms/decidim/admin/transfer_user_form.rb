# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to transfer conflicted users from the admin dashboard.
    #
    # This form will contain a dynamic attribute for the user authorization.
    # This authorization will be selected by the admin user if more than one exists.
    class TransferUserForm < Form
      attribute :email, String
      attribute :reason, String
      attribute :user, Decidim::User
      attribute :managed_user, Decidim::User
      attribute :conflict, Decidim::Verifications::Conflict

      validates :user, presence: true
      validates :managed_user, presence: true
    end
  end
end
