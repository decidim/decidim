# frozen_string_literal: true

module Decidim
  class MachineTranslationResourceJob < ApplicationJob
    queue_as :default

    def perform(resource)
      resource.translatable_fields_list.each do |field|
        MachineTranslationFieldsJob.perform_later(field)
      end
    end
  end
end
