# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    attribute :sign_up_as, String
    attribute :name, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :newsletter_notifications, Boolean
    attribute :tos_agreement, Boolean

    attribute :user_group_name, String
    attribute :user_group_document_number, String
    attribute :user_group_phone, String

    validates :sign_up_as, inclusion: { in: %w(user user_group) }
    validates :name, presence: true
    validates :email, presence: true
    validates :password, presence: true, confirmation: true, length: { in: Decidim::User.password_length }
    validates :tos_agreement, allow_nil: false, acceptance: true

    validates :user_group_name, presence: true, if: :user_group?
    validates :user_group_document_number, presence: true, if: :user_group?
    validates :user_group_phone, presence: true, if: :user_group?

    validate :email_unique_in_organization
    validate :user_group_name_unique_in_organization
    validate :user_group_document_number_unique_in_organization

    def user_group?
      sign_up_as == "user_group"
    end

    private

    def email_unique_in_organization
      errors.add :email, :taken if User.where(email: email, organization: current_organization).first.present?
    end

    def user_group_name_unique_in_organization
      errors.add :user_group_name, :taken if UserGroup.where(name: user_group_name, decidim_organization_id: current_organization.id).first.present?
    end

    def user_group_document_number_unique_in_organization
      errors.add :user_group_document_number, :taken if UserGroup.where(
        document_number: user_group_document_number,
        decidim_organization_id: current_organization.id
      ).first.present?
    end
  end
end
