# frozen_string_literal: true

module Decidim
  # This Dummy translator recieves the field value
  # and the locale of the field which has to be
  # translated. It returns the appended value for both.
  # This is for testing only.
  class DummyTranslator
    attr_reader :text, :original_locale, :target_locale, :resource, :field_name

    def initialize(resource, field_name, text, original_locale, target_locale)
      @resource = resource
      @field_name = field_name
      @text = text
      @original_locale = original_locale
      @target_locale = target_locale
    end

    def translate
      translated_text = "#{target_locale} - #{text}"

      # This is a Dummy Translator, it returns the translation
      # instantly and is only used for testing.
      # After integrating your translation service,
      # you could create a job to perform the following
      # storing operations.
      if resource[field_name]["machine_translations"].present?
        resource[field_name]["machine_translations"] = resource[field_name]["machine_translations"].merge(target_locale => translated_text)
      else
        resource[field_name] = resource[field_name].merge("machine_translations" => { target_locale => translated_text })
      end

      # rubocop:disable Rails/SkipsModelValidations
      resource.update_attribute field_name, resource[field_name]
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
