# frozen_string_literal: true

module Decidim
  class MachineTranslationCreateResourceJob < ApplicationJob
    queue_as :default

    def perform(resource, source_locale)
      class_name = resource.class.name
      id = resource.id
      translatable_fields = resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        locales = Decidim.available_locales.map(&:to_s)
        locales.each do |locale|
          next if locale == source_locale
          next if resource_field(resource, field, source_locale).blank?
          MachineTranslationCreateFieldsJob.perform_later(
            id,
            class_name,
            field,
            resource_field(resource, field, source_locale),
            locale
          )
        end
      end
    end

    def resource_field(resource, field, source_locale)
      value = resource[field]
      return value[source_locale] if value.is_a?(Hash)
      value
    end
  end
end
