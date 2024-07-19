# frozen_string_literal: true

module Decidim
  module Ai
    module LanguageDetection
      autoload :Service, "decidim/ai/language_detection/service"
      include ActiveSupport::Configurable

      # Language detection service class.
      #
      # If you want to autodetect the language of the content, you can use a class service having the following contract
      #
      # class LanguageDetectionService
      #   def initialize(text)
      #     @text = text
      #   end
      #
      #   def language_code
      #     CLD.detect_language(@text).fetch(:code)
      #   end
      # end
      config_accessor :service do
        Decidim::Ai::LanguageDetection::Service
      end
    end
  end
end
