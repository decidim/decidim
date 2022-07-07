# frozen_string_literal: true

module Decidim
  module System
    # A form object used to create organizations from the system dashboard.
    #
    class AdminForm < Form
      mimic :admin

      attribute :email, String
      attribute :password, String
      attribute :password_confirmation, String

      validates :email, presence: true
      validates :password, presence: true, unless: :admin_exists?
      validates :password_confirmation, presence: true, unless: :admin_exists?

      validates :password, password: { email: :email }

      validate :email, :email_uniqueness

      private

      def email_uniqueness
        return unless Admin.where(email: email).where.not(id: id).any?

        errors.add(:email, I18n.t("models.admin.validations.email_uniqueness",
                                  scope: "decidim.system"))
      end

      def admin_exists?
        id.present?
      end
    end
  end
end
