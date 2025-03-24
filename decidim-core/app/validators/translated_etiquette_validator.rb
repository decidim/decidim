# frozen_string_literal: true

# This validator takes care of i18n fields ensuring the validated content is
# respectful, does not use caps, and overall is meaningful.
#
#   validates :my_i18n_field, translated_etiquette: true
class TranslatedEtiquetteValidator < EtiquetteValidator
  def validate_each(record, attribute, _value)
    translated_attr = "#{attribute}_#{default_locale_for(record)}".gsub("-", "__")
    translated_value = record.send(translated_attr)
    return if translated_value.blank?

    text_value = strip_tags(translated_value)

    validate_caps(record, translated_attr, text_value)
    validate_marks(record, translated_attr, text_value)
    validate_caps_first(record, translated_attr, text_value)
  end

  private

  def default_locale_for(record)
    return record.default_locale if record.respond_to?(:default_locale)

    if record.current_organization
      record.current_organization.default_locale
    else
      record.errors.add(:current_organization, :blank)
      Decidim.default_locale
    end
  end
end
