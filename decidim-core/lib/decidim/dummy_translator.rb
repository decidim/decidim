# frozen_string_literal: true

module Decidim
  # This Dummy translator recieves the field value
  # and the locale of the field which has to be
  # translated. It returns the appended value for both.
  # This is for testing only.
  class DummyTranslator

    attr_reader :text, :original_locale, :target_locale
  
    def initialize(text, original_locale, target_locale)
      @text = text
      @original_locale = original_locale
      @target_locale = target_locale
    end

    def translate
       "#{target_locale} - #{text}"
    end
  end
end
