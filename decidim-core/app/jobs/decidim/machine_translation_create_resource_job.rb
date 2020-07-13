# frozen_string_literal: true

module Decidim
  class MachineTranslationCreateResourceJob < ApplicationJob
    queue_as :default

    def perform(resource, source_locale)
      translatable_fields = resource.class.translatable_fields_list.map(&:to_s)
      locales = available_locales(resource)

      translatable_fields.each do |field|
        locales.each do |locale|
          next if locale == source_locale
          next if resource_field_value(resource, field, source_locale).blank?

          MachineTranslationCreateFieldsJob.perform_later(
            resource,
            field,
            resource_field_value(
              resource,
              field,
              source_locale
            ),
            locale,
            source_locale
          )
        end
      end
    end

    def resource_field_value(resource, field, source_locale)
      value = resource[field]
      return value[source_locale] if value.is_a?(Hash)

      value
    end

    def available_locales(resource)
      locales = resource.organization.available_locales.map(&:to_s) if resource.respond_to? :organization
      locales ||=  resource.available_locales.map(&:to_s)
    end
  end
end
