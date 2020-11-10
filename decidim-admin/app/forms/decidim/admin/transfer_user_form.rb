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
      attribute :current_user, Decidim::User
      attribute :conflict, Decidim::Verifications::Conflict

      validates :current_user, presence: true
      validates :conflict, presence: true
    end
  end
end
