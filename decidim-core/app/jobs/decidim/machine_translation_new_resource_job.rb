# frozen_string_literal: true

module Decidim
  class MachineTranslationNewResourceJob < ApplicationJob
    queue_as :default

    def perform(resource, source_locale)
      class_name = resource.class.name
      id = resource.id
      translatable_fields = resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        locales = Decidim.available_locales.map(&:to_s)
        locales.each do |locale|
          next unless locale != source_locale
          byebug
          MachineTranslationCreateFieldsJob.perform_later(id, class_name, field, resource[field], locale)
        end
      end
    end
  end
end
