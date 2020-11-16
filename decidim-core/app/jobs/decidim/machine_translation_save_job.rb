# frozen_string_literal: true

module Decidim
  # This job is used by machine translation services to store the result of
  # a field translation. This way services don't need to care about how to
  # save it and also enables storing translations asynchronously when the
  # translation service returns the translated text in a webhook.
  class MachineTranslationSaveJob < ApplicationJob
    queue_as :default

    # Performs the job. It won't perform anything if the
    # `Decidim.machine_translation_service` config is not set.
    #
    # resource - Any kind of `Decidim::TranslatableResource` model instance
    # field_name - A Symbol representing the name of the field being translated
    # target_locale - A Symbol representing the target locale for the translation
    # translated_text - A String with the value of the field_name, translated
    #   into the target_locale
    def perform(resource, field_name, target_locale, translated_text)
      resource.with_lock do
        if resource[field_name]["machine_translations"].present?
          resource[field_name]["machine_translations"] = resource[field_name]["machine_translations"].merge(target_locale => translated_text)
        else
          resource[field_name] = resource[field_name].merge("machine_translations" => { target_locale => translated_text })
        end

        # rubocop:disable Rails/SkipsModelValidations
        resource.update_column field_name.to_sym, resource[field_name]
        # rubocop:enable Rails/SkipsModelValidations
      end

      send_translated_report_notifications(resource) if reported_resource_in_organization_language?(resource, target_locale)
    end

    private

    def send_translated_report_notifications(reportable)
      reportable.moderation.reports.each do |report|
        reportable.moderation.participatory_space.moderators.each do |moderator|
          Decidim::ReportedMailer.report(moderator, report).deliver_later
        end
      end
    end

    def reported_resource_in_organization_language?(resource, target_locale)
      return unless resource.try(:organization)

      resource_reported?(resource) && target_locale == resource.organization.default_locale && resource_completely_translated?(resource, target_locale)
    end

    def resource_reported?(resource)
      resource.class.included_modules.include?(Decidim::Reportable) && resource.reported?
    end

    def resource_completely_translated?(resource, target_locale)
      reported_translatable_fields = resource.reported_attributes & resource.class.translatable_fields_list
      reported_translatable_fields.all? do |field|
        resource[field]&.dig("machine_translations", target_locale).present?
      end
    end
  end
end
