# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# respectful, does not use caps, and overall is meaningful.
class EtiquetteValidator < ActiveModel::EachValidator
  include ActionView::Helpers::SanitizeHelper

  def validate_each(record, attribute, value)
    # remove HTML tags, from WYSIWYG editor
    value = clean_value(value)

    return if value.blank?

    text_value = strip_tags(value)

    validate_caps(record, attribute, text_value)
    validate_marks(record, attribute, text_value)
    validate_caps_first(record, attribute, text_value)
  end

  private

  def validate_caps(record, attribute, value)
    # to prevent :too_much_caps error when there are no caps and 1-3 char string
    caps = value.scan(/[A-Z]/).length
    return if caps.zero? || value.scan(/[A-Z]/).length < value.length / 4

    record.errors.add(attribute, options[:message] || :too_much_caps)
  end

  def validate_marks(record, attribute, value)
    return if value.scan(/[!?¡¿]{2,}/).empty?

    record.errors.add(attribute, options[:message] || :too_many_marks)
  end

  def validate_caps_first(record, attribute, value)
    return if value.scan(/\A[a-z]{1}/).empty?

    record.errors.add(attribute, options[:message] || :must_start_with_caps)
  end

  def clean_value(value)
    ActionController::Base.helpers.strip_tags(value).to_s.strip
  end
end
