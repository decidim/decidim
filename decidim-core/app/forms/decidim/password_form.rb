# frozen_string_literal: true

module Decidim
  class PasswordForm < Form
    attribute :password
    attribute :password_confirmation

    validate :passwords_match

    private

    def passwords_match
      errors.add(:password, I18n.t("decidim.forms.errors.decidim/user.password_confirmation")) if password != password_confirmation
    end
  end
end
