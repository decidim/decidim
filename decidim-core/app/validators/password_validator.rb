# frozen_string_literal: true

# Class is used to verify that the user's password is strong enough
class PasswordValidator < ActiveModel::EachValidator
  MINIMUM_LENGTH = 10
  MAX_LENGTH = 256
  MIN_UNIQUE_CHARACTERS = 5
  IGNORE_SIMILARITY_SHORTER_THAN = 4
  VALIDATION_METHODS = [
    :password_too_short?,
    :password_too_long?,
    :not_enough_unique_characters?,
    :name_included_in_password?,
    :nickname_included_in_password?,
    :email_included_in_password?,
    :domain_included_in_password?,
    :password_too_common?,
    :blacklisted?
  ].freeze

  # Check if user's password is strong enough
  #
  # record - Instance of a form (e.g. Decidim::RegistrationForm) or model
  # attribute - "password"
  # value - Actual password
  # Returns true if password is strong enough
  def validate_each(record, attribute, value)
    return false if value.blank?

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

  def get_message(reason)
    I18n.t "password_validator.#{reason}"
  end

  def organization
    @organization ||= organization_from_record
  end

  def organization_from_record
    return record.current_organization if record.respond_to?(:current_organization)
    return record.organization if record.respond_to?(:organization)
  end

  def strong?
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
    value.chars.uniq.length < MIN_UNIQUE_CHARACTERS
  end

  def name_included_in_password?
    return false if !record.respond_to?(:name) || record.name.blank?
    return true if value.include?(record.name.delete(" "))

    record.name.split(" ").each do |part|
      next if part.length < IGNORE_SIMILARITY_SHORTER_THAN

      return true if value.include?(part)
    end

    false
  end

  def nickname_included_in_password?
    return false if !record.respond_to?(:nickname) || record.nickname.blank?

    value.include?(record.nickname)
  end

  def email_included_in_password?
    return false if !record.respond_to?(:email) || record.email.blank?

    name, domain, _whatever = record.email.split("@")
    value.include?(name) || (domain && value.include?(domain.split(".").first))
  end

  def domain_included_in_password?
    return false unless organization && organization.host
    return true if value.include?(organization.host)

    organization.host.split(".").each do |part|
      next if part.length < IGNORE_SIMILARITY_SHORTER_THAN

      return true if value.include?(part)
    end

    false
  end

  def blacklisted?
    Array(Decidim.password_blacklist).each do |expression|
      return true if expression.is_a?(Regexp) && value.match?(expression)
      return true if expression.to_s == value
    end

    false
  end

  def password_too_common?
    Decidim::CommonPasswords.instance.passwords.include?(value)
  end
end
