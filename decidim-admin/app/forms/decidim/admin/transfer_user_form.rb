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
      validates :email, presence: true
      validate :unique_email

      private

      def unique_email
        return if conflict.blank?
        return true if Decidim::UserBaseEntity.where(
          organization: context.current_organization,
          email:
        ).where.not(id: [conflict.current_user.id, conflict.managed_user_id]).empty?

        errors.add :email, :taken
        false
      end
    end
  end
end
