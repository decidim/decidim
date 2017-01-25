# frozen_string_literal: true

module Decidim
  # A form object used to invite admins to an organization.
  #
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

    private

    def password_present
      !password.blank?
    end
  end
end
