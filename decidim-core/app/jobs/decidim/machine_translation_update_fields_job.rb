# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdateFieldsJob < ApplicationJob
    queue_as :default

    def perform(id, resource_type, field_name)
      locales = Decidim.available_locales.map(&:to_s)
      locales.each do |locale|
        Decidim::TranslatedField.update!(
          translted_resource_id: id,
          translted_resource_type: resource_type,
          field_name: field_name,
          translation_locale: locale,
          translation_value: 'untranslated'
        )
      end
    end
  end
end
  