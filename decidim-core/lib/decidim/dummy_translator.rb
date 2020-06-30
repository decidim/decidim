# frozen_string_literal: true

module Decidim
  # This Dummy translator recieves the field value
  # and the locale of the field which has to be
  # translated. It returns the appended value for both.
  # This is for testing only.
  class DummyTranslator
    def self.translate(id, translation_locale, field_name, field_value)

      Decidim::TranslatedField.where(
        translated_resource_id: id,
        field_name: field_name,
        translation_locale: translation_locale
      ).update(
        translation_value: "#{translation_locale} - #{field_value}"
      )
    end
  end
end
