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
      Decidim::MachineTranslationNewResourceJob.perform_now(self)
    end

    def machine_translation_updated_resource
      Decidim::MachineTranslationUpdatedResourceJob.perform_now(self)
    end
  end
end
