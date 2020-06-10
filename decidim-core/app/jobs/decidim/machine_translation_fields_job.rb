# frozen_string_literal: true

module Decidim
  class MachineTranslationFieldsJob < ApplicationJob
    queue_as :default
 
    def perform(field)
      Decidim.available_locales.each do |locale|
        Decidim::TranslatedField.create(
          field_name: field,
          translation_locale: locale
        )
      end
    end
  end
end
