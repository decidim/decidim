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
      if resource[field_name]["machine_translations"].present?
        resource[field_name]["machine_translations"] = resource[field_name]["machine_translations"].merge(target_locale => translated_text)
      else
        resource[field_name] = resource[field_name].merge("machine_translations" => { target_locale => translated_text })
      end

      # rubocop:disable Rails/SkipsModelValidations
      resource.update_column field_name.to_sym, resource[field_name]
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
