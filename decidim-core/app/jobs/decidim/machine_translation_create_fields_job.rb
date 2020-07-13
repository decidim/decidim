# frozen_string_literal: true

module Decidim
  class MachineTranslationCreateFieldsJob < ApplicationJob
    queue_as :default

    def perform(resource, field_name, field_value, locale, source_locale)
      translation_value = Decidim.machine_translation_service.to_s.safe_constantize.new(field_value, source_locale, locale).translate
      Decidim::TranslatedField.create!(
        translated_resource: resource,
        field_name: field_name,
        field_value: field_value,
        translation_value: translation_value,
        translation_locale: locale
      )
    end
  end
end
