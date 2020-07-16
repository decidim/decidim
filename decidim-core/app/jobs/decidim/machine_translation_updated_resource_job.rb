# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdatedResourceJob < ApplicationJob
    queue_as :default

    def perform(resource, previous_changes, source_locale)
      translatable_fields = resource.class.translatable_fields_list.map(&:to_s)

      translatable_fields.each do |field|
        # keys must be true
        next unless previous_changes.keys.include?(field)

        # loclae must be cjanged
        next unless current_locale_changed(previous_changes, source_locale, field)

        locales = locales_to_be_translated(resource, field)

        locales.each do |locale|
          next if locale == source_locale

          MachineTranslationUpdateFieldsJob.perform_now(
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

    def current_locale_changed(previous_changes, source_locale, field)
      values = previous_changes[field]
      old_value = values.first
      new_value = values.last
      return true unless old_value.is_a?(Hash)

      old_value[source_locale] != new_value[source_locale]
    end

    def resource_field_value(previous_changes, field, source_locale)
      values = previous_changes[field]
      new_value = values.last
      return new_value[source_locale] if new_value.is_a?(Hash)

      new_value
    end

    def locales_to_be_translated(resource, field)
      translated_locales = []
      existing_locales = resource[field].keys - ["machine_translations"]
      existing_locales.each do |locale|
        unless resource[field][locale].blank?
          translated_locales << locale
        end
      end

      #Remove duplicate translations 
      #Make another function?
      #Refactor code
      if resource[field]["machine_translstions"].present?
        machine_translated_locale = resource[field]["machine_translstions"].keys
        unless (translated_locales & machine_translated_locale).nil?
          (translated_locales & machine_translated_locale).each { |key| resource[field]["machine_translstions"].delete key }
        end
      end

      available_locales = resource.organization.available_locales.map(&:to_s) if resource.respond_to? :organization
      available_locales ||=  Decidim.available_locales.map(&:to_s)

      locales_to_be_translated =  available_locales - translated_locales
    end
  end
end
