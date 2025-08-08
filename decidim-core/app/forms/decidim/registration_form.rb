# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    attribute :name, String
    attribute :email, String
    attribute :password, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean
    attribute :current_locale, String

    validates :name, presence: true, format: { with: Decidim::User::REGEXP_NAME }
    validates :email, presence: true, "valid_email_2/email": { disposable: true }
    validates :password, presence: true, password: { name: :name, email: :email, username: :nickname }
    validates :tos_agreement, allow_nil: false, acceptance: true

    validate :email_unique_in_organization
    validate :no_pending_invitations_exist

    def nickname
      generate_nickname(name, current_organization)
    end

    def newsletter_at
      return nil unless newsletter?

      Time.current
    end

    private

    def email_unique_in_organization
      errors.add :email, :taken if valid_users.find_by(email:, organization: current_organization).present?
    end

    def generate_nickname(name, organization)
      Decidim::UserBaseEntity.nicknamize(name, organization.id)
    end

    def valid_users
      UserBaseEntity.where(invitation_token: nil)
    end

    def no_pending_invitations_exist
      errors.add :base, I18n.t("devise.failure.invited") if User.has_pending_invitations?(current_organization.id, email)
    end
  end
end
