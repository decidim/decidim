# frozen_string_literal: true

module Decidim
  class MachineTranslationResourceJob < ApplicationJob
    queue_as :default

    def perform(resource, previous_changes, source_locale)
      @resource = resource
      @locales_to_be_translated = []
      translatable_fields = @resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        next unless @resource[field].is_a?(Hash) && previous_changes.keys.include?(field)

        translated_locales = translated_locales_list(field)
        remove_duplicate_translations(field, translated_locales) if @resource[field]["machine_translations"].present?

        next unless default_locale_changed_or_translation_removed(previous_changes, field)

        @locales_to_be_translated += available_locales(translated_locales) if @locales_to_be_translated.blank?

        @locales_to_be_translated.each do |locale|
          MachineTranslationFieldsJob.perform_later(
            resource,
            field,
            resource_field_value(
              previous_changes,
              field
            ),
            locale,
            source_locale
          )
        end
      end
    end

    def default_locale_changed_or_translation_removed(previous_changes, field)
      default_locale = default_locale(@resource)
      values = previous_changes[field]
      old_value = values.first
      new_value = values.last
      return true unless old_value.is_a?(Hash)

      return true if old_value[default_locale] != new_value[default_locale]

      # In a case where the default locale isn't changed
      # but a translation of a different locale is deleted
      # We trigger a job to translate only for that locale
      if old_value[default_locale] == new_value[default_locale]
        locales_present = old_value.keys
        locales_present.each do |locale|
          @locales_to_be_translated << locale if old_value[locale] != new_value[locale] && new_value[locale] == ""
        end
      end

      @locales_to_be_translated.present?
    end

    def resource_field_value(previous_changes, field)
      values = previous_changes[field]
      new_value = values.last
      return new_value[default_locale(@resource)] if new_value.is_a?(Hash)

      new_value
    end

    def default_locale(resource)
      if resource.respond_to? :organization
        resource.organization.default_locale.to_s
      else
        Decidim.available_locales.first.to_s
      end
    end

    def translated_locales_list(field)
      return nil unless @resource[field].is_a? Hash

      translated_locales = []
      existing_locales = @resource[field].keys - ["machine_translations"]
      existing_locales.each do |locale|
        translated_locales << locale if @resource[field][locale].present?
      end

      translated_locales
    end

    def remove_duplicate_translations(field, translated_locales)
      machine_translated_locale = @resource[field]["machine_translations"].keys
      unless (translated_locales & machine_translated_locale).nil?
        (translated_locales & machine_translated_locale).each { |key| @resource[field]["machine_translations"].delete key }
      end
    end

    def available_locales(translated_locales)
      available_locales = @resource.organization.available_locales.map(&:to_s) if @resource.respond_to? :organization
      available_locales ||= Decidim.available_locales.map(&:to_s)
      available_locales - translated_locales
    end
  end
end
