# frozen_string_literal: true

module Decidim
  # This job is part of the machine translation flow. This one is fired every
  # time a `Decidim::TranslatableResource` is created or updated. If any of the
  # attributes defines as translatable is modified, then for each of those
  # attributes this job will schedule a `Decidim::MachineTranslationFieldsJob`.
  class MachineTranslationResourceJob < ApplicationJob
    queue_as :translations

    # rubocop: disable Metrics/CyclomaticComplexity

    # Performs the job.
    #
    # resource - Any kind of `Decidim::TranslatableResource` model instance
    # previous_changes - A Hash with the set fo changes. This is intended to be
    #   taken from `resource.previous_changes`, but we need to manually pass
    #   them to the job because the value gets lost when serializing the
    #   resource.
    # source_locale - A Symbol representing the source locale for the translation
    def perform(resource, previous_changes, source_locale)
      return unless Decidim.machine_translation_service_klass

      @resource = resource
      @locales_to_be_translated = []
      translatable_fields = @resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        next unless @resource[field].is_a?(Hash) && previous_changes.keys.include?(field)

        translated_locales = translated_locales_list(field)
        remove_duplicate_translations(field, translated_locales) if @resource[field]["machine_translations"].present?

        next unless default_locale_changed_or_translation_removed(previous_changes, field)

        @locales_to_be_translated += pending_locales(translated_locales) if @locales_to_be_translated.blank?

        @locales_to_be_translated.each do |target_locale|
          Decidim::MachineTranslationFieldsJob.perform_later(
            @resource,
            field,
            resource_field_value(
              previous_changes,
              field,
              source_locale
            ),
            target_locale,
            source_locale
          )
        end
      end
    end
    # rubocop: enable Metrics/CyclomaticComplexity

    def default_locale_changed_or_translation_removed(previous_changes, field)
      default_locale = default_locale(@resource)
      values = previous_changes[field]
      old_value = values.first
      new_value = values.last
      return true unless old_value.is_a?(Hash)

      return true if old_value[default_locale] != new_value[default_locale]

      # In a case where the default locale is not changed
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

    def resource_field_value(previous_changes, field, source_locale)
      values = previous_changes[field]
      new_value = values.last
      if new_value.is_a?(Hash)
        locale = source_locale || default_locale(@resource)
        return new_value[locale]
      end

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

    def pending_locales(translated_locales)
      available_locales = @resource.organization.available_locales.map(&:to_s) if @resource.respond_to? :organization
      available_locales ||= Decidim.available_locales.map(&:to_s)
      available_locales - translated_locales
    end
  end
end
