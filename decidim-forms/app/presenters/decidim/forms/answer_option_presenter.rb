# frozen_string_literal: true

module Decidim
  module Forms
    #
    # Decorator for answer_options
    #
    class AnswerOptionPresenter < SimpleDelegator
      include Decidim::TranslationsHelper

      def translated_body
        @translated_body ||= translated_attribute body
      end

      def json
        { id: id, body: translated_body }
      end
    end
  end
end
