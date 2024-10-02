# frozen_string_literal: true

module Decidim
  module Ai
    module Language
      autoload :Detection, "decidim/ai/language/detection"
      autoload :Formatter, "decidim/ai/language/formatter"
      include ActiveSupport::Configurable

      # Language detection service class.
      #
      # If you want to autodetect the language of the content, you can use a class service having the following contract
      #
      # class Detection
      #   def initialize(text)
      #     @text = text
      #   end
      #
      #   def language_code
      #     CLD.detect_language(@text).fetch(:code)
      #   end
      # end
      config_accessor :service do
        "Decidim::Ai::Language::Detection"
      end

      # Text cleanup service
      #
      # If you want to implement your own text formatter, you can use a class having the following contract
      #
      # class Formatter
      #   def cleanup(text)
      #     # your code
      #   end
      # end
      config_accessor :formatter do
        "Decidim::Ai::Language::Formatter"
      end
    end
  end
end
