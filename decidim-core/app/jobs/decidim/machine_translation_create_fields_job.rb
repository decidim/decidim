# frozen_string_literal: true

module Decidim
  class MachineTranslationCreateFieldsJob < ApplicationJob
    queue_as :default

    def perform(id, resource_type, field_name, field_value, locale)
      Decidim::TranslatedField.create!(
        translated_resource_id: id,
        translated_resource_type: resource_type,
        field_name: field_name,
        field_value: field_value,
        translation_value: nil,
        translation_locale: locale
      )
      Decidim::DummyTranslator.translate(id, locale, field_name, field_value)
    end
  end
end
