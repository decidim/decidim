# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdateFieldsJob < ApplicationJob
    queue_as :default

    def perform(resource, field_name, field_value, locale, source_locale)
      translation_value = Decidim.machine_translation_service.to_s.safe_constantize.new(field_value, source_locale, locale).translate

      #Refactor code
      if resource[field_name]["machine_translations"].present?
        resource[field_name]["machine_translations"] = resource[field_name]["machine_translations"].merge({locale => translation_value})
      else
        resource[field_name] = resource[field_name].merge({"machine_translations" =>{ locale => translation_value }})
      end

      resource.update_attribute field_name, resource[field_name]
    end
  end
end
