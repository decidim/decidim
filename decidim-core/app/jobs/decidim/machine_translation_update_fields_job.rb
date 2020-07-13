# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdateFieldsJob < ApplicationJob
    queue_as :default

    def perform(resource, field_name, field_value, locale, source_locale)
      translation_value = Decidim.machine_translation_service.to_s.safe_constantize.new(field_value, source_locale, locale).translate
      Decidim::TranslatedField.find_or_initialize_by(
        translated_resource: resource,
        field_name: field_name,
        translation_locale: locale
      ).update(field_value: field_value,
               translation_value: translation_value)
    end
  end
end
