# frozen_string_literal: true

module Decidim
  module PasswordsHelper
    def password_field_options_for(user)
      user =
        case user
        when :user
          Decidim::User.new
        when :admin
          Decidim::User.new(admin: true)
        when String
          Decidim::User.with_reset_password_token(user)
        else
          user
        end
      min_length = ::PasswordValidator.minimum_length_for(user)
      help_text =
        if needs_admin_password?(user)
          t("devise.passwords.edit.password_help_admin", minimum_characters: min_length)
        else
          t("devise.passwords.edit.password_help", minimum_characters: min_length)
        end

      {
        autocomplete: "new-password",
        required: true,
        label: false,
        help_text:,
        value: @account&.password,
        minlength: min_length,
        maxlength: ::PasswordValidator::MAX_LENGTH,
        placeholder: "**********"
      }
    end

    def old_password_options
      help_text = t("devise.passwords.edit.old_password_help").html_safe

      {
        autocomplete: "current-password",
        required: true,
        label: false,
        help_text:,
        placeholder: "**********"
      }
    end

    def needs_admin_password?(user)
      return false unless user&.admin?
      return false unless Decidim.config.admin_password_strong

      true
    end
  end
end
