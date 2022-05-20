# frozen_string_literal: true

module Decidim
  module PasswordsHelper
    def password_help_text(reset_password_token)
      if needs_admin_password?(current_user || Decidim::User.with_reset_password_token(reset_password_token))
        return t("devise.passwords.edit.password_help_admin", minimun_characters: ::AdminPasswordValidator::MINIMUM_LENGTH)
      end

      t("devise.passwords.edit.password_help", minimun_characters: ::PasswordValidator::MINIMUM_LENGTH)
    end

    def needs_admin_password?(user)
      return false unless user&.admin?
      return false unless Decidim.config.admin_password_strong_enable

      true
    end
  end
end
