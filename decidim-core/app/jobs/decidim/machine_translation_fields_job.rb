# frozen_string_literal: true

module Decidim
  # This job is part of the machine translation flow. This one specifically
  # delegates the arguments to the translation service, if any.
  class MachineTranslationFieldsJob < ApplicationJob
    queue_as :default

    # Performs the job. It won't perform anything if the
    # `Decidim.machine_translation_service` config is not set.
    #
    # resource - Any kind of `Decidim::TranslatableResource` model instance
    # field_name - A Symbol representing the name of the field being translated
    # field_value - A String with the value of the field to translate
    # target_locale - A Symbol representing the target locale for the translation
    # source_locale - A Symbol representing the source locale for the translation
    def perform(resource, field_name, field_value, target_locale, source_locale)
      klass = Decidim.machine_translation_service_klass
      return unless klass

      klass.new(
        resource,
        field_name,
        field_value,
        target_locale,
        source_locale
      ).translate
    end
  end
end
