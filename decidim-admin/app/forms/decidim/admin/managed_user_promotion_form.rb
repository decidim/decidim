# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to promote managed users from the admin dashboard.
    #
    class ManagedUserPromotionForm < Form
      attribute :email, String

      validates :email, presence: true, "valid_email_2/email": { disposable: true }
      validate :unique_email

      private

      def unique_email
        return true if Decidim::User.where(
          organization: context.current_organization,
          email: email
        ).where.not(id: context.current_user.id).empty?

        errors.add :email, :taken
        false
      end
    end
  end
end
