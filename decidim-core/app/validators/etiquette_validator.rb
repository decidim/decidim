# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# respectful, does not use caps, and overall is meaningful.
class EtiquetteValidator < ActiveModel::EachValidator
  include ActionView::Helpers::SanitizeHelper

  def validate_each(record, attribute, value)
    return unless Decidim.enable_etiquette_validator
    return if value.blank?

    # remove HTML tags, from WYSIWYG editor
    text_value = clean_value(value)

    validate_caps(record, attribute, text_value)
    validate_marks(record, attribute, text_value)
    validate_caps_first(record, attribute, text_value)
  end

  private

  def clean_value(value)
    ActionController::Base.helpers.strip_tags(value).to_s.strip
  end

  def validate_caps(record, attribute, value)
    number_of_caps = value.scan(/[A-Z]/).length
    return if number_of_caps.zero? || number_of_caps < value.length / 2 # 50%

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
end
