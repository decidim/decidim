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

      #Refactor code
      if resource[field_name]["machine_translations"].present?
        resource[field_name]["machine_translations"] = resource[field_name]["machine_translations"].merge({locale => translation_value})
      else
        resource[field_name] = resource[field_name].merge({"machine_translations" =>{ locale => translation_value }})
      end

      resource.update_attribute field_name, resource[field_name]

      # DummyTranslatorJob.perform_later(
      #   resource,
      #   field_name,
      #   translated_text,
      #   target_locale
      # )
    end
  end
end
