# frozen_string_literal: true

module Decidim
  module Forms
    #
    # Decorator for questions
    #
    class QuestionPresenter < SimpleDelegator
      include Decidim::TranslationsHelper

      def translated_body
        @translated_body ||= translated_attribute body
      end
    end
  end
end
