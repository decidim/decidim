# frozen_string_literal: true

# Class is used to verify that the admin's password is strong enough
class AdminPasswordValidator < PasswordValidator
  MINIMUM_LENGTH = Decidim.config.admin_password_min_characters
  REPETITION_TIMES = Decidim.config.admin_password_repetition_times
  VALIDATION_METHODS = [
    :password_too_short?,
    :password_repeated?
  ].freeze

  private

  attr_reader :record, :attribute, :value

  def get_message(reason)
    I18n.t "admin_password_validator.#{reason}"
  end

  def password_too_short?
    value.length < MINIMUM_LENGTH
  end

  def password_repeated?
    [record.encrypted_password_was, *record.previous_passwords].compact.take(REPETITION_TIMES).each do |encrypted_password|
      return true if Devise::Encryptor.compare(Decidim::User, encrypted_password, value)
    end

    false
  end
end
