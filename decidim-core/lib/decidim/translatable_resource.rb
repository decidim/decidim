# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module TranslatableResource
    extend ActiveSupport::Concern

    included do
      after_create :machine_translation_new_resource
      after_update :machine_translation_updated_resource
      def self.translatable_fields(*list)
        @translatable_fields = list
      end

      def self.translatable_fields_list
        @translatable_fields
      end
    end

    def machine_translation_new_resource
      Decidim::MachineTranslationCreateResourceJob.perform_later(self, I18n.locale.to_s)
    end

    def machine_translation_updated_resource
      Decidim::MachineTranslationUpdatedResourceJob.perform_later(
        self,
        translatable_previous_changes,
        I18n.locale.to_s
      )
    end

    def translatable_previous_changes
      self.previous_changes.slice(*self.class.translatable_fields_list)
    end
  end
end
