# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # account in her profile page.
  class AccountForm < Form
    mimic :user

    attribute :name
    attribute :email
    attribute :password
    attribute :password_confirmation
    attribute :avatar
    attribute :remove_avatar

    validates :name, presence: true
    validates :email, presence: true

    validates :password, confirmation: true
    validates :password, length: { in: Decidim::User.password_length, allow_blank: true }
    validates :password_confirmation, presence: true, if: :password_present
    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }

    validate :unique_email

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
  end
end
