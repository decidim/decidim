# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdateFieldsJob < ApplicationJob
    queue_as :default

    def perform(id, resource_type, field_name, field_value, locale, source_locale)
      Decidim::TranslatedField.find_or_initialize_by(
        translated_resource_id: id,
        translated_resource_type: resource_type,
        field_name: field_name,
        translation_locale: locale
      ).update(field_value: field_value,
               translation_value: nil)
      Decidim::DummyTranslator.translate(id, locale, field_name, field_value)
    end
  end
end
