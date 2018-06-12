# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # account in her profile page.
  class AccountForm < Form
    mimic :user

    attribute :name
    attribute :nickname
    attribute :email
    attribute :password
    attribute :password_confirmation
    attribute :avatar
    attribute :remove_avatar
    attribute :personal_url
    attribute :about

    validates :name, presence: true
    validates :email, presence: true
    validates :nickname, presence: true

    validates :nickname, length: { maximum: Decidim::User.nickname_max_length, allow_blank: true }
    validates :password, confirmation: true
    validates :password, password: { name: :name, email: :email, username: :nickname }, if: -> { password.present? }
    validates :password_confirmation, presence: true, if: :password_present
    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }

    validate :unique_email
    validate :unique_nickname
    validate :personal_url_format

    def personal_url
      return if super.blank?

      return "http://" + super unless super.match?(%r{\A(http|https)://}i)

      super
    end

    private

    def password_present
      password.present?
    end

    def unique_email
      return true if Decidim::User.where(
        organization: context.current_organization,
        email: email
      ).where.not(id: context.current_user.id).empty?

      errors.add :email, :taken
      false
    end

    def unique_nickname
      return true if Decidim::User.where(
        organization: context.current_organization,
        nickname: nickname
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
