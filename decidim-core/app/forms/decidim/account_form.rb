# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # account in their profile page.
  class AccountForm < Form
    include Decidim::HasUploadValidations

    mimic :user

    attribute :locale
    attribute :name
    attribute :nickname
    attribute :email
    attribute :old_password
    attribute :password
    attribute :avatar, Decidim::Attributes::Blob
    attribute :remove_avatar, Boolean, default: false
    attribute :personal_url
    attribute :about

    validates :name, presence: true, format: { with: Decidim::User::REGEXP_NAME }
    validates :email, presence: true, "valid_email_2/email": { disposable: true }
    validates :nickname,
              presence: true,
              format: { with: Decidim::User::REGEXP_NICKNAME, message: :format },
              length: { maximum: Decidim::User.nickname_max_length }

    validates :nickname, length: { maximum: Decidim::User.nickname_max_length, allow_blank: true }
    validates :password, password: { name: :name, email: :email, username: :nickname }, if: -> { password.present? }
    validate :validate_old_password
    validates :avatar, passthru: { to: Decidim::User }

    validate :unique_email
    validate :unique_nickname
    validate :personal_url_format

    alias organization current_organization

    def personal_url
      return if super.blank?

      return "http://#{super}" unless super.match?(%r{\A(http|https)://}i)

      super
    end

    private

    def unique_email
      return true if Decidim::UserBaseEntity.where(
        organization: context.current_organization,
        email:
      ).where.not(id: context.current_user.id).empty?

      errors.add :email, :taken
      false
    end

    def validate_old_password
      user = context.current_user
      if user.email != email || password.present?
        return true if user.valid_password?(old_password)

        errors.add :old_password, :invalid
        false
      end
    end

    def unique_nickname
      return true if Decidim::UserBaseEntity.where(
        "decidim_organization_id = ? AND nickname = ? ",
        context.current_organization.id,
        nickname.downcase
      ).where.not(id: context.current_user.id).empty?

      errors.add :nickname, :taken
      false
    end

    def personal_url_format
      return if personal_url.blank?

      uri = URI.parse(personal_url)
      errors.add :personal_url, :invalid if !uri.is_a?(URI::HTTP) || uri.host.nil?
    rescue URI::InvalidURIError
      errors.add :personal_url, :invalid
    end
  end
end
