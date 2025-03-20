# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind creating a user group.
  class UserGroupForm < Form
    include Decidim::HasUploadValidations

    mimic :group

    attribute :name
    attribute :nickname
    attribute :email
    attribute :avatar, Decidim::Attributes::Blob
    attribute :about
    attribute :document_number
    attribute :phone

    validates :name, presence: true
    validates :email, presence: true, "valid_email_2/email": { disposable: true }
    validates :nickname, presence: true

    validates :nickname, length: { maximum: Decidim::User.nickname_max_length, allow_blank: true }
    validates :avatar, passthru: { to: Decidim::UserGroup }

    validate :unique_document_number
    validate :unique_email
    validate :unique_name
    validate :unique_nickname

    alias organization current_organization

    private

    def unique_document_number
      return if document_number.blank?

      errors.add :document_number, :taken if UserGroup
                                             .with_document_number(
                                               context.current_organization,
                                               document_number
                                             )
                                             .where.not(id:)
                                             .present?
    end

    def unique_email
      return true if Decidim::UserBaseEntity
                     .where(
                       organization: context.current_organization,
                       email:
                     )
                     .where.not(id:)
                     .empty?

      errors.add :email, :taken
      false
    end

    def unique_name
      return true if Decidim::UserBaseEntity
                     .where(
                       organization: context.current_organization,
                       name:
                     )
                     .where.not(id:)
                     .empty?

      errors.add :name, :taken
      false
    end

    def unique_nickname
      return true if Decidim::UserBaseEntity
                     .where(
                       organization: context.current_organization,
                       nickname:
                     )
                     .where.not(id:)
                     .empty?

      errors.add :nickname, :taken
      false
    end
  end
end
