# frozen_string_literal: true

require "cld"

module Decidim
  module Ai
    class LanguageDetectionService
      def initialize(text)
        @text = text
      end

      def language_code
        CLD.detect_language(@text).fetch(:code)
      end
    end
  end
end
