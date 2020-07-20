# frozen_string_literal: true

module Decidim
  class MachineTranslationResourceJob < ApplicationJob
    queue_as :default

    def perform(resource, previous_changes, source_locale)
      translatable_fields = resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        next unless resource[field].is_a?(Hash) && previous_changes.keys.include?(field)

        translated_locales = translated_locales_list(resource, field)
        locales_to_be_translated = available_locales(resource, translated_locales)

        remove_duplicate_translations(resource, field, translated_locales) if resource[field]["machine_translations"].present?

        locales_to_be_translated.each do |locale|
          MachineTranslationFieldsJob.perform_later(
            resource,
            field,
            resource_field_value(
              previous_changes,
              field,
              source_locale
            ),
            locale,
            source_locale
          )
        end
      end
    end

    def resource_field_value(previous_changes, field, source_locale)
      values = previous_changes[field]
      new_value = values.last
      return new_value[source_locale] if new_value.is_a?(Hash)

      new_value
    end

    def translated_locales_list(resource, field)
      return nil unless resource[field].is_a? Hash

      translated_locales = []
      existing_locales = resource[field].keys - ["machine_translations"]
      existing_locales.each do |locale|
        translated_locales << locale if resource[field][locale].present?
      end

      translated_locales
    end

    def remove_duplicate_translations(resource, field, translated_locales)
      machine_translated_locale = resource[field]["machine_translations"].keys
      unless (translated_locales & machine_translated_locale).nil?
        (translated_locales & machine_translated_locale).each { |key| resource[field]["machine_translations"].delete key }
      end
    end

    def available_locales(resource, translated_locales)
      available_locales = resource.organization.available_locales.map(&:to_s) if resource.respond_to? :organization
      available_locales ||= Decidim.available_locales.map(&:to_s)
      available_locales -= translated_locales

      available_locales
    end
  end
end
