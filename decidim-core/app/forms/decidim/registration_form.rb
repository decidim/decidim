# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    attribute :name, String
    attribute :nickname, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean

    validates :name, presence: true
    validates :nickname, presence: true, length: { maximum: Decidim::User.nickname_max_length }
    validates :email, presence: true, 'valid_email_2/email': { disposable: true }
    validates :password, confirmation: true
    validates :password, password: { name: :name, email: :email, username: :nickname }
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true

    validate :email_unique_in_organization
    validate :nickname_unique_in_organization

    def newsletter_at
      return nil unless newsletter?
      Time.current
    end

    private

    def email_unique_in_organization
      errors.add :email, :taken if User.find_by(email: email, organization: current_organization).present?
    end

    def nickname_unique_in_organization
      errors.add :nickname, :taken if User.find_by(nickname: nickname, organization: current_organization).present?
    end
  end
end
