# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module TranslatableResource
    extend ActiveSupport::Concern

    included do
      after_create :machine_translation
      after_update :machine_translation

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
            return super(new_value) if attributes[field.to_s].nil?
            return super(new_value) unless [new_value, attributes[field.to_s]].all?(Hash)
            return super(new_value) if new_value.has_key?("machine_translations")

            original_value = attributes[field.to_s]

            new_value = new_value.merge("machine_translations" => original_value["machine_translations"]) if original_value.has_key?("machine_translations")

            super(new_value)
          end
        end
      end

      def self.translatable_fields_list
        @translatable_fields
      end

      # Fires a job to start the machine translation process, only if the
      # service is properly configured and the organization has machine
      # translations enabled.
      def machine_translation
        return unless Decidim.machine_translation_service_klass

        organization = try(:organization)
        return if organization && !organization.enable_machine_translations
        return if try(:enable_machine_translations) == false

        Decidim::MachineTranslationResourceJob.perform_later(
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
end
