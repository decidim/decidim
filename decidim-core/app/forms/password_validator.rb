# frozen_string_literal: true

# Class is used to verify that the user's password is strong enough
class PasswordValidator < ActiveModel::EachValidator
  MINIMUM_LENGTH = 10
  MAX_LENGTH = 256
  MIN_UNIQUE_CHARACTERS = 5
  VALIDATION_METHODS = [
    :password_too_short?,
    :password_too_long?,
    :not_enough_unique_characters?,
    :username_included_in_password?,
    :email_included_in_password?,
    :domain_included_in_password?,
    :password_too_common
  ].freeze

  # Check if user's password is strong enough
  #
  # record - Instance of a form (e.g. Decidim::RegistrationForm) or model
  # attribute - "password"
  # value - Actual password
  # Returns true if password is strong enough
  def validate_each(record, attribute, value)
    @record = record
    @attribute = attribute
    @value = value
    @weak_password_reasons = []

    return true if strong?

    @weak_password_reasons.each do |reason|
      record.errors[attribute] << get_message(reason)
    end

    false
  end

  private

  attr_reader :record, :attribute, :value

  def strong?
    @strong ||= check_password
  end

  def get_message(reason)
    I18n.t "password_validator.#{reason}"
  end

  def check_password
    VALIDATION_METHODS.each do |method|
      @weak_password_reasons << method.to_s.sub(/\?$/, "").to_sym if send(method.to_s)
    end

    @weak_password_reasons.empty?
  end

  def password_too_short?
    value.length < MINIMUM_LENGTH
  end

  def password_too_long?
    value.length > MAX_LENGTH
  end

  def not_enough_unique_characters?
    value.split("").uniq.length < MIN_UNIQUE_CHARACTERS
  end

  def username_included_in_password?
    record.name.split(" ").include?(value) || record.name.downcase.split(" ").include?(value)
  end

  def email_included_in_password?
    name, domain, _whatever = record.email.split("@")

    value.include?(name) || value.include?(domain.split(".").first)
  end

  def domain_included_in_password?
    return false unless record&.context&.current&.organization&.host

    record.context.current.organization.host.split(".").each do |part|
      next if part.length < 4

      return true if value.include?(part)
    end

    false
  end

  def password_too_common
    Decidim::CommonPasswords.instance.dictionary.include?(value)
  end
end
