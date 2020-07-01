# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdatedResourceJob < ApplicationJob
    queue_as :default

    def perform(resource, previous_changes, source_locale)
      class_name = resource.class.name
      id = resource.id
      translatable_fields = resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        next unless previous_changes.keys.include?(field)
        next unless current_locale_changed(previous_changes, source_locale, field)

        locales = Decidim.available_locales.map(&:to_s)
        locales.each do |locale|
          next if locale == source_locale

          MachineTranslationUpdateFieldsJob.perform_later(id, class_name, field, resource_field_value(previous_changes, field, source_locale), locale)
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
  end
end
