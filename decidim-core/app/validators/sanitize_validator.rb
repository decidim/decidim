# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# respectful, doesn't use invalid first character.
class SanitizeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_first_char(record, attribute, value)
  end

  private

  def validate_first_char(record, attribute, value)
    return unless invalid_first_chars.include? value.first

    record.errors.add(attribute, options[:message] || :invalid_first_char)
  end

  def invalid_first_chars
    %w(= + - @)
  end
end
