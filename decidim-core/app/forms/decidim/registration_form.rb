# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    attribute :sign_up_as, String
    attribute :name, String
    attribute :nickname, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean

    attribute :user_group_name, String
    attribute :user_group_document_number, String
    attribute :user_group_phone, String

    validates :sign_up_as, inclusion: { in: %w(user user_group) }
    validates :name, presence: true
    validates :nickname, presence: true, length: { maximum: Decidim::User.nickname_max_length }
    validates :email, presence: true, 'valid_email_2/email': { disposable: true }
    validates :password, confirmation: true
    validates :password, password: { name: :name, email: :email, username: :nickname }
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true

    validates :user_group_name, presence: true, if: :user_group?
    validates :user_group_document_number, presence: true, if: :user_group?
    validates :user_group_phone, presence: true, if: :user_group?

    validate :email_unique_in_organization
    validate :nickname_unique_in_organization
    validate :user_group_name_unique_in_organization
    validate :user_group_document_number_unique_in_organization

    def user_group?
      sign_up_as == "user_group"
    end

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

    def user_group_name_unique_in_organization
      errors.add :user_group_name, :taken if UserGroup.find_by(name: user_group_name, decidim_organization_id: current_organization.id).present?
    end

    def user_group_document_number_unique_in_organization
      errors.add :user_group_document_number, :taken if UserGroup.find_by(
        document_number: user_group_document_number,
        decidim_organization_id: current_organization.id
      ).present?
    end
  end
end
