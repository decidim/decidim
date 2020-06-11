# frozen_string_literal: true

module Decidim
  class MachineTranslationUpdatedResourceJob < ApplicationJob
    queue_as :default

    def perform(resource)
      class_name = resource.class.name
      id = resource.id
      translatable_fields = resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        if resource.previous_changes[field].present?
          MachineTranslationUpdateFieldsJob.perform_later(id, class_name, field)
        end
      end
    end
  end
end
