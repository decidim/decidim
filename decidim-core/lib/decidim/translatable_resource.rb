# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module TranslatableResource
    extend ActiveSupport::Concern

    included do
      after_create :machine_translation_updated_resource
      after_update :machine_translation_updated_resource

      def self.translatable_fields(*list)
        @translatable_fields = list

        @translatable_fields.each do |field|
          method_name = "#{field}="

          # We're overriding the attribute setter method so that we can reuse the
          # machine translations. This is to fix a bug encoutered when updating
          # the resource from a FormObject. The FormObject on the `#create`
          # action in the controller doesn't have the machine translations loaded,
          # so they're effectively lost whenever a resource is updated.
          #
          # This overriding allows us to keep the old machine translations, so
          # that we skip some translations requests.
          define_method(method_name) do |new_value|
            original_value = attributes[field.to_s]

            return super(new_value) if new_value.has_key?("machine_translations")

            if original_value.has_key?("machine_translations")
              new_value = new_value.merge("machine_translations" => original_value["machine_translations"])
            end

            super(new_value)
          end
        end
      end

      def self.translatable_fields_list
        @translatable_fields
      end
    end

    def machine_translation_new_resource
      return unless Decidim.machine_translation_service.present?

      Decidim::MachineTranslationCreateResourceJob.perform_now(
        self,
        I18n.locale.to_s
      )
    end

    def machine_translation_updated_resource
      return unless Decidim.machine_translation_service.present?

      Decidim::MachineTranslationUpdatedResourceJob.perform_now(
        self,
        translatable_previous_changes,
        I18n.locale.to_s
      )
    end

    def translatable_previous_changes
      previous_changes.slice(*self.class.translatable_fields_list)
    end
  end
end
