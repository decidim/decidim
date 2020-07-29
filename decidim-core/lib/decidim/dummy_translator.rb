# frozen_string_literal: true

module Decidim
  # This Dummy translator recieves the field value
  # and the locale of the field which has to be
  # translated. It returns the appended value for both.
  # This is for testing only.
  class DummyTranslator
    attr_reader :text, :original_locale, :target_locale, :resource, :field_name

    def initialize(resource, field_name, text, target_locale, original_locale)
      @resource = resource
      @field_name = field_name
      @text = text
      @target_locale = target_locale
      @original_locale = original_locale
    end

    def translate
      translated_text = "#{target_locale} - #{text}"

      MachineTranslationSaveJob.perform_later(
        resource,
        field_name,
        target_locale,
        translated_text
      )
    end
  end
end
