# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdateFieldsJob < ApplicationJob
    queue_as :default

    def perform(resource, field_name, field_value, locale, source_locale)
      Decidim.machine_translation_service.to_s.safe_constantize.new(field_value, source_locale, locale).translate

    end
  end
end
