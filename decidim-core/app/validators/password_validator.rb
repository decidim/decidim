# frozen_string_literal: true

# Class is used to verify that the user's password is strong enough
class PasswordValidator < ActiveModel::EachValidator
  MINIMUM_LENGTH = 10
  MAX_LENGTH = 256
  MIN_UNIQUE_CHARACTERS = 5
  IGNORE_SIMILARITY_SHORTER_THAN = 4
  ADMIN_MINIMUM_LENGTH = Decidim.config.admin_password_min_characters
  ADMIN_REPETITION_TIMES = Decidim.config.admin_password_repetition_times
  VALIDATION_METHODS = [
    :password_too_short?,
    :password_too_long?,
    :not_enough_unique_characters?,
    :name_included_in_password?,
    :nickname_included_in_password?,
    :email_included_in_password?,
    :domain_included_in_password?,
    :password_too_common?,
    :blacklisted?,
    :password_repeated?
  ].freeze

  def self.minimum_length_for(record)
    return ADMIN_MINIMUM_LENGTH if record.try(:admin?)

    MINIMUM_LENGTH
  end

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
      record.errors.add attribute, get_message(reason)
    end

    false
  end

  protected

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
    value.length < self.class.minimum_length_for(record)
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

    record.name.split.each do |part|
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

  def password_repeated?
    return false unless Decidim.config.admin_password_strong_enable
    return false unless record.try(:admin?)
    return false unless record.try(:encrypted_password_changed?)

    [record.encrypted_password_was, *record.previous_passwords].compact_blank.take(ADMIN_REPETITION_TIMES).each do |encrypted_password|
      return true if Devise::Encryptor.compare(Decidim::User, encrypted_password, value)
    end

    false
  end
end
